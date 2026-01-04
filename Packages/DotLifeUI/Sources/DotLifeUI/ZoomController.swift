import SwiftUI
import DotLifeDomain

/// Manages zoom state for a visualize view (Today or Week).
@MainActor
public final class ZoomController: ObservableObject {
    // MARK: - Published State

    /// The current zoom scale
    @Published public var currentScale: GridScale

    /// Whether a pinch gesture is active
    @Published public var isPinching: Bool = false

    /// The view type this controller manages
    public let viewType: VisualizeViewType

    // MARK: - Configuration

    /// Available scales for the current view type
    public var availableScales: [GridScale] {
        ZoomLadder.scales(for: viewType)
    }

    /// Whether the user can zoom in (to finer detail)
    public var canZoomIn: Bool {
        ZoomLadder.zoomIn(from: currentScale, in: viewType) != nil
    }

    /// Whether the user can zoom out (to coarser view)
    public var canZoomOut: Bool {
        ZoomLadder.zoomOut(from: currentScale, in: viewType) != nil
    }

    // MARK: - Initialization

    public init(viewType: VisualizeViewType) {
        self.viewType = viewType
        // Default to the finest scale
        self.currentScale = ZoomLadder.scales(for: viewType).first ?? .hours
    }

    // MARK: - Actions

    /// Zooms in one level (to finer detail).
    public func zoomIn() {
        guard let nextScale = ZoomLadder.zoomIn(from: currentScale, in: viewType) else { return }
        currentScale = nextScale
    }

    /// Zooms out one level (to coarser view).
    public func zoomOut() {
        guard let nextScale = ZoomLadder.zoomOut(from: currentScale, in: viewType) else { return }
        currentScale = nextScale
    }

    /// Toggles between first and second scale (for double-tap).
    public func toggleZoom() {
        let scales = availableScales
        guard scales.count >= 2 else { return }

        if currentScale == scales[0] {
            currentScale = scales[1]
        } else {
            currentScale = scales[0]
        }
    }

    /// Called when pinch gesture begins.
    public func pinchBegan() {
        isPinching = true
    }

    /// Called when pinch gesture ends.
    public func pinchEnded(scale: CGFloat) {
        isPinching = false

        // Use pinch scale to determine direction
        // scale < 1 means pinch in (fingers coming together) = zoom out
        // scale > 1 means pinch out (fingers spreading) = zoom in
        if scale < 0.8 {
            zoomOut()
        } else if scale > 1.2 {
            zoomIn()
        }
    }
}

// MARK: - Pinch Gesture Modifier

/// A view modifier that handles pinch gestures for zooming.
public struct PinchToZoomModifier: ViewModifier {
    @ObservedObject var controller: ZoomController
    @GestureState private var gestureScale: CGFloat = 1.0

    public init(controller: ZoomController) {
        self.controller = controller
    }

    public func body(content: Content) -> some View {
        content
            .gesture(
                MagnificationGesture()
                    .updating($gestureScale) { value, state, _ in
                        state = value
                    }
                    .onChanged { _ in
                        if !controller.isPinching {
                            controller.pinchBegan()
                        }
                    }
                    .onEnded { scale in
                        controller.pinchEnded(scale: scale)
                    }
            )
            .onTapGesture(count: 2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    controller.toggleZoom()
                }
            }
    }
}

extension View {
    /// Adds pinch-to-zoom and double-tap zoom to the view.
    public func pinchToZoom(controller: ZoomController) -> some View {
        self.modifier(PinchToZoomModifier(controller: controller))
    }
}
