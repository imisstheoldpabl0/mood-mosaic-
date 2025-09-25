//
//  MoodLogView.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import SwiftUI

struct MoodLogView: View {
    @StateObject private var viewModel = MoodLogViewModel()
    @ObservedObject private var dataStore = MoodDataStore.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Mood Intensity Section
                    moodIntensitySection

                    // Emotion Tags Section
                    emotionTagsSection

                    // Quick Situational Buttons
                    quickSituationalSection

                    // Notes Section
                    notesSection

                    // Save Button
                    saveButton
                }
                .padding()
            }
            .navigationTitle("Log Your Mood")
            .navigationBarTitleDisplayMode(.large)
            .background(.regularMaterial)
        }
    }

    // MARK: - Mood Intensity Section
    private var moodIntensitySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("How are you feeling?")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(Int(viewModel.intensity))")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }

            // Custom Liquid Glass Slider
            VStack(spacing: 8) {
                Slider(value: $viewModel.intensity, in: 0...100, step: 1)
                    .tint(.blue)
                    .background(.regularMaterial, in: Capsule())

                HStack {
                    Text("😔")
                        .font(.title2)
                    Spacer()
                    Text("😐")
                        .font(.title2)
                    Spacer()
                    Text("😊")
                        .font(.title2)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.regularMaterial, lineWidth: 1)
        )
    }

    // MARK: - Emotion Tags Section
    private var emotionTagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What emotions are you experiencing?")
                .font(.headline)
                .foregroundStyle(.primary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(EmotionTag.allCases, id: \.self) { tag in
                    EmotionTagChip(
                        tag: tag,
                        isSelected: viewModel.selectedTags.contains(tag)
                    ) {
                        viewModel.toggleTag(tag)
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

    // MARK: - Quick Situational Section
    private var quickSituationalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Log")
                .font(.headline)
                .foregroundStyle(.primary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(QuickSituation.allCases, id: \.self) { situation in
                    QuickSituationButton(situation: situation) {
                        viewModel.handleQuickSituation(situation)
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

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes (optional)")
                .font(.headline)
                .foregroundStyle(.primary)

            TextEditor(text: $viewModel.note)
                .frame(minHeight: 80)
                .padding(8)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.tertiary, lineWidth: 1)
                )
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.regularMaterial, lineWidth: 1)
        )
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            // Dismiss keyboard first
            hideKeyboard()
            viewModel.saveMoodEntry(dataStore: dataStore)
        } label: {
            Text("Save Mood Entry")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue, in: RoundedRectangle(cornerRadius: 12))
        }
        .disabled(viewModel.intensity == 0)
        .padding(.horizontal)
    }

    // Helper function to hide keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Supporting Views

struct EmotionTagChip: View {
    let tag: EmotionTag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(tag.emoji)
                Text(tag.name)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule().fill(.blue)
                } else {
                    Capsule().fill(.regularMaterial)
                }
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .overlay(
                Capsule()
                    .stroke(.tertiary, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct QuickSituationButton: View {
    let situation: QuickSituation
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(situation.emoji)
                    .font(.title2)
                Text(situation.name)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.tertiary, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
    }
}

// MARK: - Enums

enum EmotionTag: String, CaseIterable {
    case happy = "Happy"
    case sad = "Sad"
    case anxious = "Anxious"
    case calm = "Calm"
    case excited = "Excited"
    case tired = "Tired"
    case focused = "Focused"
    case stressed = "Stressed"
    case grateful = "Grateful"

    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .anxious: return "😰"
        case .calm: return "😌"
        case .excited: return "🤩"
        case .tired: return "😴"
        case .focused: return "🎯"
        case .stressed: return "😤"
        case .grateful: return "🙏"
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum QuickSituation: String, CaseIterable {
    case workStress = "Work Stress"
    case socialTime = "Social Time"
    case exercise = "Exercise"
    case goodNews = "Good News"
    case conflict = "Conflict"
    case achievement = "Achievement"

    var emoji: String {
        switch self {
        case .workStress: return "💼"
        case .socialTime: return "👥"
        case .exercise: return "🏃‍♂️"
        case .goodNews: return "📰"
        case .conflict: return "⚡"
        case .achievement: return "🎉"
        }
    }

    var name: String {
        return self.rawValue
    }
}

#Preview {
    MoodLogView()
}