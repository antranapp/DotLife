import DotLifeDS
import SwiftUI

/// Centralized configuration for dot styling across all visualization views.
/// This ensures consistent appearance between DotView (time buckets) and YearDotView (year grid).
public enum DotStyling {
    // MARK: - Opacity Configuration

    /// Opacity for the current moment/today (brightest, with breathing animation)
    public static let currentOpacity: Double = 1.0

    /// Opacity for past periods (uniform appearance)
    public static let pastOpacity: Double = 0.3

    /// Opacity for future periods (visible but subdued)
    public static let futureOpacity: Double = 0.2

    // MARK: - Ring Configuration (for multi-experience dots)

    /// Ring opacity for dots with multiple experiences
    public static let ringOpacity: Double = 0.25

    /// Ring width for dots with multiple experiences
    public static let ringWidth: CGFloat = 1.5

    // MARK: - Animation Configuration

    /// Duration of the breathing animation cycle
    public static let breathingDuration: Double = 2.0

    // MARK: - Helper Methods

    /// Determines the fill color based on whether this is the current moment/today.
    /// - Parameters:
    ///   - isCurrent: Whether this is the current moment (today for year view, current hour/day/etc for time buckets)
    ///   - colors: Theme colors to use
    /// - Returns: The appropriate fill color
    public static func fillColor(isCurrent: Bool, colors: ThemeColors) -> Color {
        isCurrent ? colors.accent : colors.dotBase
    }

    /// Determines the glow color for breathing animation.
    /// - Parameters:
    ///   - isCurrent: Whether this is the current moment
    ///   - colors: Theme colors to use
    /// - Returns: The appropriate glow color
    public static func glowColor(isCurrent: Bool, colors: ThemeColors) -> Color {
        isCurrent ? colors.accent : colors.dotBase
    }

    /// Determines opacity based on time state.
    /// Brightness hierarchy (brightest to faintest):
    /// 1. Current: 1.0 (brightest, with breathing animation)
    /// 2. Past: 0.3 (uniform appearance)
    /// 3. Future: 0.2 (visible but subdued)
    /// - Parameters:
    ///   - isCurrent: Whether this is the current moment
    ///   - isFuture: Whether this period is in the future
    /// - Returns: The appropriate opacity value
    public static func opacity(isCurrent: Bool, isFuture: Bool) -> Double {
        if isCurrent {
            return currentOpacity
        }
        if isFuture {
            return futureOpacity
        }
        return pastOpacity
    }
}
