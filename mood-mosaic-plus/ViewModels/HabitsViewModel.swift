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
    @Published var waterGlasses: Int = 0
    @Published var sleepHours: Double = 0

    // Goal properties for default habits
    @Published var caffeineGoal: Int = 200 // mg per day
    @Published var waterGoal: Int = 8 // glasses per day
    @Published var exerciseGoal: Int = 30 // minutes per day
    @Published var sleepGoal: Double = 8.0 // hours per day
    @Published var alcoholLimit: Int = 2 // units per day (goal is to stay under)

    var trackedHabitsCount: Int {
        var count = 0
        if caffeineMg > 0 { count += 1 }
        if alcoholUnits > 0 { count += 1 }
        if exerciseMinutes > 0 { count += 1 }
        if waterGlasses > 0 { count += 1 }
        if sleepHours > 0 { count += 1 }
        return count
    }

    // Progress calculations for each habit
    var caffeineProgress: Double {
        Double(caffeineMg) / Double(caffeineGoal)
    }

    var waterProgress: Double {
        Double(waterGlasses) / Double(waterGoal)
    }

    var exerciseProgress: Double {
        Double(exerciseMinutes) / Double(exerciseGoal)
    }

    var sleepProgress: Double {
        sleepHours / sleepGoal
    }

    var alcoholProgress: Double {
        // For alcohol, we want to stay UNDER the limit, so progress is inverted
        if alcoholUnits <= alcoholLimit {
            return 1.0 - (Double(alcoholUnits) / Double(alcoholLimit))
        } else {
            return 0.0 // Over limit = 0% progress
        }
    }

    // Formatted progress percentages that can go over 100%
    var caffeineProgressPercent: String {
        String(format: "%.0f%%", caffeineProgress * 100)
    }

    var waterProgressPercent: String {
        String(format: "%.0f%%", waterProgress * 100)
    }

    var exerciseProgressPercent: String {
        String(format: "%.0f%%", exerciseProgress * 100)
    }

    var sleepProgressPercent: String {
        String(format: "%.0f%%", sleepProgress * 100)
    }

    var alcoholProgressPercent: String {
        if alcoholUnits <= alcoholLimit {
            return "✓ Good"
        } else {
            return "Over limit"
        }
    }

    var healthScore: Int {
        var score = 30 // Base score

        // Exercise bonus
        if exerciseMinutes >= 30 {
            score += 25
        } else if exerciseMinutes > 0 {
            score += 15
        }

        // Caffeine impact
        if caffeineMg > 400 {
            score -= 15
        } else if caffeineMg > 300 {
            score -= 10
        } else if caffeineMg > 200 {
            score -= 5
        } else if caffeineMg > 0 {
            score += 5 // Moderate caffeine can be beneficial
        }

        // Alcohol penalty
        if alcoholUnits > 3 {
            score -= 20
        } else if alcoholUnits > 2 {
            score -= 15
        } else if alcoholUnits > 1 {
            score -= 10
        }

        // Water bonus
        if waterGlasses >= 8 {
            score += 15
        } else if waterGlasses >= 6 {
            score += 10
        } else if waterGlasses >= 4 {
            score += 5
        }

        // Sleep bonus
        if sleepHours >= 7.5 {
            score += 20
        } else if sleepHours >= 6.5 {
            score += 10
        } else if sleepHours >= 5.5 {
            score += 5
        } else if sleepHours > 0 && sleepHours < 5 {
            score -= 10 // Too little sleep
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
        waterGlasses += 1
        provideFeedback()
    }

    func addGoodSleep() {
        sleepHours = 8.0 // Set to ideal sleep
        provideFeedback()
    }

    func setAlcoholUnits(_ units: Int) {
        alcoholUnits = units
        provideFeedback()
    }

    func setCaffeineMg(_ mg: Int) {
        caffeineMg = mg
        provideFeedback()
    }

    func setExercise(type: String, minutes: Int) {
        exerciseType = type
        exerciseMinutes = minutes
        provideFeedback()
    }

    func setWaterGlasses(_ glasses: Int) {
        waterGlasses = glasses
        provideFeedback()
    }

    func setSleepHours(_ hours: Double) {
        sleepHours = hours
        provideFeedback()
    }

    // Goal setting methods
    func setCaffeineGoal(_ goal: Int) {
        caffeineGoal = goal
        provideFeedback()
    }

    func setWaterGoal(_ goal: Int) {
        waterGoal = goal
        provideFeedback()
    }

    func setExerciseGoal(_ goal: Int) {
        exerciseGoal = goal
        provideFeedback()
    }

    func setSleepGoal(_ goal: Double) {
        sleepGoal = goal
        provideFeedback()
    }

    func setAlcoholLimit(_ limit: Int) {
        alcoholLimit = limit
        provideFeedback()
    }

    private func provideFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}