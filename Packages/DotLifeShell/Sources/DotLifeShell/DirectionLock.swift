#if canImport(UIKit)
import UIKit
import os.log

private let logger = Logger(subsystem: "app.antran.dotlife", category: "DirectionLock")

/// Manages direction locking for nested scroll views.
/// Prevents accidental cross-axis scrolling by locking to the first detected direction.
public final class DirectionLock: NSObject {
    /// The threshold (in points) before a direction is locked.
    public let threshold: CGFloat

    /// The ratio threshold for determining direction (horizontal vs vertical).
    /// A value > 1 means horizontal needs to be this many times larger to be preferred.
    public let ratioThreshold: CGFloat

    /// The currently locked axis.
    public private(set) var lockedAxis: Axis?

    /// The scroll views being coordinated.
    private var horizontalScrollView: UIScrollView?
    private var verticalScrollView: UIScrollView?

    /// The initial touch point for calculating direction.
    private var initialTouchPoint: CGPoint?

    /// Axis enumeration.
    public enum Axis {
        case horizontal
        case vertical
    }

    public init(threshold: CGFloat = 25, ratioThreshold: CGFloat = 1.3) {
        self.threshold = threshold
        self.ratioThreshold = ratioThreshold
        super.init()
    }

    /// Registers the scroll views for coordination.
    public func register(horizontalScrollView: UIScrollView, verticalScrollView: UIScrollView) {
        self.horizontalScrollView = horizontalScrollView
        self.verticalScrollView = verticalScrollView
    }

    /// Called when a touch begins.
    public func touchBegan(at point: CGPoint) {
        initialTouchPoint = point
        lockedAxis = nil
    }

    /// Called when a touch moves. Returns the detected axis and locks if threshold is exceeded.
    public func touchMoved(to point: CGPoint) -> Axis? {
        guard let initial = initialTouchPoint else { return lockedAxis }

        // If already locked, return the locked axis
        if let axis = lockedAxis {
            return axis
        }

        let dx = abs(point.x - initial.x)
        let dy = abs(point.y - initial.y)

        // Check if we've exceeded the threshold
        if max(dx, dy) >= threshold {
            // Determine axis based on ratio
            if dx > dy * ratioThreshold {
                lockedAxis = .horizontal
                verticalScrollView?.isScrollEnabled = false
            } else if dy > dx * ratioThreshold {
                lockedAxis = .vertical
                horizontalScrollView?.isScrollEnabled = false
            }
            // When ambiguous (diagonal swipe), don't lock - let both scroll views compete naturally
        }

        return lockedAxis
    }

    /// Called when a touch ends or is cancelled.
    public func touchEnded() {
        // Re-enable both scroll views
        horizontalScrollView?.isScrollEnabled = true
        verticalScrollView?.isScrollEnabled = true
        lockedAxis = nil
        initialTouchPoint = nil
    }

    /// Temporarily disables scrolling on both axes (e.g., during pinch gestures).
    public func disableAllScrolling() {
        horizontalScrollView?.isScrollEnabled = false
        verticalScrollView?.isScrollEnabled = false
    }

    /// Re-enables scrolling on both axes.
    public func enableAllScrolling() {
        logger.debug("enableAllScrolling()")
        horizontalScrollView?.isScrollEnabled = true
        verticalScrollView?.isScrollEnabled = true
    }
}

// MARK: - UIGestureRecognizerDelegate

extension DirectionLock: UIGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Allow simultaneous recognition initially, then direction lock takes over
        return true
    }
}
#endif
