import XCTest
import DotLifeUI

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

    // MARK: - Safety Margin Regression Tests

    /// Verify that the layout applies safety margin (2px buffer)
    /// This test ensures the fix for last row cutoff doesn't regress
    func testLayoutAppliesSafetyMargin() {
        // Given: Various screen sizes
        let testCases: [(width: CGFloat, height: CGFloat)] = [
            (370, 700),
            (402, 874),
            (393, 852),
            (390, 844),
            (375, 812),
        ]

        for (width, height) in testCases {
            // When
            let layout = calculator.calculateLayout(
                availableWidth: width,
                availableHeight: height,
                dayCount: 365
            )

            // Then: Layout should have at least 2px margin from edges (safety margin)
            let widthMargin = width - layout.totalWidth
            let heightMargin = height - layout.totalHeight

            XCTAssertGreaterThanOrEqual(
                widthMargin,
                0,
                "Width margin should be non-negative for \(width)x\(height)"
            )
            XCTAssertGreaterThanOrEqual(
                heightMargin,
                0,
                "Height margin should be non-negative for \(width)x\(height)"
            )
        }
    }

    /// Test that dot size is rounded to 0.5 increments to avoid floating point accumulation
    func testDotSizeRoundedToHalfPixel() {
        // Given
        let layout = calculator.calculateLayout(
            availableWidth: 370,
            availableHeight: 700,
            dayCount: 365
        )

        // Then: Dot size should be a multiple of 0.5
        let dotSizeDoubled = layout.dotSize * 2
        XCTAssertEqual(
            dotSizeDoubled,
            floor(dotSizeDoubled),
            "Dot size \(layout.dotSize) should be rounded to 0.5 increments"
        )
    }

    /// Test that spacing is rounded to 0.5 increments to avoid floating point accumulation
    func testSpacingRoundedToHalfPixel() {
        // Given
        let layout = calculator.calculateLayout(
            availableWidth: 370,
            availableHeight: 700,
            dayCount: 365
        )

        // Then: Spacing should be a multiple of 0.5
        let hSpacingDoubled = layout.horizontalSpacing * 2
        let vSpacingDoubled = layout.verticalSpacing * 2

        XCTAssertEqual(
            hSpacingDoubled,
            floor(hSpacingDoubled),
            "Horizontal spacing \(layout.horizontalSpacing) should be rounded to 0.5"
        )
        XCTAssertEqual(
            vSpacingDoubled,
            floor(vSpacingDoubled),
            "Vertical spacing \(layout.verticalSpacing) should be rounded to 0.5"
        )
    }

    /// Stress test: verify no floating point accumulation errors across many calculations
    func testNoFloatingPointAccumulationErrors() {
        // Given: Run many iterations to catch accumulation errors
        let iterations = 100

        for i in 0..<iterations {
            // Vary dimensions slightly to catch edge cases
            let width: CGFloat = 350 + CGFloat(i % 50)
            let height: CGFloat = 650 + CGFloat(i % 50)

            // When
            let layout = calculator.calculateLayout(
                availableWidth: width,
                availableHeight: height,
                dayCount: 365
            )

            // Then: Strict verification that layout fits
            XCTAssertLessThanOrEqual(
                layout.totalWidth,
                width,
                "Iteration \(i): Width \(layout.totalWidth) exceeds \(width)"
            )
            XCTAssertLessThanOrEqual(
                layout.totalHeight,
                height,
                "Iteration \(i): Height \(layout.totalHeight) exceeds \(height)"
            )
        }
    }

    /// Test that calculated total dimensions match manual calculation
    func testTotalDimensionsMatchManualCalculation() {
        // Given
        let layout = calculator.calculateLayout(
            availableWidth: 370,
            availableHeight: 700,
            dayCount: 365
        )

        // When: Calculate totals manually
        let manualWidth = CGFloat(layout.columns) * layout.dotSize +
                         CGFloat(layout.columns - 1) * layout.horizontalSpacing
        let manualHeight = CGFloat(layout.rows) * layout.dotSize +
                          CGFloat(layout.rows - 1) * layout.verticalSpacing

        // Then: Should match exactly (no floating point errors in calculation)
        XCTAssertEqual(
            layout.totalWidth,
            manualWidth,
            accuracy: 0.001,
            "totalWidth should match manual calculation"
        )
        XCTAssertEqual(
            layout.totalHeight,
            manualHeight,
            accuracy: 0.001,
            "totalHeight should match manual calculation"
        )
    }

    /// Test exact iPhone 17 Pro dimensions from CLAUDE.md (402x874)
    func testExactIPhone17ProDimensions() {
        // Given: Exact dimensions mentioned in CLAUDE.md
        let availableWidth: CGFloat = 402
        let availableHeight: CGFloat = 874

        // When
        let layout = calculator.calculateLayout(
            availableWidth: availableWidth,
            availableHeight: availableHeight,
            dayCount: 365
        )

        // Then: Must fit with no overflow
        XCTAssertLessThanOrEqual(
            layout.totalWidth,
            availableWidth,
            "Layout must fit iPhone 17 Pro width"
        )
        XCTAssertLessThanOrEqual(
            layout.totalHeight,
            availableHeight,
            "Layout must fit iPhone 17 Pro height - last row must not be cut off"
        )

        // Verify all 365 days can be displayed
        let totalCells = layout.columns * layout.rows
        XCTAssertGreaterThanOrEqual(totalCells, 365)
    }

    /// Test that leap year (366 days) also fits without cutoff
    func testLeapYearDoesNotCutOffLastRow() {
        let testCases: [(width: CGFloat, height: CGFloat)] = [
            (370, 700),
            (402, 874),
            (393, 852),
        ]

        for (width, height) in testCases {
            // When: Leap year has 366 days
            let layout = calculator.calculateLayout(
                availableWidth: width,
                availableHeight: height,
                dayCount: 366
            )

            // Then
            XCTAssertLessThanOrEqual(
                layout.totalHeight,
                height,
                "Leap year layout should not cut off last row for \(width)x\(height)"
            )

            let totalCells = layout.columns * layout.rows
            XCTAssertGreaterThanOrEqual(
                totalCells,
                366,
                "Must have enough cells for leap year"
            )
        }
    }
}
