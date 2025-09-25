//
//  ProgressRing.swift
//  mood-mosaic-plus
//
//  Created by Pablo on 25/9/25.
//

import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let color: Color
    let size: CGFloat
    let lineWidth: CGFloat
    let showPercentage: Bool

    init(progress: Double, color: Color, size: CGFloat = 40, lineWidth: CGFloat = 4, showPercentage: Bool = true) {
        self.progress = progress
        self.color = color
        self.size = size
        self.lineWidth = lineWidth
        self.showPercentage = showPercentage
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            // Progress circle
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)

            if showPercentage {
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.system(size: size * 0.25, weight: .semibold, design: .rounded))
                    .foregroundStyle(color)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressRing(progress: 0.75, color: .blue)
        ProgressRing(progress: 1.2, color: .green) // Over 100%
        ProgressRing(progress: 0.3, color: .orange)
    }
    .padding()
}