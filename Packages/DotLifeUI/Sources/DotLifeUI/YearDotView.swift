import DotLifeDomain
import DotLifeDS
import SwiftUI

/// A single dot in the year visualization grid.
/// Specialized for displaying year day states: empty, filled, future, and today.
public struct YearDotView: View {
    let day: YearDay
    let size: CGFloat

    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    public init(day: YearDay, size: CGFloat) {
        self.day = day
        self.size = size
    }

    public var body: some View {
        let colors = tokens.colors

        ZStack {
            BaseDotView(
                size: size,
                fillColor: fillColor(colors: colors),
                fillOpacity: fillOpacity,
                ringColor: .clear,
                ringWidth: 0,
                glowColor: DotStyling.glowColor(isCurrent: day.isToday, colors: colors),
                isAnimating: day.isToday,
                animationDuration: DotStyling.breathingDuration,
                breathingMinScale: 1.0,
                breathingMaxScale: 1.0
            )

            // Show experience count for days with experiences
            if day.hasExperiences {
                Text("\(day.experienceCount)")
                    .font(.system(size: size * 0.5, weight: .bold, design: .monospaced))
                    .foregroundStyle(day.isToday ? colors.appBackground : colors.accent)
                    .minimumScaleFactor(0.5)
            }
        }
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Styling (uses centralized DotStyling configuration)

    private func fillColor(colors: ThemeColors) -> Color {
        DotStyling.fillColor(isCurrent: day.isToday, colors: colors)
    }

    private var fillOpacity: Double {
        DotStyling.opacity(isCurrent: day.isToday, isFuture: day.isFuture)
    }

    private var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: day.date)

        if day.isToday {
            if day.hasExperiences {
                return "Today, \(dateString): \(day.experienceCount) experience\(day.experienceCount == 1 ? "" : "s")"
            } else {
                return "Today, \(dateString): no experiences"
            }
        } else if day.isFuture {
            return "\(dateString): future"
        } else if day.hasExperiences {
            return "\(dateString): \(day.experienceCount) experience\(day.experienceCount == 1 ? "" : "s")"
        } else {
            return "\(dateString): no experiences"
        }
    }
}

// MARK: - Preview

#if DEBUG
    struct YearDotView_Previews: PreviewProvider {
        static var previews: some View {
            HStack(spacing: 8) {
                // Empty past day
                YearDotView(
                    day: YearDay(
                        date: Date().addingTimeInterval(-86400 * 10),
                        experienceCount: 0,
                        isToday: false,
                        isFuture: false
                    ),
                    size: 16
                )

                // Day with 1 experience
                YearDotView(
                    day: YearDay(
                        date: Date().addingTimeInterval(-86400 * 5),
                        experienceCount: 1,
                        isToday: false,
                        isFuture: false
                    ),
                    size: 16
                )

                // Day with many experiences
                YearDotView(
                    day: YearDay(
                        date: Date().addingTimeInterval(-86400 * 2),
                        experienceCount: 5,
                        isToday: false,
                        isFuture: false
                    ),
                    size: 16
                )

                // Today
                YearDotView(
                    day: YearDay(
                        date: Date(),
                        experienceCount: 2,
                        isToday: true,
                        isFuture: false
                    ),
                    size: 16
                )

                // Future day
                YearDotView(
                    day: YearDay(
                        date: Date().addingTimeInterval(86400 * 10),
                        experienceCount: 0,
                        isToday: false,
                        isFuture: true
                    ),
                    size: 16
                )
            }
            .padding()
            .environmentObject(ThemeManager())
        }
    }
#endif
