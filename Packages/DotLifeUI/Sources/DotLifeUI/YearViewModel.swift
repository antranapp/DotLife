import Combine
import DotLifeDomain
import Foundation
import os.log

private let logger = Logger(subsystem: "app.antran.dotlife", category: "YearVM")

/// View model for the Year visualization grid.
@MainActor
public final class YearViewModel: ObservableObject {
    // MARK: - Published State

    /// All days in the current year with their experience counts.
    @Published public var yearDays: [YearDay] = []

    /// Whether data is loading.
    @Published public var isLoading: Bool = false

    // MARK: - Dependencies

    public let repository: any DotLifeDomain.ExperienceRepository

    // MARK: - Private State

    private let calendar: Calendar

    // MARK: - Initialization

    public init(
        repository: any DotLifeDomain.ExperienceRepository,
        calendar: Calendar = .current
    ) {
        self.repository = repository
        self.calendar = calendar
    }

    // MARK: - Actions

    /// Refreshes the year data by fetching experience counts for the current year.
    public func refresh() async {
        logger.debug("refresh() START")
        isLoading = true

        let year = calendar.component(.year, from: Date())

        guard let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31, hour: 23, minute: 59, second: 59))
        else {
            logger.error("refresh() failed to create year boundaries")
            isLoading = false
            return
        }

        do {
            let experienceCounts = try await repository.experienceCountsByDay(from: startOfYear, to: endOfYear)
            let days = YearDay.generateYear(year, experienceCounts: experienceCounts, calendar: calendar)

            await MainActor.run {
                self.yearDays = days
                self.isLoading = false
            }

            logger.debug("refresh() END - loaded \(days.count) days")
        } catch {
            logger.error("refresh() failed: \(error.localizedDescription)")
            // Generate empty year on failure
            let days = YearDay.generateYear(year, experienceCounts: [:], calendar: calendar)
            await MainActor.run {
                self.yearDays = days
                self.isLoading = false
            }
        }
    }
}
