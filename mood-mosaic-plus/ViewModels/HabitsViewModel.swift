//
//  HabitsViewModel.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HabitsViewModel: ObservableObject {
    @Published var caffeineMg: Int = 0
    @Published var alcoholUnits: Int = 0
    @Published var exerciseType: String = ""
    @Published var exerciseMinutes: Int = 0
    @Published var todayNotes: String = ""

    var trackedHabitsCount: Int {
        var count = 0
        if caffeineMg > 0 { count += 1 }
        if alcoholUnits > 0 { count += 1 }
        if exerciseMinutes > 0 { count += 1 }
        return count
    }

    var healthScore: Int {
        var score = 50 // Base score

        // Exercise bonus
        if exerciseMinutes >= 30 {
            score += 25
        } else if exerciseMinutes > 0 {
            score += 10
        }

        // Caffeine penalty
        if caffeineMg > 300 {
            score -= 15
        } else if caffeineMg > 200 {
            score -= 10
        } else if caffeineMg > 0 {
            score += 5 // Some caffeine is fine
        }

        // Alcohol penalty
        if alcoholUnits > 2 {
            score -= 20
        } else if alcoholUnits > 1 {
            score -= 10
        }

        return max(0, min(100, score))
    }

    init() {
        loadTodayData()
    }

    private func loadTodayData() {
        // In a real implementation, this would load from Core Data
        // For now, we'll start fresh each day
    }

    func addCoffee() {
        caffeineMg += 100
        provideFeedback()
    }

    func addWorkout() {
        exerciseType = "Workout"
        exerciseMinutes += 30
        provideFeedback()
    }

    func addWater() {
        // Could track water intake in a future version
        provideFeedback()
    }

    func addGoodSleep() {
        // Could integrate with HealthKit sleep data
        provideFeedback()
    }

    private func provideFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}