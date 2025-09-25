//
//  TodaysEntriesView.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import SwiftUI

struct TodaysEntriesView: View {
    @ObservedObject private var dataStore = MoodDataStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEntryForEditing: SimpleMoodEntry?
    @State private var showingEditView = false

    private var todaysEntries: [SimpleMoodEntry] {
        dataStore.getMoodEntries(for: Date()).sorted { $0.intensity > $1.intensity }
    }

    private var averageMood: Double {
        guard !todaysEntries.isEmpty else { return 0 }
        return todaysEntries.reduce(0) { $0 + $1.intensity } / Double(todaysEntries.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Stats
                    summaryStatsCard

                    // All Today's Entries
                    entriesListCard
                }
                .padding()
            }
            .navigationTitle("Today's Details")
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

    // MARK: - Summary Stats Card
    private var summaryStatsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Summary")
                .font(.headline)
                .foregroundStyle(.primary)

            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Total Entries")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(todaysEntries.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }

                Divider()

                VStack(alignment: .leading) {
                    Text("Average Mood")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(todaysEntries.isEmpty ? "-" : "\(averageMood, specifier: "%.0f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(moodColor(for: averageMood))
                }

                Spacer()
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.regularMaterial, lineWidth: 1)
        )
    }

    // MARK: - Entries List Card
    private var entriesListCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("All Entries")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                if !todaysEntries.isEmpty {
                    Text("Sorted by mood")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if todaysEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)

                    Text("No entries yet today")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Add your first mood entry to start tracking your day!")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                ForEach(todaysEntries, id: \.id) { entry in
                    entryCard(entry)

                    if entry != todaysEntries.last {
                        Divider()
                            .opacity(0.3)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.regularMaterial, lineWidth: 1)
        )
    }

    // MARK: - Entry Card
    private func entryCard(_ entry: SimpleMoodEntry) -> some View {
        Button {
            selectedEntryForEditing = entry
            showingEditView = true

            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Circle()
                        .fill(moodColor(for: entry.intensity))
                        .frame(width: 12, height: 12)

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

                    Image(systemName: "pencil")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                if let note = entry.note, !note.isEmpty {
                    Text("\"\(note)\"")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                        .padding(.leading, 20)
                }
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .padding(.vertical, 4)
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
    TodaysEntriesView()
}