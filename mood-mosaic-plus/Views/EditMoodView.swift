//
//  EditMoodView.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import SwiftUI

struct EditMoodView: View {
    @ObservedObject private var dataStore = MoodDataStore.shared
    @Environment(\.dismiss) private var dismiss

    let originalEntry: SimpleMoodEntry

    @State private var intensity: Double
    @State private var selectedTags: Set<EmotionTag>
    @State private var note: String
    @State private var isLoading: Bool = false

    private let maxNoteLength = 140

    init(entry: SimpleMoodEntry) {
        self.originalEntry = entry
        self._intensity = State(initialValue: entry.intensity)
        self._selectedTags = State(initialValue: Set(entry.tags.compactMap { EmotionTag(rawValue: $0) }))
        self._note = State(initialValue: entry.note ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Entry timestamp info
                    entryInfoSection

                    // Mood Intensity Section
                    moodIntensitySection

                    // Emotion Tags Section
                    emotionTagsSection

                    // Notes Section
                    notesSection

                    // Save Button
                    saveButton
                }
                .padding()
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.large)
            .background(.regularMaterial)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Entry Info Section
    private var entryInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Original Entry")
                .font(.headline)
                .foregroundStyle(.primary)

            HStack {
                Text(originalEntry.timestamp.formatted(.dateTime.weekday().month().day().hour().minute()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("Source: \(originalEntry.source)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.regularMaterial, lineWidth: 1)
        )
    }

    // MARK: - Mood Intensity Section
    private var moodIntensitySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("How are you feeling?")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(Int(intensity))")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }

            VStack(spacing: 8) {
                Slider(value: $intensity, in: 0...100, step: 1)
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
                    EditEmotionTagChip(
                        tag: tag,
                        isSelected: selectedTags.contains(tag)
                    ) {
                        toggleTag(tag)
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
            HStack {
                Text("Notes")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(note.count)/\(maxNoteLength)")
                    .font(.caption)
                    .foregroundStyle(note.count > maxNoteLength ? .red : .secondary)
            }

            TextEditor(text: $note)
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
            hideKeyboard()
            saveChanges()
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                }
                Text("Save Changes")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue, in: RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isLoading || hasNoChanges)
        .opacity(hasNoChanges ? 0.6 : 1.0)
        .padding(.horizontal)
    }

    // MARK: - Helper Properties
    private var hasNoChanges: Bool {
        intensity == originalEntry.intensity &&
        selectedTags == Set(originalEntry.tags.compactMap { EmotionTag(rawValue: $0) }) &&
        (note.isEmpty ? nil : note) == originalEntry.note
    }

    // MARK: - Helper Functions
    private func toggleTag(_ tag: EmotionTag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else if selectedTags.count < 3 {
            selectedTags.insert(tag)
        }

        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    private func saveChanges() {
        isLoading = true

        let truncatedNote = note.count > maxNoteLength ? String(note.prefix(maxNoteLength)) : note

        let updatedEntry = SimpleMoodEntry(
            id: originalEntry.id, // Keep the same ID
            intensity: intensity,
            tags: Array(selectedTags).map { $0.rawValue },
            note: truncatedNote.isEmpty ? nil : truncatedNote,
            source: originalEntry.source,
            timestamp: originalEntry.timestamp // Keep original timestamp
        )

        dataStore.updateMoodEntry(updatedEntry)

        // Add success haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)

        // Brief delay to show loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            dismiss()
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Supporting Views

struct EditEmotionTagChip: View {
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

#Preview {
    let sampleEntry = SimpleMoodEntry(
        intensity: 75,
        tags: ["Happy", "Excited"],
        note: "Had a great day at work!",
        source: "manual",
        timestamp: Date()
    )

    EditMoodView(entry: sampleEntry)
}