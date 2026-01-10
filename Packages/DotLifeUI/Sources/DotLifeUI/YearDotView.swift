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
                glowColor: colors.accent,
                isAnimating: day.isToday,
                animationDuration: 2.0,   // Breathing animation cycle
                breathingMinScale: 1.0,   // Dot stays fixed size
                breathingMaxScale: 1.0    // Same as other dots (no size change)
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

    // MARK: - Styling

    /// Determines the fill color based on day state.
    /// - Today: accent color (brightest, with animation)
    /// - All other days: dotBase color (uniform appearance)
    private func fillColor(colors: ThemeColors) -> Color {
        if day.isToday {
            return colors.accent
        } else {
            return colors.dotBase
        }
    }

    /// Determines opacity based on day state.
    /// Brightness hierarchy (brightest to faintest):
    /// 1. Today: 1.0 (brightest, with breathing animation)
    /// 2. Past days: 0.45 (uniform - experiences indicated by number only)
    /// 3. Future days: 0.04 (very faint to avoid distraction)
    private var fillOpacity: Double {
        // Today is always brightest
        if day.isToday {
            return 1.0
        }

        // Future days are very faint to avoid distraction
        if day.isFuture {
            return 0.04
        }

        // All past days have the same opacity (experiences shown by number)
        return 0.3
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
