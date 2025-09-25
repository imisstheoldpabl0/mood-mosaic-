//
//  InsightsView.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import SwiftUI

struct InsightsView: View {
    @StateObject private var healthKitService = HealthKitService()
    @StateObject private var viewModel = InsightsViewModel()
    @ObservedObject private var dataStore = MoodDataStore.shared
    @State private var selectedEntryForEditing: SimpleMoodEntry?
    @State private var showingEditView = false
    @State private var showingTodaysEntries = false
    @State private var showingAllEntries = false

    private var recentMoods: [SimpleMoodEntry] {
        dataStore.getRecentMoodEntries(days: 7)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if recentMoods.isEmpty {
                        emptyStateView
                    } else {
                        // Today's Summary
                        todaysSummaryCard

                        // Weekly Trend
                        weeklyTrendCard

                        // Health Correlations
                        if healthKitService.isAuthorized {
                            healthCorrelationsCard
                        } else {
                            healthKitAuthCard
                        }

                        // Recent Entries
                        recentEntriesCard
                    }
                }
                .padding()
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .background(.regularMaterial)
            .onAppear {
                viewModel.loadInsights(from: recentMoods)
            }
            .onReceive(dataStore.$moodEntries) { _ in
                viewModel.loadInsights(from: recentMoods)
            }
            .sheet(isPresented: $showingEditView) {
                if let selectedEntry = selectedEntryForEditing {
                    EditMoodView(entry: selectedEntry)
                }
            }
            .sheet(isPresented: $showingTodaysEntries) {
                TodaysEntriesView()
            }
            .sheet(isPresented: $showingAllEntries) {
                AllEntriesView()
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Data Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start logging your moods to see personalized insights and trends.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Today's Summary
    private var todaysSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Summary")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Text(Date(), style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Stats row
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Average Mood")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.todayEntryCount > 0 ? "\(viewModel.todayAverageMood, specifier: "%.0f")" : "-")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(moodColor(for: viewModel.todayAverageMood))
                }

                Divider()

                VStack(alignment: .leading) {
                    Text("Entries")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.todayEntryCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }

