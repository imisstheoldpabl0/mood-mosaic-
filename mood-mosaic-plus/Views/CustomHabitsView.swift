//
//  CustomHabitsView.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import SwiftUI
import Combine

struct CustomHabitsView: View {
    @ObservedObject private var customHabitsStore = CustomHabitsStore.shared
    @State private var showingAddHabit = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(customHabitsStore.habits.filter { $0.isActive }) { habit in
                        CustomHabitCard(habit: habit)
                    }

                    if customHabitsStore.habits.filter({ $0.isActive }).isEmpty {
                        emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle("Custom Habits")
            .navigationBarTitleDisplayMode(.large)
            .background(.regularMaterial)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddCustomHabitView()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Custom Habits")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Create your own habits to track and build healthy routines.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                showingAddHabit = true
            } label: {
                Text("Add Your First Habit")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding()
                    .background(.blue, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct CustomHabitCard: View {
    @ObservedObject private var customHabitsStore = CustomHabitsStore.shared
    let habit: CustomHabit
    @State private var showingEditSheet = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: habit.icon)
                    .font(.title2)
                    .foregroundStyle(habit.colorValue)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(habit.displayValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.0f%%", habit.progress * 100))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(habit.colorValue)

                    Button {
                        customHabitsStore.incrementHabit(habit.id)

                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(habit.colorValue)
                    }
                }
            }

            // Progress bar
            ProgressView(value: habit.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: habit.colorValue))
                .scaleEffect(y: 2)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.regularMaterial, lineWidth: 1)
        )
        .onTapGesture {
            showingEditSheet = true
        }
        .sheet(isPresented: $showingEditSheet) {
            EditCustomHabitView(habit: habit)
        }
    }
}

struct AddCustomHabitView: View {
    @ObservedObject private var customHabitsStore = CustomHabitsStore.shared
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "blue"
    @State private var unit = ""
    @State private var targetValue: Double = 1

    private let availableIcons = [
        "star.fill", "heart.fill", "book.fill", "figure.walk", "brain.head.profile",
        "leaf.fill", "drop.fill", "flame.fill", "moon.fill", "sun.max.fill",
        "music.note", "camera.fill", "paintbrush.fill", "gamecontroller.fill", "phone.fill"
    ]

    private let availableColors = [
        "blue", "red", "green", "orange", "purple", "pink", "yellow", "brown", "cyan", "mint", "indigo"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Habit name", text: $name)

                    TextField("Unit (e.g., mins, pages, times)", text: $unit)

                    HStack {
                        Text("Goal")
                        Spacer()
                        Stepper("\(Int(targetValue))", value: $targetValue, in: 1...100, step: 1)
                    }
                }

                Section("Appearance") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
                            .font(.headline)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundStyle(selectedIcon == icon ? .white : .primary)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            selectedIcon == icon ? .blue : .clear,
                                            in: RoundedRectangle(cornerRadius: 8)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.tertiary, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.headline)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(availableColors, id: \.self) { color in
                                Button {
                                    selectedColor = color
                                } label: {
                                    Circle()
                                        .fill(colorForString(color))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(.white, lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(.tertiary, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let habit = CustomHabit(
                            name: name,
                            icon: selectedIcon,
                            color: selectedColor,
                            unit: unit,
                            targetValue: targetValue
                        )
                        customHabitsStore.addHabit(habit)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func colorForString(_ colorString: String) -> Color {
        switch colorString {
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

struct EditCustomHabitView: View {
    @ObservedObject private var customHabitsStore = CustomHabitsStore.shared
    @Environment(\.dismiss) private var dismiss

    let habit: CustomHabit
    @State private var tempCurrentValue: Double = 0
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: habit.icon)
                        .font(.system(size: 60))
                        .foregroundStyle(habit.colorValue)

                    Text(habit.name)
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 8) {
                        if habit.unit.isEmpty {
                            Text("\(Int(tempCurrentValue))")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(habit.colorValue)
                        } else {
                            Text("\(Int(tempCurrentValue)) \(habit.unit)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(habit.colorValue)
                        }

                        Stepper("Value", value: $tempCurrentValue, in: 0...1000, step: 1)
                            .labelsHidden()
                    }

                    Text("Goal: \(Int(habit.targetValue)) \(habit.unit)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ProgressView(value: min(tempCurrentValue / habit.targetValue, 1.0))
                        .progressViewStyle(LinearProgressViewStyle(tint: habit.colorValue))
                        .scaleEffect(y: 2)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                Button {
                    showingDeleteAlert = true
                } label: {
                    Text("Delete Habit")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red, in: RoundedRectangle(cornerRadius: 12))
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        var updatedHabit = habit
                        updatedHabit.currentValue = tempCurrentValue
                        customHabitsStore.updateHabit(updatedHabit)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            tempCurrentValue = habit.currentValue
        }
        .alert("Delete Habit", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                customHabitsStore.deleteHabit(habit)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this habit? This action cannot be undone.")
        }
    }
}

#Preview {
    CustomHabitsView()
}