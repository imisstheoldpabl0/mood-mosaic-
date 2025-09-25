//
//  InsightsViewModel.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import Foundation
import SwiftUI
import Combine

struct WeeklyTrendData {
    let day: String
    let averageMood: Double
    let entryCount: Int
}

@MainActor
class InsightsViewModel: ObservableObject {
    @Published var todayAverageMood: Double = 0
    @Published var todayEntryCount: Int = 0
    @Published var todayDominantEmotion: String? = nil
    @Published var weeklyTrendData: [WeeklyTrendData] = []
    @Published var weeklyTrendDescription: String = ""

    private let calendar = Calendar.current

    func loadInsights(from moods: [SimpleMoodEntry]) {
        calculateTodaysInsights(from: moods)
        calculateWeeklyTrend(from: moods)
    }

    private func calculateTodaysInsights(from moods: [SimpleMoodEntry]) {
        let today = calendar.startOfDay(for: Date())
        let todaysMoods = moods.filter { mood in
            return calendar.isDate(mood.timestamp, inSameDayAs: today)
        }

        todayEntryCount = todaysMoods.count

        if !todaysMoods.isEmpty {
            todayAverageMood = todaysMoods.reduce(0) { $0 + $1.intensity } / Double(todaysMoods.count)

            // Find dominant emotion
            var emotionCounts: [String: Int] = [:]
            for mood in todaysMoods {
                for tag in mood.tagsList {
                    emotionCounts[tag, default: 0] += 1
                }
            }

            todayDominantEmotion = emotionCounts.max(by: { $0.1 < $1.1 })?.key
        } else {
            todayAverageMood = 0
            todayDominantEmotion = nil
        }
    }

    private func calculateWeeklyTrend(from moods: [SimpleMoodEntry]) {
        var trendData: [WeeklyTrendData] = []

        // Get last 7 days
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let startOfDay = calendar.startOfDay(for: date)

            let dayMoods = moods.filter { mood in
                return calendar.isDate(mood.timestamp, inSameDayAs: startOfDay)
            }

            let averageMood = dayMoods.isEmpty ? 0 : dayMoods.reduce(0) { $0 + $1.intensity } / Double(dayMoods.count)

            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "E"
            let dayString = dayFormatter.string(from: date)

            trendData.append(WeeklyTrendData(day: dayString, averageMood: averageMood, entryCount: dayMoods.count))
        }

        weeklyTrendData = trendData.reversed()

        // Calculate trend description
        let nonZeroMoods = trendData.filter { $0.averageMood > 0 }
        if nonZeroMoods.count >= 2 {
            let recent = nonZeroMoods.suffix(3)
            let earlier = nonZeroMoods.prefix(3)

            let recentAverage = recent.reduce(0) { $0 + $1.averageMood } / Double(recent.count)
            let earlierAverage = earlier.reduce(0) { $0 + $1.averageMood } / Double(earlier.count)

            if recentAverage > earlierAverage + 5 {
                weeklyTrendDescription = "Improving ↗️"
            } else if recentAverage < earlierAverage - 5 {
                weeklyTrendDescription = "Declining ↘️"
            } else {
                weeklyTrendDescription = "Stable →"
            }
        } else {
            weeklyTrendDescription = "Insufficient data"
        }
    }
}