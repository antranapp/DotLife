import Foundation

/// Layout parameters for the year grid
public struct YearGridLayout: Equatable {
    public let columns: Int
    public let rows: Int
    public let dotSize: CGFloat
    public let horizontalSpacing: CGFloat
    public let verticalSpacing: CGFloat

    /// Total width used by the grid (dots + spacing)
    public var totalWidth: CGFloat {
        CGFloat(columns) * dotSize + CGFloat(columns - 1) * horizontalSpacing
    }

    /// Total height used by the grid (dots + spacing)
    public var totalHeight: CGFloat {
        CGFloat(rows) * dotSize + CGFloat(rows - 1) * verticalSpacing
    }

    public init(
        columns: Int,
        rows: Int,
        dotSize: CGFloat,
        horizontalSpacing: CGFloat,
        verticalSpacing: CGFloat
    ) {
        self.columns = columns
        self.rows = rows
        self.dotSize = dotSize
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }
}

/// Calculator for year grid layout that ensures all dots fit within available space
public struct YearGridLayoutCalculator {
    /// Spacing ratio relative to dot size (spacing = dotSize * spacingRatio)
    public let spacingRatio: CGFloat

    /// Minimum number of columns
    public let minColumns: Int

    /// Maximum number of columns
    public let maxColumns: Int

    public init(
        spacingRatio: CGFloat = 0.4,
        minColumns: Int = 10,
        maxColumns: Int = 20
    ) {
        self.spacingRatio = spacingRatio
        self.minColumns = minColumns
        self.maxColumns = maxColumns
    }

    /// Calculates optimal grid layout to fit within the available space
    /// - Parameters:
    ///   - availableWidth: Available width for the grid
    ///   - availableHeight: Available height for the grid
    ///   - dayCount: Number of days to display
    /// - Returns: Grid layout that fits all dots within the available space
    public func calculateLayout(
        availableWidth: CGFloat,
        availableHeight: CGFloat,
        dayCount: Int
    ) -> YearGridLayout {
        guard availableWidth > 0, availableHeight > 0, dayCount > 0 else {
            return YearGridLayout(
                columns: 1,
                rows: 1,
                dotSize: 0,
                horizontalSpacing: 0,
                verticalSpacing: 0
            )
        }

        // Calculate optimal columns based on aspect ratio
        let aspectRatio = availableHeight / availableWidth

        // For dayCount items arranged in C columns and R rows:
        // R = ceil(dayCount / C)
        // We want R/C ≈ aspectRatio
        // C ≈ sqrt(dayCount / aspectRatio)
        let idealColumns = sqrt(Double(dayCount) / aspectRatio)
        let columns = max(minColumns, min(maxColumns, Int(round(idealColumns))))
        let rows = Int(ceil(Double(dayCount) / Double(columns)))

        // Calculate dot size that fits within available space
        // Total width = columns * dotSize + (columns - 1) * spacing
        // Total height = rows * dotSize + (rows - 1) * spacing
        // where spacing = dotSize * spacingRatio

        // Solving for dotSize from width:
        // availableWidth = columns * dotSize + (columns - 1) * dotSize * spacingRatio
        // availableWidth = dotSize * (columns + (columns - 1) * spacingRatio)
        // dotSize = availableWidth / (columns + (columns - 1) * spacingRatio)

        let horizontalDivisor = CGFloat(columns) + CGFloat(columns - 1) * spacingRatio
        let verticalDivisor = CGFloat(rows) + CGFloat(rows - 1) * spacingRatio

        let dotSizeFromWidth = availableWidth / horizontalDivisor
        let dotSizeFromHeight = availableHeight / verticalDivisor

        // Use the smaller dot size to ensure everything fits
        // Apply a small safety margin (0.99) to prevent floating point rounding issues
        let dotSize = floor(min(dotSizeFromWidth, dotSizeFromHeight) * 100) / 100
        let baseSpacing = dotSize * spacingRatio

        // Calculate actual used dimensions
        let usedWidth = CGFloat(columns) * dotSize + CGFloat(columns - 1) * baseSpacing
        let usedHeight = CGFloat(rows) * dotSize + CGFloat(rows - 1) * baseSpacing

        // Distribute extra space evenly to spacing
        let extraHorizontal = availableWidth - usedWidth
        let extraVertical = availableHeight - usedHeight

        let actualHorizontalSpacing: CGFloat
        let actualVerticalSpacing: CGFloat

        if columns > 1 {
            actualHorizontalSpacing = baseSpacing + (extraHorizontal / CGFloat(columns - 1))
        } else {
            actualHorizontalSpacing = baseSpacing
        }

        if rows > 1 {
            actualVerticalSpacing = baseSpacing + (extraVertical / CGFloat(rows - 1))
        } else {
            actualVerticalSpacing = baseSpacing
        }

        return YearGridLayout(
            columns: columns,
            rows: rows,
            dotSize: dotSize,
            horizontalSpacing: actualHorizontalSpacing,
            verticalSpacing: actualVerticalSpacing
        )
    }

    /// Validates that a layout fits within the available space
    /// - Parameters:
    ///   - layout: The layout to validate
    ///   - availableWidth: Available width
    ///   - availableHeight: Available height
    /// - Returns: true if the layout fits, false otherwise
    public func validateLayout(
        _ layout: YearGridLayout,
        fitsIn availableWidth: CGFloat,
        availableHeight: CGFloat
    ) -> Bool {
        // Allow a tiny tolerance for floating point comparison
        let tolerance: CGFloat = 0.01
        return layout.totalWidth <= availableWidth + tolerance &&
               layout.totalHeight <= availableHeight + tolerance
    }
}
