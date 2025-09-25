//
//  NotificationService.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import Foundation
import UserNotifications
import UIKit
import Combine

class NotificationService: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isEnabled: Bool = false

    init() {
        checkAuthorizationStatus()
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )

            await MainActor.run {
                self.isEnabled = granted
                self.checkAuthorizationStatus()
            }

            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
                self.isEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    func scheduleHourlyReminders() {
        guard isEnabled else { return }

        // Remove existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // Schedule notifications for waking hours (8 AM to 10 PM)
        for hour in 8...22 {
            let content = UNMutableNotificationContent()
            content.title = "How are you feeling?"
            content.body = getMoodPrompt()
            content.sound = .default
            content.badge = 1

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: "mood-reminder-\(hour)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error)")
                }
            }
        }
    }

    func scheduleCustomReminder(at date: Date, message: String) {
        guard isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Mood Mosaic+"
        content.body = message
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: date.timeIntervalSinceNow,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func getMoodPrompt() -> String {
        let prompts = [
            "Take a moment to check in with yourself.",
            "How has your mood been over the past hour?",
            "What emotions are you experiencing right now?",
            "Quick mood check - how are you doing?",
            "Time for a gentle mood reflection.",
            "What's your current emotional state?"
        ]

        return prompts.randomElement() ?? "How are you feeling right now?"
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func setQuietHours(start: Date, end: Date) {
        // This would modify the scheduling logic to respect quiet hours
        // For now, we'll keep the simple implementation
        scheduleHourlyReminders()
    }
}