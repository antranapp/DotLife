import SwiftUI
import DotLifeDomain
import DotLifeDS

/// A single dot in the visualization grid.
/// Appearance varies based on whether the bucket has experiences.
public struct DotView: View {
    let summary: TimeBucketSummary
    let size: CGFloat
    let isCurrentMoment: Bool
    let onTap: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

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
        let colors = tokens.colors

        Button(action: onTap) {
            ZStack {
                // Breathing glow effect for current moment
                if isCurrentMoment {
                    Circle()
                        .fill(colors.dotBase.opacity(0.15))
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
            return tokens.colors.dotBase.opacity(fillOpacity)
        } else {
            // Empty dot: very soft background texture
            return tokens.colors.dotBase.opacity(0.1)
        }
    }

    private var fillOpacity: Double {
        // Base opacity for filled dots
        // Multi-experience buckets get slightly higher opacity
        if summary.count >= 3 {
            return 1.0
        } else if summary.count >= 2 {
            return 0.9
        } else {
            return 0.85
        }
    }

    private var ringColor: Color {
        // Subtle ring for multi-experience buckets
        if summary.count >= 2 {
            return tokens.colors.dotBase.opacity(0.25)
        } else {
            return tokens.colors.dotBase.opacity(0)
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
        .environmentObject(ThemeManager())
    }
}
#endif
