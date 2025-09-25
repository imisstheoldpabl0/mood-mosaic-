//
//  HabitsView.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import SwiftUI

struct HabitsView: View {
    @StateObject private var viewModel = HabitsViewModel()
    @ObservedObject private var customHabitsStore = CustomHabitsStore.shared
    @State private var showingAlcoholInput = false
    @State private var showingCaffeineInput = false
    @State private var showingExerciseInput = false
    @State private var showingWaterInput = false
    @State private var showingSleepInput = false
    @State private var showingCustomHabits = false

    // Goal setting sheets
    @State private var showingCaffeineGoal = false
    @State private var showingWaterGoal = false
    @State private var showingExerciseGoal = false
    @State private var showingSleepGoal = false
    @State private var showingAlcoholGoal = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Habits Section
                    dailyHabitsSection

                    // Custom Habits Section
                    customHabitsSection

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
        .sheet(isPresented: $showingAlcoholInput) {
            AlcoholInputView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingCaffeineInput) {
            CaffeineInputView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingExerciseInput) {
            ExerciseInputView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingWaterInput) {
            WaterInputView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingSleepInput) {
            SleepInputView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingCustomHabits) {
            CustomHabitsView()
        }
        // Goal setting sheets
        .sheet(isPresented: $showingCaffeineGoal) {
            GoalSettingView(
                title: "Caffeine Goal",
                currentGoal: viewModel.caffeineGoal,
                unit: "mg",
                range: 0...600,
                step: 25
            ) { newGoal in
                viewModel.setCaffeineGoal(newGoal)
            }
        }
        .sheet(isPresented: $showingWaterGoal) {
            GoalSettingView(
                title: "Water Goal",
                currentGoal: viewModel.waterGoal,
                unit: "glasses",
                range: 1...20,
                step: 1
            ) { newGoal in
                viewModel.setWaterGoal(newGoal)
            }
        }
        .sheet(isPresented: $showingExerciseGoal) {
            GoalSettingView(
                title: "Exercise Goal",
                currentGoal: viewModel.exerciseGoal,
                unit: "minutes",
                range: 5...180,
                step: 5
            ) { newGoal in
                viewModel.setExerciseGoal(newGoal)
            }
        }
        .sheet(isPresented: $showingSleepGoal) {
            SleepGoalSettingView(
                currentGoal: viewModel.sleepGoal
            ) { newGoal in
                viewModel.setSleepGoal(newGoal)
            }
        }
        .sheet(isPresented: $showingAlcoholGoal) {
            GoalSettingView(
                title: "Alcohol Limit",
                currentGoal: viewModel.alcoholLimit,
                unit: "units",
                range: 0...10,
                step: 1
            ) { newGoal in
                viewModel.setAlcoholLimit(newGoal)
            }
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
                HabitEntryRowWithProgress(
                    icon: "cup.and.saucer.fill",
                    title: "Caffeine",
                    current: viewModel.caffeineMg,
                    goal: viewModel.caffeineGoal,
                    unit: "mg",
                    progress: viewModel.caffeineProgress,
                    color: .brown,
                    onTap: {
                        showingCaffeineInput = true
                    },
                    onLongPress: {
                        showingCaffeineGoal = true
                    }
                )

                Divider()

                // Exercise
                HabitEntryRowWithProgress(
                    icon: "figure.run",
                    title: "Exercise",
                    current: viewModel.exerciseMinutes,
                    goal: viewModel.exerciseGoal,
                    unit: "min",
                    progress: viewModel.exerciseProgress,
                    color: .green,
                    onTap: {
                        showingExerciseInput = true
                    },
                    onLongPress: {
                        showingExerciseGoal = true
                    }
                )

                Divider()

                // Water
                HabitEntryRowWithProgress(
                    icon: "waterbottle.fill",
                    title: "Water",
                    current: viewModel.waterGlasses,
                    goal: viewModel.waterGoal,
                    unit: "glasses",
                    progress: viewModel.waterProgress,
                    color: .blue,
                    onTap: {
                        showingWaterInput = true
                    },
                    onLongPress: {
                        showingWaterGoal = true
                    }
                )

                Divider()

                // Sleep
                HabitEntryRowWithProgress(
                    icon: "bed.double.fill",
                    title: "Sleep",
                    current: Int(viewModel.sleepHours * 10), // Convert to tenths for display
                    goal: Int(viewModel.sleepGoal * 10),
                    unit: "hrs",
                    progress: viewModel.sleepProgress,
                    color: .indigo,
                    customDisplay: viewModel.sleepHours > 0 ? String(format: "%.1f/%.1f hrs", viewModel.sleepHours, viewModel.sleepGoal) : "0.0/\(viewModel.sleepGoal) hrs",
                    onTap: {
                        showingSleepInput = true
                    },
                    onLongPress: {
                        showingSleepGoal = true
                    }
                )

                Divider()

                // Alcohol (special case - limit instead of goal)
                HabitEntryRowWithLimit(
                    icon: "wineglass.fill",
                    title: "Alcohol",
                    current: viewModel.alcoholUnits,
                    limit: viewModel.alcoholLimit,
                    unit: "units",
                    color: .purple,
                    isGood: viewModel.alcoholUnits <= viewModel.alcoholLimit
                ) {
                    showingAlcoholInput = true
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

    // MARK: - Custom Habits Section
    private var customHabitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Custom Habits")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    showingCustomHabits = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Manage")
                            .font(.caption)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundStyle(.blue)
                }
            }

            if customHabitsStore.habits.filter({ $0.isActive }).isEmpty {
                VStack(spacing: 8) {
                    Text("No custom habits yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button {
                        showingCustomHabits = true
                    } label: {
                        Text("Add Custom Habit")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.blue, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(customHabitsStore.habits.filter { $0.isActive }.prefix(3)) { habit in
                        HStack {
                            Image(systemName: habit.icon)
                                .foregroundStyle(habit.colorValue)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(habit.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)

                                Text(habit.displayValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button {
                                customHabitsStore.incrementHabit(habit.id)

                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(habit.colorValue)
                            }
                        }
                        .padding(.vertical, 4)

                        if habit.id != customHabitsStore.habits.filter({ $0.isActive }).prefix(3).last?.id {
                            Divider()
                        }
                    }

                    if customHabitsStore.habits.filter({ $0.isActive }).count > 3 {
                        Button {
                            showingCustomHabits = true
                        } label: {
                            HStack {
                                Text("View all (\(customHabitsStore.habits.filter { $0.isActive }.count))")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding(.top, 4)
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
                    color: .brown,
                    action: {
                        viewModel.addCoffee()
                    },
                    longPressAction: {
                        showingCaffeineInput = true
                    }
                )

                QuickAddButton(
                    icon: "figure.run",
                    title: "Workout",
                    subtitle: "30min exercise",
                    color: .green,
                    action: {
                        viewModel.addWorkout()
                    },
                    longPressAction: {
                        showingExerciseInput = true
                    }
                )

                QuickAddButton(
                    icon: "waterbottle.fill",
                    title: "Water",
                    subtitle: "+1 glass",
                    color: .blue,
                    action: {
                        viewModel.addWater()
                    },
                    longPressAction: {
                        showingWaterInput = true
                    }
                )

                QuickAddButton(
                    icon: "bed.double.fill",
                    title: "Good Sleep",
                    subtitle: "8+ hours",
                    color: .indigo,
                    action: {
                        viewModel.addGoodSleep()
                    },
                    longPressAction: {
                        showingSleepInput = true
                    }
                )
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
    let longPressAction: (() -> Void)?

    init(icon: String, title: String, subtitle: String, color: Color, action: @escaping () -> Void, longPressAction: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.action = action
        self.longPressAction = longPressAction
    }

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
        .onLongPressGesture {
            longPressAction?()
        }
    }
}

// MARK: - Input Views

struct AlcoholInputView: View {
    @ObservedObject var viewModel: HabitsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tempAlcoholUnits: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Alcohol Intake")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 8) {
                        Text("\(tempAlcoholUnits) units")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.purple)

                        Stepper("Alcohol units", value: $tempAlcoholUnits, in: 0...20, step: 1)
                            .labelsHidden()
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                Spacer()
            }
            .padding()
            .navigationTitle("Alcohol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.setAlcoholUnits(tempAlcoholUnits)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            tempAlcoholUnits = viewModel.alcoholUnits
        }
    }
}

struct CaffeineInputView: View {
    @ObservedObject var viewModel: HabitsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tempCaffeineMg: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Caffeine Intake")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 8) {
                        Text("\(tempCaffeineMg) mg")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.brown)

                        Stepper("Caffeine amount", value: $tempCaffeineMg, in: 0...600, step: 25)
                            .labelsHidden()
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                Spacer()
            }
            .padding()
            .navigationTitle("Caffeine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.setCaffeineMg(tempCaffeineMg)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            tempCaffeineMg = viewModel.caffeineMg
        }
    }
}

