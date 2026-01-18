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
                animationDuration: DotStyling.breathingDuration,
                breathingMinScale: 1.0,
                breathingMaxScale: 1.0
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(accessibilityIdentifierValue)
    }

    // MARK: - Styling (uses centralized DotStyling configuration)

    private func fillColor(colors: ThemeColors) -> Color {
        DotStyling.fillColor(isCurrent: isCurrentMoment, colors: colors)
    }

    private func glowColor(colors: ThemeColors) -> Color {
        DotStyling.glowColor(isCurrent: isCurrentMoment, colors: colors)
    }

    private var isFuture: Bool {
        summary.bucket.start > Date()
    }

    private var fillOpacity: Double {
        DotStyling.opacity(isCurrent: isCurrentMoment, isFuture: isFuture)
    }

    private var ringColor: Color {
        summary.count >= 2 ? tokens.colors.dotBase.opacity(DotStyling.ringOpacity) : .clear
    }

    private var ringWidth: CGFloat {
        summary.count >= 2 ? DotStyling.ringWidth : 0
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
