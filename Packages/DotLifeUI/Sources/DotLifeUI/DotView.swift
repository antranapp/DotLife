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
                fillColor: colors.dotBase,
                fillOpacity: fillOpacity,
                ringColor: ringColor,
                ringWidth: ringWidth,
                glowColor: colors.dotBase,
                isAnimating: isCurrentMoment,
                animationDuration: 2.0
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(accessibilityIdentifierValue)
    }

    // MARK: - Styling

    private var fillOpacity: Double {
        if summary.hasMoments {
            // Filled dot: opacity varies by count
            if summary.count >= 3 {
                return 1.0
            } else if summary.count >= 2 {
                return 0.9
            } else {
                return 0.85
            }
        } else {
            // Empty dot: very soft background texture
            return 0.1
        }
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
