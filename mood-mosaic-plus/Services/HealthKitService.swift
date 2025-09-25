//
//  HealthKitService.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import Foundation
import HealthKit
import Combine

enum HealthKitError: Error {
    case notAvailable
    case dataNotAvailable
    case authorizationDenied
    case fetchFailed(Error)
}

class HealthKitService: ObservableObject {
    @Published var isAuthorized = false
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined

    private let healthStore = HKHealthStore()

    init() {
        checkAuthorizationStatus()
    }

    var isHealthDataAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isHealthDataAvailable else {
            throw HealthKitError.notAvailable
        }

        // Simplified for MVP - just basic step count for now
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.dataNotAvailable
        }

        let typesToRead: Set<HKObjectType> = [stepsType]

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: HealthKitError.fetchFailed(error))
                    } else {
                        self?.isAuthorized = success
                        self?.checkAuthorizationStatus()
                        continuation.resume(returning: ())
                    }
                }
            }
        }
    }

    private func checkAuthorizationStatus() {
        guard isHealthDataAvailable,
              let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }

        let status = healthStore.authorizationStatus(for: stepsType)
        authorizationStatus = status
        isAuthorized = status == .sharingAuthorized
    }

    // Simplified methods for MVP
    func fetchSteps(for date: Date) async throws -> Int {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.dataNotAvailable
        }

        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int, Error>) in
            let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in

                if let error = error {
                    continuation.resume(throwing: HealthKitError.fetchFailed(error))
                    return
                }

                guard let result = result, let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }

                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                continuation.resume(returning: steps)
            }

            self.healthStore.execute(query)
        }
    }
}