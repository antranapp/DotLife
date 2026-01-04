import SwiftUI
import DotLifeDomain

/// Grid view showing the current day at various zoom scales.
public struct TodayGridView: View {
    @ObservedObject private var viewModel: VisualizeViewModel

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
        VStack(spacing: 20) {
            // Header with scale indicator
            VStack(spacing: 4) {
                Text(headerText)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(scaleLabel)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, 20)

            // Grid with zoom gesture
            if viewModel.todaySummaries.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.todaySummaries) { summary in
                        VStack(spacing: 4) {
                            DotView(
                                summary: summary,
                                size: dotSize,
                                onTap: { viewModel.selectBucket(summary.bucket) }
                            )

                            Text(bucketLabel(for: summary.bucket))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .pinchToZoom(controller: viewModel.todayZoomController)
            }

            Spacer()

            // Hint
            Text("Swipe down for This Week")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Task {
                await viewModel.refreshTodayData()
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

    private func bucketLabel(for bucket: TimeBucket) -> String {
        bucket.displayLabel()
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
    }
}
