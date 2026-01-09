import XCTest
@testable import DotLifeUI

final class YearGridLayoutCalculatorTests: XCTestCase {
    var calculator: YearGridLayoutCalculator!

    override func setUp() {
        super.setUp()
        calculator = YearGridLayoutCalculator()
    }

    override func tearDown() {
        calculator = nil
        super.tearDown()
    }

    // MARK: - Basic Layout Tests

    func testLayoutFitsWithinAvailableSpace() {
        // Given: Typical iPhone screen dimensions (minus safe areas and padding)
        let availableWidth: CGFloat = 370
        let availableHeight: CGFloat = 700
        let dayCount = 365

        // When
        let layout = calculator.calculateLayout(
            availableWidth: availableWidth,
            availableHeight: availableHeight,
            dayCount: dayCount
        )

        // Then: Layout should fit within available space
        XCTAssertLessThanOrEqual(
            layout.totalWidth,
            availableWidth,
            "Total width \(layout.totalWidth) should not exceed available width \(availableWidth)"
        )
        XCTAssertLessThanOrEqual(
            layout.totalHeight,
            availableHeight,
            "Total height \(layout.totalHeight) should not exceed available height \(availableHeight)"
        )
    }

    func testLayoutFitsWithinAvailableSpaceWithValidation() {
        // Given
        let availableWidth: CGFloat = 370
        let availableHeight: CGFloat = 700
        let dayCount = 365

        // When
        let layout = calculator.calculateLayout(
            availableWidth: availableWidth,
            availableHeight: availableHeight,
            dayCount: dayCount
        )

        // Then
        XCTAssertTrue(
            calculator.validateLayout(layout, fitsIn: availableWidth, availableHeight: availableHeight),
            "Layout should validate as fitting within available space"
        )
    }

    func testLayoutContainsAllDays() {
        // Given
        let dayCount = 365

        // When
        let layout = calculator.calculateLayout(
            availableWidth: 370,
            availableHeight: 700,
            dayCount: dayCount
        )

        // Then: Grid should have enough cells for all days
        let totalCells = layout.columns * layout.rows
        XCTAssertGreaterThanOrEqual(
            totalCells,
            dayCount,
            "Grid should have at least \(dayCount) cells, but has \(totalCells)"
        )
    }

    func testLayoutHasPositiveDotSize() {
        // Given
        let layout = calculator.calculateLayout(
            availableWidth: 370,
            availableHeight: 700,
            dayCount: 365
        )

        // Then
        XCTAssertGreaterThan(layout.dotSize, 0, "Dot size should be positive")
    }

    func testLayoutHasPositiveSpacing() {
        // Given
        let layout = calculator.calculateLayout(
            availableWidth: 370,
            availableHeight: 700,
            dayCount: 365
        )

        // Then
        XCTAssertGreaterThanOrEqual(layout.horizontalSpacing, 0, "Horizontal spacing should be non-negative")
        XCTAssertGreaterThanOrEqual(layout.verticalSpacing, 0, "Vertical spacing should be non-negative")
    }

    // MARK: - Edge Case Tests

    func testLayoutWithZeroWidth() {
        // Given
        let layout = calculator.calculateLayout(
            availableWidth: 0,
            availableHeight: 700,
            dayCount: 365
        )

        // Then: Should return safe default values
        XCTAssertEqual(layout.dotSize, 0, "Dot size should be 0 for zero available width")
    }

    func testLayoutWithZeroHeight() {
        // Given
        let layout = calculator.calculateLayout(
            availableWidth: 370,
            availableHeight: 0,
            dayCount: 365
        )

        // Then: Should return safe default values
        XCTAssertEqual(layout.dotSize, 0, "Dot size should be 0 for zero available height")
    }

    func testLayoutWithZeroDays() {
        // Given
        let layout = calculator.calculateLayout(
            availableWidth: 370,
            availableHeight: 700,
            dayCount: 0
        )

        // Then: Should return safe default values
        XCTAssertEqual(layout.dotSize, 0, "Dot size should be 0 for zero days")
    }

    func testLayoutWithLeapYear() {
        // Given: Leap year has 366 days
        let dayCount = 366
        let availableWidth: CGFloat = 370
        let availableHeight: CGFloat = 700

        // When
        let layout = calculator.calculateLayout(
            availableWidth: availableWidth,
            availableHeight: availableHeight,
            dayCount: dayCount
        )

        // Then: Layout should still fit
        XCTAssertLessThanOrEqual(
            layout.totalWidth,
            availableWidth,
            "Leap year layout should fit within available width"
        )
        XCTAssertLessThanOrEqual(
            layout.totalHeight,
            availableHeight,
            "Leap year layout should fit within available height"
        )

        let totalCells = layout.columns * layout.rows
        XCTAssertGreaterThanOrEqual(totalCells, dayCount)
    }

    // MARK: - Different Screen Size Tests

    func testLayoutFitsOnSmallScreen() {
        // Given: Small iPhone SE-like dimensions
        let availableWidth: CGFloat = 300
        let availableHeight: CGFloat = 500

        // When
        let layout = calculator.calculateLayout(
            availableWidth: availableWidth,
            availableHeight: availableHeight,
            dayCount: 365
        )

        // Then
        XCTAssertLessThanOrEqual(layout.totalWidth, availableWidth)
        XCTAssertLessThanOrEqual(layout.totalHeight, availableHeight)
        XCTAssertTrue(calculator.validateLayout(layout, fitsIn: availableWidth, availableHeight: availableHeight))
    }

