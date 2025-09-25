//
//  SimpleMoodEntry.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import Foundation
import Combine

struct SimpleMoodEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let intensity: Double
    let tags: [String]
    let note: String?
    let source: String
    let timestamp: Date

    init(
        intensity: Double,
        tags: [String] = [],
        note: String? = nil,
        source: String = "manual",
        timestamp: Date = Date()
    ) {
        self.id = UUID()
        self.intensity = intensity
        self.tags = tags
        self.note = note
        self.source = source
        self.timestamp = timestamp
    }

    init(
        id: UUID,
        intensity: Double,
        tags: [String],
        note: String?,
        source: String,
        timestamp: Date
    ) {
        self.id = id
        self.intensity = intensity
        self.tags = tags
        self.note = note
        self.source = source
        self.timestamp = timestamp
    }

    var intensityPercentage: String {
        return String(format: "%.0f%%", intensity)
    }

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var tagsList: [String] {
        return tags
    }
}

// Mock Data Store for MVP
class MoodDataStore: ObservableObject {
    static let shared = MoodDataStore()

    @Published var moodEntries: [SimpleMoodEntry] = []

    private let userDefaults = UserDefaults.standard
    private let moodEntriesKey = "MoodEntries"

    private init() {
        loadMoodEntries()
    }

    func addMoodEntry(_ entry: SimpleMoodEntry) {
        moodEntries.append(entry)
        saveMoodEntries()
    }

    func deleteMoodEntry(_ entry: SimpleMoodEntry) {
        moodEntries.removeAll { $0.id == entry.id }
        saveMoodEntries()
    }

    func updateMoodEntry(_ entry: SimpleMoodEntry) {
        if let index = moodEntries.firstIndex(where: { $0.id == entry.id }) {
            moodEntries[index] = entry
            saveMoodEntries()
        }
    }

    func getMoodEntries(for date: Date) -> [SimpleMoodEntry] {
        let calendar = Calendar.current
        return moodEntries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: date)
        }
    }

    func getRecentMoodEntries(days: Int = 7) -> [SimpleMoodEntry] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return moodEntries.filter { $0.timestamp >= cutoffDate }
            .sorted { $0.timestamp > $1.timestamp }
    }

    private func saveMoodEntries() {
        if let encoded = try? JSONEncoder().encode(moodEntries) {
            userDefaults.set(encoded, forKey: moodEntriesKey)
        }
    }

    private func loadMoodEntries() {
        if let data = userDefaults.data(forKey: moodEntriesKey),
           let decoded = try? JSONDecoder().decode([SimpleMoodEntry].self, from: data) {
            moodEntries = decoded
        }
    }
}