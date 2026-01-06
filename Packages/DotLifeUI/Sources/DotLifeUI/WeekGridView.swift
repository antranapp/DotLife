import SwiftUI
import DotLifeDomain
import DotLifeDS

/// Grid view showing the current week at various zoom scales.
public struct WeekGridView: View {
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
        switch viewModel.weekZoomController.currentScale {
        case .hours: return 7     // Not used in week view, fallback to days
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
        switch viewModel.weekZoomController.currentScale {
        case .hours: return 40
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
            // Hint
            Text("Swipe up for Today")
                .font(typography.caption)
                .foregroundStyle(colors.textSecondary.opacity(0.7))
                .padding(.top, spacing.xl)
                .accessibilityIdentifier("visualize.week.hint")

            Spacer()

            // Header with scale indicator
            VStack(spacing: 4) {
                Text(headerText)
                    .font(typography.title)
                    .foregroundStyle(colors.textSecondary)
                    .accessibilityIdentifier("visualize.week.headerLabel")

                Text(scaleLabel)
                    .font(typography.caption)
                    .foregroundStyle(colors.textSecondary.opacity(0.7))
                    .accessibilityIdentifier("visualize.week.scaleLabel")
            }

            // Grid with zoom gesture
            if viewModel.weekSummaries.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.weekSummaries) { summary in
                        DotView(
                            summary: summary,
                            size: dotSize,
                            isCurrentMoment: isCurrentPeriod(summary.bucket),
                            onTap: { viewModel.selectBucket(summary.bucket) }
                        )
                    }
                }
                .padding(.horizontal, spacing.xl)
                .frame(maxWidth: .infinity)
                .pinchToZoom(controller: viewModel.weekZoomController)
                .accessibilityIdentifier("visualize.week.grid")
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(colors.textPrimary)
        .background(colors.appBackground.ignoresSafeArea())
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("visualize.week.screen")
        .onAppear {
            Task {
                await viewModel.refreshWeekData()
            }
        }
        // NOTE: Detail presentation is handled by TodayGridView only
        // to avoid duplicate .fullScreenCover conflict when both views
        // share the same VisualizeViewModel.showingDetail binding
    }

    private var headerText: String {
        let bucketingService = TimeBucketingService.current
        let formatter = DateFormatter()

        switch viewModel.weekZoomController.currentScale {
        case .hours, .days:
            let weekStart = bucketingService.startOfWeek(for: Date())
            let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
        case .weeks:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: Date())
        case .months:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: Date())
        }
    }

    private var scaleLabel: String {
        viewModel.weekZoomController.currentScale.displayName
    }

    private func isCurrentPeriod(_ bucket: TimeBucket) -> Bool {
        switch bucket.type {
        case .day:
            return Calendar.current.isDateInToday(bucket.start)
        case .week:
            let bucketingService = TimeBucketingService.current
            let currentWeekStart = bucketingService.startOfWeek(for: Date())
            return bucket.start == currentWeekStart
        case .month:
            let calendar = Calendar.current
            return calendar.isDate(bucket.start, equalTo: Date(), toGranularity: .month)
        default:
            return false
        }
    }

    private var emptyState: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        return VStack(spacing: 12) {
            ProgressView()
                .tint(colors.accent)
                .accessibilityIdentifier("visualize.week.loadingIndicator")
            Text("Loading...")
                .font(typography.caption)
                .foregroundStyle(colors.textSecondary)
                .accessibilityIdentifier("visualize.week.loadingLabel")
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
    }
}
