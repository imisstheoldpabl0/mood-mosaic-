//
//  MoodLogViewModel.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MoodLogViewModel: ObservableObject {
    @Published var intensity: Double = 50.0
    @Published var selectedTags: Set<EmotionTag> = []
    @Published var note: String = ""
    @Published var isLoading: Bool = false
    @Published var showingSaveConfirmation: Bool = false

    private let maxTagSelection = 3
    private let maxNoteLength = 140

    var canSave: Bool {
        intensity > 0
    }

    var noteCharacterCount: Int {
        note.count
    }

    var isNoteTooLong: Bool {
        note.count > maxNoteLength
    }

    func toggleTag(_ tag: EmotionTag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else if selectedTags.count < maxTagSelection {
            selectedTags.insert(tag)
        }
    }

    func handleQuickSituation(_ situation: QuickSituation) {
        // Only set tags and notes based on situation, keep intensity independent
        switch situation {
        case .workStress:
            selectedTags = [.stressed, .tired]
            note = "Work-related stress"
        case .socialTime:
            selectedTags = [.happy, .excited]
            note = "Enjoying social time"
        case .exercise:
            selectedTags = [.focused, .excited]
            note = "Post-workout feeling"
        case .goodNews:
            selectedTags = [.happy, .grateful]
            note = "Received good news"
        case .conflict:
            selectedTags = [.stressed, .sad]
            note = "Had a conflict"
        case .achievement:
            selectedTags = [.happy, .grateful, .excited]
            note = "Personal achievement"
        }

        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

    func saveMoodEntry(dataStore: MoodDataStore) {
        guard canSave else { return }

        isLoading = true

        let tagStrings = Array(selectedTags).map { $0.rawValue }
        let truncatedNote = note.count > maxNoteLength ? String(note.prefix(maxNoteLength)) : note

        let entry = SimpleMoodEntry(
            intensity: intensity,
            tags: tagStrings,
            note: truncatedNote.isEmpty ? nil : truncatedNote,
            source: "manual",
            timestamp: Date()
        )

        dataStore.addMoodEntry(entry)

        resetForm()
        showingSaveConfirmation = true

        // Add success haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)

        // Hide confirmation after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showingSaveConfirmation = false
        }

        isLoading = false
    }

    private func resetForm() {
        intensity = 50.0
        selectedTags.removeAll()
        note = ""
    }
}