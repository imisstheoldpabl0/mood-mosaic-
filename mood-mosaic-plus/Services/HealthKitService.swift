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

        // Define the health data types we want to read
        var typesToRead: Set<HKObjectType> = []

        if let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            typesToRead.insert(stepsType)
        }

        if let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) {
            typesToRead.insert(sleepType)
        }

        if let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            typesToRead.insert(heartRateType)
        }

        if let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            typesToRead.insert(activeEnergyType)
        }

        guard !typesToRead.isEmpty else {
            throw HealthKitError.dataNotAvailable
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: HealthKitError.fetchFailed(error))
                    } else {
                        self?.checkAuthorizationStatus()
                        continuation.resume(returning: ())
                    }
                }
            }
        }
    }

    private func checkAuthorizationStatus() {
        guard isHealthDataAvailable else {
            authorizationStatus = .notDetermined
            isAuthorized = false
            return
        }

        // Check authorization for multiple types
        var hasAnyAuthorization = false

        let typesToCheck: [HKObjectType] = [
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis),
            HKQuantityType.quantityType(forIdentifier: .heartRate),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        ].compactMap { $0 }

        for type in typesToCheck {
            let status = healthStore.authorizationStatus(for: type)
            if status == .sharingAuthorized {
                hasAnyAuthorization = true
                authorizationStatus = .sharingAuthorized
                break
            } else if status == .sharingDenied {
                authorizationStatus = .sharingDenied
            }
        }

        isAuthorized = hasAnyAuthorization

        // If no specific status was found, keep as notDetermined
        if !hasAnyAuthorization && authorizationStatus != .sharingDenied {
            authorizationStatus = .notDetermined
        }
    }

    // Health data fetching methods
    func fetchSleepHours(for date: Date) async throws -> Double {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthKitError.dataNotAvailable
        }

        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.fetchFailed(error))
                    return
                }

                guard let sleepSamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0.0)
                    return
                }

                // Calculate total sleep time (in bed + asleep)
                let totalSleepTime = sleepSamples
                    .filter { $0.value == HKCategoryValueSleepAnalysis.inBed.rawValue || $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue }
                    .reduce(0.0) { total, sample in
                        total + sample.endDate.timeIntervalSince(sample.startDate)
                    }

                let hoursSlept = totalSleepTime / 3600.0 // Convert seconds to hours
                continuation.resume(returning: hoursSlept)
            }

            self.healthStore.execute(query)
        }
    }

    func fetchWorkoutMinutes(for date: Date) async throws -> Int {
        guard let workoutType = HKWorkoutType.workoutType() else {
            throw HealthKitError.dataNotAvailable
        }

        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int, Error>) in
            let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.fetchFailed(error))
                    return
                }

                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(returning: 0)
                    return
                }

                let totalMinutes = workouts.reduce(0) { total, workout in
                    total + Int(workout.duration / 60.0) // Convert seconds to minutes
                }

                continuation.resume(returning: totalMinutes)
            }

            self.healthStore.execute(query)
        }
    }

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