import SwiftUI
import DotLifeDomain

/// Grid view showing the current week at various zoom scales.
public struct WeekGridView: View {
    @ObservedObject private var viewModel: VisualizeViewModel

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
        VStack(spacing: 20) {
            // Hint
            Text("Swipe up for Today")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.top, 20)

            Spacer()

            // Header with scale indicator
            VStack(spacing: 4) {
                Text(headerText)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(scaleLabel)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
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
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .pinchToZoom(controller: viewModel.weekZoomController)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Task {
                await viewModel.refreshWeekData()
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $viewModel.showingDetail) {
            if let detailVM = viewModel.makeDetailViewModel() {
                DetailView(
                    viewModel: detailVM,
                    onDismiss: { viewModel.closeDetail() }
                )
            }
        }
        #else
        .sheet(isPresented: $viewModel.showingDetail) {
            if let detailVM = viewModel.makeDetailViewModel() {
                DetailView(
                    viewModel: detailVM,
                    onDismiss: { viewModel.closeDetail() }
                )
            }
        }
        #endif
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
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
    }
}
