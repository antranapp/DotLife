import SwiftUI
import DotLifeDomain
import DotLifeDS

/// Grid view showing the current day at various zoom scales.
public struct TodayGridView: View {
    @ObservedObject private var viewModel: VisualizeViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    public init(viewModel: VisualizeViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    /// Number of columns based on zoom scale
    private var columnCount: Int {
        switch viewModel.todayZoomController.currentScale {
        case .hours: return 6     // 24 hours = 4 rows
        case .days: return 7      // 7 days = 1 row
        case .weeks: return 5     // ~5 weeks in a month
        case .months: return 4    // 12 months = 3 rows
        }
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount)
    }

    /// Dot size based on zoom scale
    private var dotSize: CGFloat {
        switch viewModel.todayZoomController.currentScale {
        case .hours: return 36
        case .days: return 40
        case .weeks: return 44
        case .months: return 48
        }
    }

    public var body: some View {
        let colors = tokens.colors
        let typography = tokens.typography
        let spacing = tokens.spacing

        VStack(spacing: 20) {
            // Header with scale indicator
            VStack(spacing: 4) {
                Text(headerText)
                    .font(typography.title)
                    .foregroundStyle(colors.textSecondary)
                    .accessibilityIdentifier("visualize.today.headerLabel")

                Text(scaleLabel)
                    .font(typography.caption)
                    .foregroundStyle(colors.textSecondary.opacity(0.7))
                    .accessibilityIdentifier("visualize.today.scaleLabel")
            }
            .padding(.top, spacing.xl)

            // Grid with zoom gesture
            if viewModel.todaySummaries.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.todaySummaries) { summary in
                        DotView(
                            summary: summary,
                            size: dotSize,
                            isCurrentMoment: isCurrentMoment(summary.bucket),
                            onTap: { viewModel.selectBucket(summary.bucket) }
                        )
                    }
                }
                .padding(.horizontal, spacing.lg)
                .frame(maxWidth: .infinity)
                .pinchToZoom(controller: viewModel.todayZoomController)
                .accessibilityIdentifier("visualize.today.grid")
            }

            Spacer()

            // Hint
            Text("Swipe down for This Week")
                .font(typography.caption)
                .foregroundStyle(colors.textSecondary.opacity(0.7))
                .padding(.bottom, spacing.xl)
                .accessibilityIdentifier("visualize.today.hint")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(colors.textPrimary)
        .background(colors.appBackground.ignoresSafeArea())
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("visualize.today.screen")
        .onAppear {
            Task {
                await viewModel.refreshTodayData()
            }
        }
        // NOTE: Detail presentation is handled at UIKit level (RootViewController)
        // to avoid scroll view interference when modal dismisses.
        // See VisualizeViewModel.onPresentDetail callback.
    }

    private var headerText: String {
        let formatter = DateFormatter()
        switch viewModel.todayZoomController.currentScale {
        case .hours:
            formatter.dateFormat = "EEEE, MMMM d"
        case .days:
            // Week range
            let bucketingService = TimeBucketingService.current
            let weekStart = bucketingService.startOfWeek(for: Date())
            let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
        case .weeks:
            formatter.dateFormat = "MMMM yyyy"
        case .months:
            formatter.dateFormat = "yyyy"
        }
        return formatter.string(from: Date())
    }

    private var scaleLabel: String {
        viewModel.todayZoomController.currentScale.displayName
    }

    private func isCurrentMoment(_ bucket: TimeBucket) -> Bool {
        let calendar = Calendar.current
        let now = Date()

        switch bucket.type {
        case .hour:
            // Check if this hour bucket contains the current hour
            return calendar.isDate(bucket.start, equalTo: now, toGranularity: .hour)
        case .day:
            return calendar.isDateInToday(bucket.start)
        case .week:
            let bucketingService = TimeBucketingService.current
            let currentWeekStart = bucketingService.startOfWeek(for: now)
            return bucket.start == currentWeekStart
        case .month:
            return calendar.isDate(bucket.start, equalTo: now, toGranularity: .month)
        case .year:
            return calendar.isDate(bucket.start, equalTo: now, toGranularity: .year)
        }
    }

    private var emptyState: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        return VStack(spacing: 12) {
            ProgressView()
                .tint(colors.accent)
                .accessibilityIdentifier("visualize.today.loadingIndicator")
            Text("Loading...")
                .font(typography.caption)
                .foregroundStyle(colors.textSecondary)
                .accessibilityIdentifier("visualize.today.loadingLabel")
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
    }
}
