import DotLifeDomain
import DotLifeDS
import SwiftUI

/// Grid view displaying all days of the current year as a dot matrix.
/// Shows current date/time at the top and the dot grid below.
/// The grid dynamically calculates columns, dot size, and spacing to fill the entire screen.
public struct YearGridView: View {
    @ObservedObject var viewModel: YearViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentDate = Date()

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    /// Padding from safe area edges
    private let edgePadding: CGFloat = 16

    /// Height reserved for the date header
    private let dateHeaderHeight: CGFloat = 24

    /// Timer to update the current time
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public init(viewModel: YearViewModel) {
        self.viewModel = viewModel
    }

    /// Layout calculator for consistent grid sizing
    private let layoutCalculator = YearGridLayoutCalculator()

    public var body: some View {
        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            let availableWidth = geometry.size.width - edgePadding * 2
            let availableHeight = geometry.size.height - safeArea.top - safeArea.bottom - edgePadding * 2 - dateHeaderHeight - 8

            let layout = layoutCalculator.calculateLayout(
                availableWidth: availableWidth,
                availableHeight: availableHeight,
                dayCount: max(viewModel.yearDays.count, 365)
            )

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: safeArea.top + edgePadding)

                // Date/time header
                Text(formattedDateTime)
                    .font(tokens.typography.caption)
                    .foregroundStyle(tokens.colors.textSecondary)
                    .frame(height: dateHeaderHeight)
                    .padding(.bottom, 8)

                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.fixed(layout.dotSize), spacing: layout.horizontalSpacing),
                        count: layout.columns
                    ),
                    spacing: layout.verticalSpacing
                ) {
                    ForEach(viewModel.yearDays) { day in
                        YearDotView(day: day, size: layout.dotSize)
                    }
                }
                .padding(.horizontal, edgePadding)

                Spacer()
                    .frame(height: safeArea.bottom + edgePadding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(tokens.colors.appBackground)
        .ignoresSafeArea()
        .task {
            await viewModel.refresh()
        }
        .onReceive(timer) { date in
            currentDate = date
        }
    }

    /// Formatted date and time string
    private var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy • h:mm:ss a"
        return formatter.string(from: currentDate)
    }

}

// MARK: - Preview

#if DEBUG
    struct YearGridView_Previews: PreviewProvider {
        static var previews: some View {
            YearGridView(viewModel: makePreviewViewModel())
                .environmentObject(ThemeManager())
        }

        @MainActor
        static func makePreviewViewModel() -> YearViewModel {
            let viewModel = YearViewModel(repository: MockRepository())

            // Generate sample year data
            var sampleCounts: [Date: Int] = [:]
            let calendar = Calendar.current
            let today = Date()

            // Add some random experience counts for past days
            for dayOffset in -180 ... 0 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: today) {
                    let dayStart = calendar.startOfDay(for: date)
                    // Random count: 0-5, weighted towards 0
                    let random = Int.random(in: 0 ... 10)
                    if random > 5 {
                        sampleCounts[dayStart] = random - 5
                    }
                }
            }

            viewModel.yearDays = YearDay.generateCurrentYear(
                experienceCounts: sampleCounts,
                calendar: calendar
            )

            return viewModel
        }
    }

    private final class MockRepository: ExperienceRepository, @unchecked Sendable {
        func create(_: ExperienceCreateRequest) async throws -> ExperienceRecord {
            fatalError("Not implemented")
        }

        func fetch(_: ExperienceFetchRequest) async throws -> [ExperienceRecord] {
            []
        }

        func fetch(byID _: UUID) async throws -> ExperienceRecord? {
            nil
        }

        func delete(byID _: UUID) async throws {}

        func summaries(for _: [TimeBucket]) async throws -> [TimeBucketSummary] {
            []
        }

        func count(in _: TimeBucket) async throws -> Int {
            0
        }

        func experienceCountsByDay(from _: Date, to _: Date) async throws -> [Date: Int] {
            [:]
        }
    }
#endif