struct ExerciseInputView: View {
    @ObservedObject var viewModel: HabitsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tempExerciseType: String = ""
    @State private var tempExerciseMinutes: Int = 0

    let exerciseTypes = ["Cardio", "Weight Training", "Yoga", "Running", "Walking", "Swimming", "Cycling", "Other"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Exercise")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 12) {
                        Picker("Exercise Type", selection: $tempExerciseType) {
                            Text("Select Type").tag("")
                            ForEach(exerciseTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(.menu)

                        VStack(spacing: 8) {
                            Text("\(tempExerciseMinutes) minutes")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)

                            Stepper("Exercise duration", value: $tempExerciseMinutes, in: 0...300, step: 5)
                                .labelsHidden()
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                Spacer()
            }
            .padding()
            .navigationTitle("Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.setExercise(type: tempExerciseType, minutes: tempExerciseMinutes)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            tempExerciseType = viewModel.exerciseType
            tempExerciseMinutes = viewModel.exerciseMinutes
        }
    }
}

struct WaterInputView: View {
    @ObservedObject var viewModel: HabitsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tempWaterGlasses: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Water Intake")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 8) {
                        Text("\(tempWaterGlasses) glasses")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)

                        Stepper("Water glasses", value: $tempWaterGlasses, in: 0...20, step: 1)
                            .labelsHidden()
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                Spacer()
            }
            .padding()
            .navigationTitle("Water")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.setWaterGlasses(tempWaterGlasses)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            tempWaterGlasses = viewModel.waterGlasses
        }
    }
}