                Spacer()
            }

            // Today's entries breakdown
            if viewModel.todayEntryCount > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Entries:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    let todaysEntries = dataStore.getMoodEntries(for: Date()).sorted { $0.intensity > $1.intensity }
                    ForEach(todaysEntries.prefix(3), id: \.id) { entry in
                        Button {
                            editEntry(entry)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(entry.timestamp.formatted(.dateTime.hour().minute()))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Text("•")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Text("Mood: \(Int(entry.intensity))")
                                        .font(.caption)
                                        .fontWeight(.medium)

                                    if !entry.tags.isEmpty {
                                        Text("•")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)

                                        Text(entry.tags.joined(separator: ", "))
                                            .font(.caption)
                                            .foregroundStyle(.blue)
                                    }

                                    Spacer()

                                    Image(systemName: "pencil")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }

                                if let note = entry.note, !note.isEmpty {
                                    Text("\"\(note)\"")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .italic()
                                        .padding(.leading, 8)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.primary)
                        .padding(.vertical, 2)

                        if entry != todaysEntries.prefix(3).last {
                            Divider()
                                .opacity(0.3)
                        }
                    }

                    if todaysEntries.count > 3 {
                        Button {
                            showingTodaysEntries = true
                        } label: {
                            Text("+ \(todaysEntries.count - 3) more entries")
                                .font(.caption)
                                .foregroundStyle(.blue)
                                .padding(.top, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 8)
            }

            if let dominantEmotion = viewModel.todayDominantEmotion {
                Text("Most common emotion: \(dominantEmotion)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.regularMaterial, lineWidth: 1)
        )
    }

    // MARK: - Weekly Trend
    private var weeklyTrendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7-Day Trend")
                .font(.headline)
                .foregroundStyle(.primary)

            HStack(spacing: 4) {
                ForEach(viewModel.weeklyTrendData, id: \.day) { data in
                    VStack(spacing: 4) {
                        ZStack {
                            Rectangle()
                                .fill(moodColor(for: data.averageMood))
                                .frame(width: 30, height: max(20, data.averageMood * 0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 2))

                            if data.entryCount > 0 {
                                Text("\(data.entryCount)")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }

                        Text(data.day)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            HStack {
                Text("Trend: \(viewModel.weeklyTrendDescription)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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

    // MARK: - Health Correlations
    private var healthCorrelationsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Health Correlations")
                .font(.headline)
                .foregroundStyle(.primary)

            // Placeholder for now - would show correlations with sleep, steps, etc.
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "bed.double.fill")
                        .foregroundStyle(.blue)
                    Text("Sleep Duration")
                        .font(.subheadline)
                    Spacer()
                    Text("Moderate correlation")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundStyle(.green)
                    Text("Daily Steps")
                        .font(.subheadline)
                    Spacer()
                    Text("Weak correlation")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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

    // MARK: - Health Insights Section
    private var healthKitAuthCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Insights")
                .font(.headline)
                .foregroundStyle(.primary)

            if healthKitService.isAuthorized {
                // Connected state - show health data
                connectedHealthInsights
            } else {
                // Not connected state - show connect button
                VStack(alignment: .leading, spacing: 12) {
                    Text("Connect with Apple Health to see correlations between your mood and health metrics like sleep, activity, and heart rate.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button {
                        Task { @MainActor in
                            do {
                                try await healthKitService.requestAuthorization()
                            } catch HealthKitError.notAvailable {
                                print("HealthKit is not available on this device")
                            } catch HealthKitError.authorizationDenied {
                                print("HealthKit authorization was denied")
                            } catch {
                                print("HealthKit authorization failed: \(error)")
                            }
                        }
                    } label: {
                        Text("Connect Apple Health")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue, in: RoundedRectangle(cornerRadius: 12))
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

    // MARK: - Connected Health Insights
    @ViewBuilder
    private var connectedHealthInsights: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Connected to Apple Health")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.green)
            }

            // Health metrics grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                HealthMetricCard(
                    title: "Sleep",
                    value: sleepData,
                    icon: "bed.double.fill",
                    color: .indigo
                )

                HealthMetricCard(
                    title: "Exercise",
                    value: workoutData,
                    icon: "figure.run",
                    color: .green
                )

                HealthMetricCard(
                    title: "Steps",
                    value: stepsData,
                    icon: "figure.walk",
                    color: .blue
                )

                HealthMetricCard(
                    title: "Heart Rate",
                    value: "85 BPM",
                    icon: "heart.fill",
                    color: .red
                )
            }

            // Mood correlation insights
            VStack(alignment: .leading, spacing: 8) {
                Text("Mood Correlations")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                correlationInsight(
                    metric: "Sleep",
                    correlation: "Better mood with 8+ hours",
                    trend: .positive
                )

                correlationInsight(
                    metric: "Exercise",
                    correlation: "30% mood boost after workouts",
                    trend: .positive
                )
            }
        }
    }

    private func correlationInsight(metric: String, correlation: String, trend: CorrelationTrend) -> some View {
        HStack(spacing: 8) {
            Image(systemName: trend == .positive ? "arrow.up.right" : "arrow.down.right")
                .font(.caption)
                .foregroundStyle(trend == .positive ? .green : .red)

            VStack(alignment: .leading, spacing: 2) {
                Text(metric)
                    .font(.caption)
                    .fontWeight(.medium)

                Text(correlation)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }

    // MARK: - Health Data Properties
    private var sleepData: String {
        if healthKitService.isAuthorized {
            return "7.5 hrs" // This would be fetched from HealthKit
        } else {
            return "No data"
        }
    }

    private var workoutData: String {
        if healthKitService.isAuthorized {
            return "45 min" // This would be fetched from HealthKit
        } else {
            return "No data"
        }
    }

    private var stepsData: String {
        if healthKitService.isAuthorized {
            return "8,432" // This would be fetched from HealthKit
        } else {
            return "No data"
        }
    }

    enum CorrelationTrend {
        case positive, negative
    }

    // MARK: - Recent Entries
    private var recentEntriesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Entries")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Text("Latest 3")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(Array(recentMoods.prefix(3)), id: \.id) { mood in
                Button {
                    // Edit functionality
                    editEntry(mood)
                } label: {
                    HStack {
                        Circle()
                            .fill(moodColor(for: mood.intensity))
                            .frame(width: 12, height: 12)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text("\(Int(mood.intensity))")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                if !mood.tagsList.isEmpty {
                                    Text("• \(mood.tagsList.joined(separator: ", "))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(mood.timestamp.formatted(.relative(presentation: .numeric)))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if let note = mood.note, !note.isEmpty {
                                Text("\"\(note)\"")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .italic()
                                    .lineLimit(2)
                            }
                        }

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary)
                .padding(.vertical, 4)

                if mood != recentMoods.prefix(3).last {
                    Divider()
                }
            }

            // View All button
            if recentMoods.count > 3 {
                Button {
                    showingAllEntries = true
                } label: {
                    HStack {
                        Text("View All")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        Image(systemName: "arrow.right")
                            .font(.caption)
                    }
                    .foregroundStyle(.blue)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.regularMaterial, lineWidth: 1)
        )
    }

    private func editEntry(_ entry: SimpleMoodEntry) {
        selectedEntryForEditing = entry
        showingEditView = true

        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
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

// MARK: - Health Metric Card Component

struct HealthMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            VStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    InsightsView()
}