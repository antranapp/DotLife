import Foundation
import Combine
import DotLifeDomain
import os.log

private let logger = Logger(subsystem: "app.antran.dotlife", category: "VisualizeVM")

/// View model for the Visualize screens (Today and Week grids).
@MainActor
public final class VisualizeViewModel: ObservableObject {
    // MARK: - Published State

    /// Summaries for Today view (varies by scale)
    @Published public var todaySummaries: [TimeBucketSummary] = []

    /// Summaries for Week view (varies by scale)
    @Published public var weekSummaries: [TimeBucketSummary] = []

    /// Whether data is loading
    @Published public var isLoading: Bool = false

    /// The currently selected bucket (for detail view)
    @Published public var selectedBucket: TimeBucket?

    /// Whether to show detail view
    @Published public var showingDetail: Bool = false

    /// Zoom controller for Today view
    @Published public var todayZoomController: ZoomController

    /// Zoom controller for Week view
    @Published public var weekZoomController: ZoomController

    /// Callback when pinching state changes (for disabling pagers)
    public var onPinchingChanged: ((Bool) -> Void)?

    /// Callback when detail should be presented (for UIKit-level presentation)
    public var onPresentDetail: ((TimeBucket) -> Void)?

    // MARK: - Dependencies

    public let repository: any DotLifeDomain.ExperienceRepository
    public let bucketingService: TimeBucketingService

    // MARK: - Private State

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        repository: any DotLifeDomain.ExperienceRepository,
        bucketingService: TimeBucketingService = .current
    ) {
        self.repository = repository
        self.bucketingService = bucketingService
        self.todayZoomController = ZoomController(viewType: .today)
        self.weekZoomController = ZoomController(viewType: .week)

        setupZoomObservers()
    }

    // MARK: - Zoom Observation

    private func setupZoomObservers() {
        // Observe Today zoom controller scale changes
        todayZoomController.$currentScale
            .dropFirst()
            .sink { [weak self] _ in
                Task { await self?.refreshTodayData() }
            }
            .store(in: &cancellables)

        // Observe Week zoom controller scale changes
        weekZoomController.$currentScale
            .dropFirst()
            .sink { [weak self] _ in
                Task { await self?.refreshWeekData() }
            }
            .store(in: &cancellables)

        // Observe pinching state for both controllers
        todayZoomController.$isPinching
            .sink { [weak self] isPinching in
                self?.onPinchingChanged?(isPinching)
            }
            .store(in: &cancellables)

        weekZoomController.$isPinching
            .sink { [weak self] isPinching in
                self?.onPinchingChanged?(isPinching)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    /// Refreshes all data for today and this week.
    public func refresh() async {
        logger.debug("refresh() START")
        isLoading = true

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.refreshTodayData() }
            group.addTask { await self.refreshWeekData() }
        }

        isLoading = false
        logger.debug("refresh() END")
    }

    /// Refreshes the Today view data based on current zoom scale.
    public func refreshTodayData() async {
        let now = Date()
        let buckets = bucketingService.buckets(forTodayView: now, at: todayZoomController.currentScale)

        do {
            let summaries = try await repository.summaries(for: buckets)
            await MainActor.run {
                self.todaySummaries = summaries
            }
        } catch {
            // Silently fail, keep existing data
        }
    }

    /// Refreshes the Week view data based on current zoom scale.
    public func refreshWeekData() async {
        let now = Date()
        let buckets = bucketingService.buckets(forWeekView: now, at: weekZoomController.currentScale)

        do {
            let summaries = try await repository.summaries(for: buckets)
            await MainActor.run {
                self.weekSummaries = summaries
            }
        } catch {
            // Silently fail, keep existing data
        }
    }

    /// Selects a bucket to show its detail.
    public func selectBucket(_ bucket: TimeBucket) {
        logger.debug("selectBucket() bucket=\(bucket.type.rawValue)")
        selectedBucket = bucket

        // Use UIKit-level presentation if available (avoids scroll view interference)
        if let onPresentDetail {
            logger.debug("selectBucket() using UIKit presentation callback")
            onPresentDetail(bucket)
        } else {
            // Fallback to SwiftUI presentation
            logger.debug("selectBucket() using SwiftUI presentation fallback")
            showingDetail = true
        }
    }

    /// Closes the detail view.
    public func closeDetail() {
        logger.debug("closeDetail() START - showingDetail=\(self.showingDetail)")
        showingDetail = false
        logger.debug("closeDetail() after showingDetail=false")
        selectedBucket = nil
        logger.debug("closeDetail() after selectedBucket=nil")
        // Refresh data after closing detail (in case items were added)
        Task {
            logger.debug("closeDetail() Task starting refresh")
            await refresh()
            logger.debug("closeDetail() Task completed refresh")
        }
    }

    /// Creates a DetailViewModel for the selected bucket.
    public func makeDetailViewModel() -> DetailViewModel? {
        guard let bucket = selectedBucket else { return nil }
        return DetailViewModel(
            bucket: bucket,
            repository: repository,
            bucketingService: bucketingService
        )
    }
}