struct SleepInputView: View {
    @ObservedObject var viewModel: HabitsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tempSleepHours: Double = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Sleep Hours")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 8) {
                        Text(String(format: "%.1f hours", tempSleepHours))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.indigo)

                        Slider(value: $tempSleepHours, in: 0...12, step: 0.5) {
                            Text("Sleep hours")
                        } minimumValueLabel: {
                            Text("0h")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } maximumValueLabel: {
                            Text("12h")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .tint(.indigo)
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                Spacer()
            }
            .padding()
            .navigationTitle("Sleep")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.setSleepHours(tempSleepHours)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            tempSleepHours = viewModel.sleepHours
        }
    }
}

// MARK: - Enhanced Habit Entry Components

struct HabitEntryRowWithProgress: View {
    let icon: String
    let title: String
    let current: Int
    let goal: Int
    let unit: String
    let progress: Double
    let color: Color
    let customDisplay: String?
    let action: () -> Void

    init(icon: String, title: String, current: Int, goal: Int, unit: String, progress: Double, color: Color, customDisplay: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.current = current
        self.goal = goal
        self.unit = unit
        self.progress = progress
        self.color = color
        self.customDisplay = customDisplay
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(customDisplay ?? "\(current)/\(goal) \(unit)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 8) {
                    Text(String(format: "%.0f%%", progress * 100))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(progressColor)

                    ProgressRing(
                        progress: progress,
                        color: progressColor,
                        size: 32,
                        lineWidth: 3,
                        showPercentage: false
                    )
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var progressColor: Color {
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.7 {
            return color
        } else {
            return .orange
        }
    }
}

struct HabitEntryRowWithLimit: View {
    let icon: String
    let title: String
    let current: Int
    let limit: Int
    let unit: String
    let color: Color
    let isGood: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text("\(current)/\(limit) \(unit) limit")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 8) {
                    Text(statusText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(statusColor)

                    Image(systemName: isGood ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.title3)
                        .foregroundStyle(statusColor)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var statusText: String {
        if isGood {
            return "Good"
        } else {
            return "Over"
        }
    }

    private var statusColor: Color {
        isGood ? .green : .red
    }
}

#Preview {
    HabitsView()
}