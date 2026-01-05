import SwiftUI
import DotLifeDomain

/// A single dot in the visualization grid.
/// Appearance varies based on whether the bucket has experiences.
public struct DotView: View {
    let summary: TimeBucketSummary
    let size: CGFloat
    let isCurrentMoment: Bool
    let onTap: () -> Void

    /// Breathing animation state
    @State private var isBreathing = false

    public init(
        summary: TimeBucketSummary,
        size: CGFloat = 32,
        isCurrentMoment: Bool = false,
        onTap: @escaping () -> Void
    ) {
        self.summary = summary
        self.size = size
        self.isCurrentMoment = isCurrentMoment
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            ZStack {
                // Breathing glow effect for current moment
                if isCurrentMoment {
                    Circle()
                        .fill(Color.primary.opacity(0.15))
                        .frame(width: size * 1.6, height: size * 1.6)
                        .scaleEffect(isBreathing ? 1.0 : 0.7)
                        .opacity(isBreathing ? 0.0 : 0.6)
                }

                Circle()
                    .fill(fillColor)
                    .overlay(
                        // Add subtle ring for multi-experience buckets
                        Circle()
                            .strokeBorder(ringColor, lineWidth: ringWidth)
                    )
                    .frame(width: size, height: size)
                    .scaleEffect(isCurrentMoment && isBreathing ? 1.08 : 1.0)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .onAppear {
            if isCurrentMoment {
                startBreathingAnimation()
            }
        }
        .onChange(of: isCurrentMoment) { _, newValue in
            if newValue {
                startBreathingAnimation()
            } else {
                isBreathing = false
            }
        }
    }

    private func startBreathingAnimation() {
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            isBreathing = true
        }
    }

    // MARK: - Styling

    private var fillColor: Color {
        if summary.hasMoments {
            // Filled dot: primary color with slight opacity variation
            return Color.primary.opacity(fillOpacity)
        } else {
            // Empty dot: very soft background texture
            return Color.primary.opacity(0.08)
        }
    }

    private var fillOpacity: Double {
        // Base opacity for filled dots
        // Multi-experience buckets get slightly higher opacity
        if summary.count >= 3 {
            return 0.9
        } else if summary.count >= 2 {
            return 0.75
        } else {
            return 0.6
        }
    }

    private var ringColor: Color {
        // Subtle ring for multi-experience buckets
        if summary.count >= 2 {
            return Color.primary.opacity(0.2)
        } else {
            return Color.clear
        }
    }

    private var ringWidth: CGFloat {
        summary.count >= 2 ? 1.5 : 0
    }

    private var accessibilityLabel: String {
        let label = summary.bucket.displayLabel()
        if summary.hasMoments {
            return "\(label): \(summary.count) experience\(summary.count == 1 ? "" : "s")"
        } else {
            return "\(label): no experiences"
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DotView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 12) {
            // Empty dot
            DotView(
                summary: TimeBucketSummary(
                    bucket: TimeBucket(type: .hour, start: Date()),
                    count: 0
                ),
                onTap: {}
            )

            // Single experience
            DotView(
                summary: TimeBucketSummary(
                    bucket: TimeBucket(type: .hour, start: Date()),
                    count: 1
                ),
                onTap: {}
            )

            // Multiple experiences
            DotView(
                summary: TimeBucketSummary(
                    bucket: TimeBucket(type: .hour, start: Date()),
                    count: 3
                ),
                onTap: {}
            )
        }
        .padding()
    }
}
#endif
