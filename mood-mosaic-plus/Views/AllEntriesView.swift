//
//  AllEntriesView.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import SwiftUI

struct AllEntriesView: View {
    @ObservedObject private var dataStore = MoodDataStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEntryForEditing: SimpleMoodEntry?
    @State private var showingEditView = false
    @State private var selectedTimeFilter: TimeFilter = .all

    enum TimeFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case week = "This Week"
        case month = "This Month"

        var title: String {
            return self.rawValue
        }
    }

    private var filteredEntries: [SimpleMoodEntry] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedTimeFilter {
        case .all:
            return dataStore.moodEntries.sorted { $0.timestamp > $1.timestamp }
        case .today:
            return dataStore.moodEntries.filter { entry in
                calendar.isDate(entry.timestamp, inSameDayAs: now)
            }.sorted { $0.timestamp > $1.timestamp }
        case .week:
            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else {
                return []
            }
            return dataStore.moodEntries.filter { entry in
                entry.timestamp >= weekAgo
            }.sorted { $0.timestamp > $1.timestamp }
        case .month:
            guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) else {
                return []
            }
            return dataStore.moodEntries.filter { entry in
                entry.timestamp >= monthAgo
            }.sorted { $0.timestamp > $1.timestamp }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Time filter picker
                Picker("Time Filter", selection: $selectedTimeFilter) {
                    ForEach(TimeFilter.allCases, id: \.self) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if filteredEntries.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(entriesByDate, id: \.date) { dateGroup in
                                VStack(alignment: .leading, spacing: 8) {
                                    // Date header
                                    HStack {
                                        Text(dateGroup.date, style: .date)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Text("\(dateGroup.entries.count) entries")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 8)

                                    // Entries for this date
                                    ForEach(dateGroup.entries, id: \.id) { entry in
                                        entryCard(entry)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("All Entries")
            .navigationBarTitleDisplayMode(.large)
            .background(.regularMaterial)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                if let selectedEntry = selectedEntryForEditing {
                    EditMoodView(entry: selectedEntry)
                }
            }
        }
    }

    // MARK: - Entry Card
    private func entryCard(_ entry: SimpleMoodEntry) -> some View {
        Button {
            selectedEntryForEditing = entry
            showingEditView = true

            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        } label: {
            HStack(spacing: 12) {
                // Mood indicator
                Circle()
                    .fill(moodColor(for: entry.intensity))
                    .frame(width: 16, height: 16)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Mood: \(Int(entry.intensity))")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        if !entry.tags.isEmpty {
                            Text("• \(entry.tags.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }

                        Spacer()

                        Text(entry.timestamp.formatted(.dateTime.hour().minute()))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let note = entry.note, !note.isEmpty {
                        Text("\"\(note)\"")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .italic()
                            .lineLimit(3)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.regularMaterial, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Entries Found")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Try adjusting your filter or add some mood entries to see them here.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helper Properties
    private var entriesByDate: [(date: Date, entries: [SimpleMoodEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }

        return grouped.map { (date, entries) in
            (date: date, entries: entries.sorted { $0.timestamp > $1.timestamp })
        }.sorted { $0.date > $1.date }
    }

    // MARK: - Helper Functions
    private func moodColor(for intensity: Double) -> Color {
        switch intensity {
        case 0..<30:
            return .red
        case 30..<50:
            return .orange
        case 50..<70:
            return .yellow
        case 70..<85:
            return .green
        default:
            return .blue
        }
    }
}

#Preview {
    AllEntriesView()
}