#if canImport(UIKit)
import Testing
import UIKit
import DotLifeShell

@Test func directionLockPrefersHorizontalWhenDxDominates() {
    let horizontal = UIScrollView()
    let vertical = UIScrollView()
    let lock = DirectionLock(threshold: 10, ratioThreshold: 1.2)
    lock.register(horizontalScrollView: horizontal, verticalScrollView: vertical)

    lock.touchBegan(at: CGPoint(x: 0, y: 0))
    let axis = lock.touchMoved(to: CGPoint(x: 20, y: 5))

    #expect(axis == .horizontal)
    #expect(vertical.isScrollEnabled == false)
    #expect(horizontal.isScrollEnabled == true)
}

@Test func directionLockPrefersVerticalWhenDyDominates() {
    let horizontal = UIScrollView()
    let vertical = UIScrollView()
    let lock = DirectionLock(threshold: 10, ratioThreshold: 1.2)
    lock.register(horizontalScrollView: horizontal, verticalScrollView: vertical)

    lock.touchBegan(at: CGPoint(x: 0, y: 0))
    let axis = lock.touchMoved(to: CGPoint(x: 5, y: 20))

    #expect(axis == .vertical)
    #expect(horizontal.isScrollEnabled == false)
    #expect(vertical.isScrollEnabled == true)
}

@Test func directionLockDoesNotLockWhenAmbiguous() {
    let horizontal = UIScrollView()
    let vertical = UIScrollView()
    let lock = DirectionLock(threshold: 10, ratioThreshold: 1.2)
    lock.register(horizontalScrollView: horizontal, verticalScrollView: vertical)

    lock.touchBegan(at: CGPoint(x: 0, y: 0))
    // Diagonal movement - neither dx nor dy dominates by ratioThreshold
    let axis = lock.touchMoved(to: CGPoint(x: 12, y: 11))

    // When ambiguous, don't lock - let both scroll views compete naturally
    #expect(axis == nil)
    #expect(horizontal.isScrollEnabled == true)
    #expect(vertical.isScrollEnabled == true)
}

@Test func directionLockResetsOnTouchEnd() {
    let horizontal = UIScrollView()
    let vertical = UIScrollView()
    let lock = DirectionLock(threshold: 10, ratioThreshold: 1.2)
    lock.register(horizontalScrollView: horizontal, verticalScrollView: vertical)

    lock.touchBegan(at: CGPoint(x: 0, y: 0))
    _ = lock.touchMoved(to: CGPoint(x: 20, y: 5))
    lock.touchEnded()

    #expect(horizontal.isScrollEnabled == true)
    #expect(vertical.isScrollEnabled == true)
    #expect(lock.lockedAxis == nil)
}
#endif
