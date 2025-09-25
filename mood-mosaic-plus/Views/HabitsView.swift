//
//  HabitsView.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import SwiftUI

struct HabitsView: View {
    @StateObject private var viewModel = HabitsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Habits Section
                    dailyHabitsSection

                    // Quick Add Section
                    quickAddSection

                    // Today's Summary
                    todaySummarySection
                }
                .padding()
            }
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.large)
            .background(.regularMaterial)
        }
    }

    // MARK: - Daily Habits Section
    private var dailyHabitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Habits")
                .font(.headline)
                .foregroundStyle(.primary)

            VStack(spacing: 12) {
                // Caffeine
                HabitEntryRow(
                    icon: "cup.and.saucer.fill",
                    title: "Caffeine",
                    value: "\(viewModel.caffeineMg) mg",
                    color: .brown
                ) {
                    // Tap action for caffeine entry
                }

                Divider()

                // Exercise
                HabitEntryRow(
                    icon: "figure.run",
                    title: "Exercise",
                    value: viewModel.exerciseType.isEmpty ? "None" : "\(viewModel.exerciseType) - \(viewModel.exerciseMinutes)min",
                    color: .green
                ) {
                    // Tap action for exercise entry
                }

                Divider()

                // Alcohol
                HabitEntryRow(
                    icon: "wineglass.fill",
                    title: "Alcohol",
                    value: "\(viewModel.alcoholUnits) units",
                    color: .purple
                ) {
                    // Tap action for alcohol entry
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

    // MARK: - Quick Add Section
    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Add")
                .font(.headline)
                .foregroundStyle(.primary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickAddButton(
                    icon: "cup.and.saucer.fill",
                    title: "Coffee",
                    subtitle: "+100mg caffeine",
                    color: .brown
                ) {
                    viewModel.addCoffee()
                }

                QuickAddButton(
                    icon: "figure.run",
                    title: "Workout",
                    subtitle: "30min exercise",
                    color: .green
                ) {
                    viewModel.addWorkout()
                }

                QuickAddButton(
                    icon: "waterbottle.fill",
                    title: "Water",
                    subtitle: "Stay hydrated",
                    color: .blue
                ) {
                    viewModel.addWater()
                }

                QuickAddButton(
                    icon: "bed.double.fill",
                    title: "Good Sleep",
                    subtitle: "8+ hours",
                    color: .indigo
                ) {
                    viewModel.addGoodSleep()
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

    // MARK: - Today's Summary
    private var todaySummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Summary")
                .font(.headline)
                .foregroundStyle(.primary)

            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Habits Tracked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.trackedHabitsCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }

                Divider()

                VStack(alignment: .leading) {
                    Text("Health Score")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.healthScore)/100")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(healthScoreColor)
                }

                Spacer()
            }

            if !viewModel.todayNotes.isEmpty {
                Text("Notes: \(viewModel.todayNotes)")
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

    private var healthScoreColor: Color {
        switch viewModel.healthScore {
        case 0..<40: return .red
        case 40..<60: return .orange
        case 60..<80: return .yellow
        default: return .green
        }
    }
}

// MARK: - Supporting Views

struct HabitEntryRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(value)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct QuickAddButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.tertiary, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HabitsView()
}