    func testLayoutFitsOnLargeScreen() {
        // Given: Large iPad-like dimensions
        let availableWidth: CGFloat = 800
        let availableHeight: CGFloat = 1000

        // When
        let layout = calculator.calculateLayout(
            availableWidth: availableWidth,
            availableHeight: availableHeight,
            dayCount: 365
        )

        // Then
        XCTAssertLessThanOrEqual(layout.totalWidth, availableWidth)
        XCTAssertLessThanOrEqual(layout.totalHeight, availableHeight)
        XCTAssertTrue(calculator.validateLayout(layout, fitsIn: availableWidth, availableHeight: availableHeight))
    }

    func testLayoutFitsOnWideScreen() {
        // Given: Landscape orientation
        let availableWidth: CGFloat = 700
        let availableHeight: CGFloat = 350

        // When
        let layout = calculator.calculateLayout(
            availableWidth: availableWidth,
            availableHeight: availableHeight,
            dayCount: 365
        )

        // Then
        XCTAssertLessThanOrEqual(layout.totalWidth, availableWidth)
        XCTAssertLessThanOrEqual(layout.totalHeight, availableHeight)
        XCTAssertTrue(calculator.validateLayout(layout, fitsIn: availableWidth, availableHeight: availableHeight))
    }

    // MARK: - Column Range Tests

    func testColumnsWithinRange() {
        // Given
        let layout = calculator.calculateLayout(
            availableWidth: 370,
            availableHeight: 700,
            dayCount: 365
        )

        // Then: Columns should be within default range (10-20)
        XCTAssertGreaterThanOrEqual(layout.columns, 10, "Columns should be at least 10")
        XCTAssertLessThanOrEqual(layout.columns, 20, "Columns should be at most 20")
    }

    func testCustomColumnRange() {
        // Given
        let customCalculator = YearGridLayoutCalculator(
            spacingRatio: 0.4,
            minColumns: 5,
            maxColumns: 30
        )

        // When: Wide screen should want more columns
        let layout = customCalculator.calculateLayout(
            availableWidth: 1000,
            availableHeight: 300,
            dayCount: 365
        )

        // Then: Should respect custom range
        XCTAssertGreaterThanOrEqual(layout.columns, 5)
        XCTAssertLessThanOrEqual(layout.columns, 30)
    }

    // MARK: - Validation Tests

    func testValidateLayoutThatFits() {
        // Given
        let layout = YearGridLayout(
            columns: 10,
            rows: 37,
            dotSize: 10,
            horizontalSpacing: 4,
            verticalSpacing: 4
        )

        // Then: totalWidth = 10*10 + 9*4 = 136, totalHeight = 37*10 + 36*4 = 514
        XCTAssertTrue(calculator.validateLayout(layout, fitsIn: 150, availableHeight: 520))
    }

    func testValidateLayoutThatDoesNotFitWidth() {
        // Given
        let layout = YearGridLayout(
            columns: 10,
            rows: 37,
            dotSize: 10,
            horizontalSpacing: 4,
            verticalSpacing: 4
        )

        // Then: Width is 136, should not fit in 100
        XCTAssertFalse(calculator.validateLayout(layout, fitsIn: 100, availableHeight: 600))
    }

    func testValidateLayoutThatDoesNotFitHeight() {
        // Given
        let layout = YearGridLayout(
            columns: 10,
            rows: 37,
            dotSize: 10,
            horizontalSpacing: 4,
            verticalSpacing: 4
        )

        // Then: Height is 514, should not fit in 400
        XCTAssertFalse(calculator.validateLayout(layout, fitsIn: 200, availableHeight: 400))
    }

    // MARK: - Regression Tests

    /// Test that addresses the original bug: last dot being cut off
    func testLayoutLastDotNotCutOff() {
        // Given: Dimensions that previously caused the last dot to be cut off
        let testCases: [(width: CGFloat, height: CGFloat)] = [
            (370, 700),   // iPhone 15 Pro (portrait)
            (402, 874),   // iPhone 17 Pro (portrait) - from CLAUDE.md
            (300, 500),   // Small screen
            (350, 650),   // Medium screen
            (393, 852),   // iPhone 14 Pro
        ]

        for (width, height) in testCases {
            // When
            let layout = calculator.calculateLayout(
                availableWidth: width,
                availableHeight: height,
                dayCount: 365
            )

            // Then: Verify with strict tolerance
            let widthFits = layout.totalWidth <= width + 0.01
            let heightFits = layout.totalHeight <= height + 0.01

            XCTAssertTrue(
                widthFits,
                "Width overflow for screen \(width)x\(height): \(layout.totalWidth) > \(width)"
            )
            XCTAssertTrue(
                heightFits,
                "Height overflow for screen \(width)x\(height): \(layout.totalHeight) > \(height)"
            )
        }
    }

    /// Test that the layout uses space efficiently
    func testLayoutUsesSpaceEfficiently() {
        // Given
        let availableWidth: CGFloat = 370
        let availableHeight: CGFloat = 700

        // When
        let layout = calculator.calculateLayout(
            availableWidth: availableWidth,
            availableHeight: availableHeight,
            dayCount: 365
        )

        // Then: At least one dimension should use most of the available space (within 20%)
        let widthUsage = layout.totalWidth / availableWidth
        let heightUsage = layout.totalHeight / availableHeight

        let maxUsage = max(widthUsage, heightUsage)
        XCTAssertGreaterThan(
            maxUsage,
            0.8,
            "Layout should use at least 80% of one dimension, but max usage is \(maxUsage * 100)%"
        )
    }
}
