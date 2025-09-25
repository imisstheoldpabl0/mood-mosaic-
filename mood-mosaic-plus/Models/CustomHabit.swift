//
//  CustomHabit.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import Foundation
import SwiftUI
import Combine

struct CustomHabit: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var icon: String
    var color: String
    var unit: String
    var targetValue: Double
    var currentValue: Double
    var isActive: Bool
    var createdAt: Date

    init(name: String, icon: String, color: String, unit: String, targetValue: Double = 1.0) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.color = color
        self.unit = unit
        self.targetValue = targetValue
        self.currentValue = 0
        self.isActive = true
        self.createdAt = Date()
    }

    var displayValue: String {
        if unit.isEmpty {
            return String(format: "%.0f", currentValue)
        } else {
            return String(format: "%.0f %@", currentValue, unit)
        }
    }

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }

    var colorValue: Color {
        switch color {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        case "brown": return .brown
        case "cyan": return .cyan
        case "mint": return .mint
        case "indigo": return .indigo
        default: return .blue
        }
    }
}

// Custom Habits Data Store
class CustomHabitsStore: ObservableObject {
    static let shared = CustomHabitsStore()

    @Published var habits: [CustomHabit] = []

    private let userDefaults = UserDefaults.standard
    private let customHabitsKey = "CustomHabits"

    private init() {
        loadHabits()
    }

    func addHabit(_ habit: CustomHabit) {
        habits.append(habit)
        saveHabits()
    }

    func updateHabit(_ habit: CustomHabit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
        }
    }

    func deleteHabit(_ habit: CustomHabit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }

    func incrementHabit(_ habitId: UUID, by amount: Double = 1.0) {
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            habits[index].currentValue += amount
            saveHabits()
        }
    }

    func resetDailyValues() {
        for index in habits.indices {
            habits[index].currentValue = 0
        }
        saveHabits()
    }

    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            userDefaults.set(encoded, forKey: customHabitsKey)
        }
    }

    private func loadHabits() {
        if let data = userDefaults.data(forKey: customHabitsKey),
           let decoded = try? JSONDecoder().decode([CustomHabit].self, from: data) {
            habits = decoded
        } else {
            // Add some default custom habits
            habits = [
                CustomHabit(name: "Meditation", icon: "brain.head.profile", color: "purple", unit: "min", targetValue: 10),
                CustomHabit(name: "Reading", icon: "book.fill", color: "brown", unit: "pages", targetValue: 20),
                CustomHabit(name: "Steps", icon: "figure.walk", color: "green", unit: "steps", targetValue: 10000),
            ]
            saveHabits()
        }
    }
}