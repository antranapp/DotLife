import DotLifeDomain
import DotLifeDS
import SwiftUI

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
            BaseDotView(
                size: size,
                fillColor: fillColor(colors: colors),
                fillOpacity: fillOpacity,
                ringColor: ringColor,
                ringWidth: ringWidth,
                glowColor: glowColor(colors: colors),
                isAnimating: isCurrentMoment,
                animationDuration: 2.0,
                breathingMinScale: 1.0,
                breathingMaxScale: 1.0
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(accessibilityIdentifierValue)
    }

    // MARK: - Styling

    /// Determines the fill color based on current moment state.
    /// - Current moment: accent color (brightest, with animation) - matches YearDotView today styling
    /// - Other periods: dotBase color
    private func fillColor(colors: ThemeColors) -> Color {
        if isCurrentMoment {
            return colors.accent
        } else {
            return colors.dotBase
        }
    }

    /// Determines the glow color for breathing animation.
    /// - Current moment: accent color glow - matches YearDotView today styling
    /// - Other periods: dotBase color glow
    private func glowColor(colors: ThemeColors) -> Color {
        if isCurrentMoment {
            return colors.accent
        } else {
            return colors.dotBase
        }
    }

    /// Determines if this period is in the future.
    private var isFuture: Bool {
        summary.bucket.start > Date()
    }

    /// Determines opacity based on period state.
    /// Brightness hierarchy (brightest to faintest) - matches YearDotView:
    /// 1. Current moment: 1.0 (brightest, with breathing animation)
    /// 2. Past periods: 0.3 (uniform - same as yearly overview)
    /// 3. Future periods: 0.04 (very faint to avoid distraction)
    private var fillOpacity: Double {
        // Current moment is always brightest
        if isCurrentMoment {
            return 1.0
        }

        // Future periods are very faint to avoid distraction
        if isFuture {
            return 0.04
        }

        // All past periods have the same opacity (matches YearDotView)
        return 0.3
    }

    private var ringColor: Color {
        // Subtle ring for multi-experience buckets
        if summary.count >= 2 {
            return tokens.colors.dotBase.opacity(0.25)
        } else {
            return .clear
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

    private var accessibilityIdentifierValue: String {
        if isCurrentMoment {
            return "visualize.dot.current"
        }
        return "visualize.dot.\(summary.bucket.bucketID)"
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
