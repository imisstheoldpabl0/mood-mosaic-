//
//  SplashScreenView.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 24/9/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var currentMessageIndex = 0
    @State private var isAnimating = false
    @State private var showContent = false

    private let loadingMessages = [
        "Loading up your feelings...",
        "Preparing your emotional journey...",
        "Setting up your mood sanctuary...",
        "Connecting to your inner world..."
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                // App Icon and Title
                VStack(spacing: 16) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.blue)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)

                    Text("Mood Mosaic+")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text("Scientific Emotion Tracking")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.8), value: showContent)

                // Loading Message
                VStack(spacing: 16) {
                    Text(loadingMessages[currentMessageIndex])
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .animation(.easeInOut(duration: 0.5), value: currentMessageIndex)

                    // Loading dots animation
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(.blue)
                                .frame(width: 8, height: 8)
                                .scaleEffect(isAnimating ? 1.0 : 0.6)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.8).delay(0.3), value: showContent)
            }
        }
        .onAppear {
            showContent = true
            isAnimating = true
            startMessageRotation()
        }
    }

    private func startMessageRotation() {
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentMessageIndex = (currentMessageIndex + 1) % loadingMessages.count
            }
        }
    }
}

#Preview {
    SplashScreenView()
}