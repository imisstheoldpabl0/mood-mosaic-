//
//  MainTabView.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MoodLogView()
                .tabItem {
                    Label("Log", systemImage: "heart.circle.fill")
                }

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                }

            HabitsView()
                .tabItem {
                    Label("Habits", systemImage: "list.bullet.clipboard")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}