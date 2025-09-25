//
//  ProfileView.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 25/9/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var healthKitService = HealthKitService()
    @State private var notificationsEnabled = true
    @State private var quietHoursStart = Date()
    @State private var quietHoursEnd = Date()
    @State private var hapticFeedbackEnabled = true
    @State private var showingDataExport = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeader

                    // Settings Sections
                    VStack(spacing: 20) {
                        // Health & Privacy Section
                        settingsSection(title: "Health & Privacy") {
                            healthKitRow
                            Divider()
                            notificationSettingsRow
                        }

                        // Preferences Section
                        settingsSection(title: "Preferences") {
                            quietHoursRow
                            Divider()
                            hapticFeedbackRow
                        }

                        // Data Section
                        settingsSection(title: "Your Data") {
                            dataExportRow
                            Divider()
                            dataDeleteRow
                        }

                        // Support Section
                        settingsSection(title: "Support") {
                            supportRow
                            Divider()
                            aboutRow
                        }

                        // App Info
                        settingsSection(title: nil) {
                            versionRow
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .background(.regularMaterial)
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView()
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(.blue.gradient)
                .frame(width: 80, height: 80)
                .overlay {
                    Text("You")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }

            VStack(spacing: 4) {
                Text("Welcome to Mood Mosaic+")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("Keep tracking your wellbeing")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Quick Stats
            HStack(spacing: 20) {
                statItem(title: "Streak", value: "7 days")

                Divider()
                    .frame(height: 30)

                statItem(title: "Entries", value: "42")

                Divider()
                    .frame(height: 30)

                statItem(title: "Score", value: "85%")
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.blue)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func settingsSection<Content: View>(title: String?, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 4)
            }

            VStack(spacing: 8) {
                content()
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.regularMaterial, lineWidth: 1)
            )
        }
    }

    // MARK: - Settings Rows (moved from SettingsView)

    private var healthKitRow: some View {
        HStack {
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text("Apple Health")
                    .font(.body)

                Text(healthKitService.isAuthorized ? "Connected" : "Not Connected")
                    .font(.caption)
                    .foregroundStyle(healthKitService.isAuthorized ? .green : .secondary)
            }

            Spacer()

            if !healthKitService.isAuthorized {
                Button("Connect") {
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
                }
                .font(.subheadline)
                .foregroundStyle(.blue)
            }
        }
    }

    private var notificationSettingsRow: some View {
        NavigationLink {
            NotificationSettingsView(
                notificationsEnabled: $notificationsEnabled,
                quietHoursStart: $quietHoursStart,
                quietHoursEnd: $quietHoursEnd
            )
        } label: {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundStyle(.blue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Notifications")
                        .font(.body)

                    Text(notificationsEnabled ? "Enabled" : "Disabled")
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

    private var quietHoursRow: some View {
        HStack {
            Image(systemName: "moon.fill")
                .foregroundStyle(.indigo)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text("Quiet Hours")
                    .font(.body)

                Text("10:00 PM - 8:00 AM")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("Edit")
                .font(.subheadline)
                .foregroundStyle(.blue)
        }
    }

    private var hapticFeedbackRow: some View {
        Toggle(isOn: $hapticFeedbackEnabled) {
            HStack {
                Image(systemName: "iphone.radiowaves.left.and.right")
                    .foregroundStyle(.orange)
                    .frame(width: 24)

                Text("Haptic Feedback")
                    .font(.body)
            }
        }
    }

    private var dataExportRow: some View {
        Button {
            showingDataExport = true
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.green)
                    .frame(width: 24)

                Text("Export Data")
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var dataDeleteRow: some View {
        Button {
            // Handle data deletion
        } label: {
            HStack {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
                    .frame(width: 24)

                Text("Delete All Data")
                    .font(.body)
                    .foregroundStyle(.red)

                Spacer()
            }
        }
    }

    private var supportRow: some View {
        NavigationLink {
            SupportView()
        } label: {
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(.blue)
                    .frame(width: 24)

                Text("Help & Support")
                    .font(.body)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }

    private var aboutRow: some View {
        NavigationLink {
            AboutView()
        } label: {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(.blue)
                    .frame(width: 24)

                Text("About")
                    .font(.body)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }

    private var versionRow: some View {
        HStack {
            Image(systemName: "app.badge")
                .foregroundStyle(.gray)
                .frame(width: 24)

            Text("Version")
                .font(.body)

            Spacer()

            Text("1.0.0")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Supporting Views (copied from SettingsView)

struct NotificationSettingsView: View {
    @Binding var notificationsEnabled: Bool
    @Binding var quietHoursStart: Date
    @Binding var quietHoursEnd: Date

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                } footer: {
                    Text("Get gentle reminders to log your mood throughout the day.")
                }

                if notificationsEnabled {
                    Section {
                        DatePicker("Start", selection: $quietHoursStart, displayedComponents: .hourAndMinute)
                        DatePicker("End", selection: $quietHoursEnd, displayedComponents: .hourAndMinute)
                    } header: {
                        Text("Quiet Hours")
                    } footer: {
                        Text("No notifications will be sent during these hours.")
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DataExportView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("Export Your Data")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Export all your mood entries, health correlations, and insights to CSV format.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                Button {
                    // Handle export action
                } label: {
                    Text("Export as CSV")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SupportView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("FAQ")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }
            }

            Section {
                HStack {
                    Text("Contact Support")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }

                HStack {
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("Mood Mosaic+")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Scientific emotion tracking with personalized insights. Track your mood, connect with Apple Health, and discover patterns in your wellbeing.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Features:")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Comprehensive mood tracking")
                        Text("• Apple Health integration")
                        Text("• Personalized insights")
                        Text("• Privacy-first design")
                        Text("• On-device processing")
                    }
                    .font(.body)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
}