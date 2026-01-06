#if canImport(UIKit)
import Combine
import UIKit
import SwiftUI
import DotLifeUI
import DotLifeDomain
import DotLifeDS

/// Horizontal pager that contains Capture and Visualize pages.
public final class HorizontalPagerController: UIViewController {

    // MARK: - Properties

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.bounces = true
        sv.alwaysBounceHorizontal = true
        sv.alwaysBounceVertical = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        // Prevent automatic content inset adjustments that can reset scroll position
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    /// The capture view model (injected from AppKit)
    public var captureViewModel: CaptureViewModel?

    /// The visualize view model (injected from AppKit)
    public var visualizeViewModel: VisualizeViewModel?

    /// Direction lock coordinator
    public var directionLock: DirectionLock?

    /// Theme manager injected from AppKit
    public var themeManager: ThemeManager?

    /// Child view controllers for each page
    private var captureHostingController: UIViewController?
    private var visualizeController: VerticalPagerController?

    private var themeObservation: AnyCancellable?
    private var currentPage: Int = 0
    private var pendingPage: Int?
    private var didSetInitialPage = false

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupPages()
        applyTheme()
        observeThemeChanges()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didSetInitialPage {
            syncCurrentPage()
            didSetInitialPage = true
        }
    }

    // MARK: - Setup

    private func setupScrollView() {
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.addSubview(contentView)

        // Use contentLayoutGuide for scroll content size calculation
        // and frameLayoutGuide for sizing relative to visible area
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            // Height must equal scroll view visible height (no vertical scrolling)
            contentView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            // Width is 2x scroll view visible width (2 pages)
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, multiplier: 2)
        ])

        scrollView.delegate = self
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
    }

    private func setupPages() {
        // Page 1: Capture
        setupCapturePage()

        // Page 2: Visualize (vertical pager)
        setupVisualizePage()
    }

    private func setupCapturePage() {
        guard let viewModel = captureViewModel else {
            // Fallback to placeholder if no view model
            let placeholder = makeHostingController(rootView: PlaceholderRootView())
            addChild(placeholder)
            contentView.addSubview(placeholder.view)
            placeholder.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                placeholder.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                placeholder.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                placeholder.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                placeholder.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
            ])
            placeholder.didMove(toParent: self)
            return
        }

        let captureView = CaptureView(viewModel: viewModel)
        let hostingController = makeHostingController(rootView: captureView)
        captureHostingController = hostingController

        addChild(hostingController)
        contentView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    private func setupVisualizePage() {
        let visualizeVC = VerticalPagerController()
        visualizeVC.directionLock = directionLock
        visualizeVC.visualizeViewModel = visualizeViewModel
        visualizeVC.themeManager = themeManager
        visualizeController = visualizeVC

        // Update direction lock to use the vertical scroll view
        if let lock = directionLock {
            lock.register(horizontalScrollView: scrollView, verticalScrollView: visualizeVC.scrollView)
        }

        addChild(visualizeVC)
        contentView.addSubview(visualizeVC.view)
        visualizeVC.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            visualizeVC.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            visualizeVC.view.leadingAnchor.constraint(equalTo: contentView.centerXAnchor),
            visualizeVC.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            visualizeVC.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        visualizeVC.didMove(toParent: self)
    }

    // MARK: - Public API

    /// Exposes the scroll view for direction lock coordination.
    public var horizontalScrollView: UIScrollView {
        scrollView
    }

    /// Scrolls to a specific page.
    public func scrollTo(page: Int, animated: Bool = true) {
        let x = CGFloat(page) * scrollView.bounds.width
        if animated {
            pendingPage = page
        } else {
            setCurrentPage(page)
        }
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
    }

    // MARK: - Theme

    private func observeThemeChanges() {
        themeObservation = themeManager?.objectWillChange.sink { [weak self] _ in
            self?.applyTheme()
        }
    }

    private func applyTheme() {
        guard let themeManager else { return }
        overrideUserInterfaceStyle = themeManager.interfaceStyleOverride
        captureHostingController?.overrideUserInterfaceStyle = themeManager.interfaceStyleOverride
        visualizeController?.overrideUserInterfaceStyle = themeManager.interfaceStyleOverride
        let colors = themeManager.uiColors(for: traitCollection.userInterfaceStyle)
        view.backgroundColor = colors.appBackground
        scrollView.backgroundColor = colors.appBackground
        contentView.backgroundColor = colors.appBackground
        captureHostingController?.view.backgroundColor = colors.appBackground
        visualizeController?.view.backgroundColor = colors.appBackground
    }

    private func makeHostingController<Content: View>(rootView: Content) -> UIHostingController<AnyView> {
        let resolvedView: AnyView
        if let themeManager = themeManager {
            resolvedView = AnyView(rootView.environmentObject(themeManager))
        } else {
            resolvedView = AnyView(rootView)
        }
        let hostingController = UIHostingController(rootView: resolvedView)
        if let themeManager = themeManager {
            hostingController.overrideUserInterfaceStyle = themeManager.interfaceStyleOverride
            let colors = themeManager.uiColors(for: traitCollection.userInterfaceStyle)
            hostingController.view.backgroundColor = colors.appBackground
        } else {
            hostingController.view.backgroundColor = .clear
        }
        return hostingController
    }

    private func setCurrentPage(_ page: Int) {
        guard page != currentPage else { return }
        currentPage = page
        captureViewModel?.isCaptureActive = page == 0
    }

    private func syncCurrentPage() {
        let width = scrollView.bounds.width
        guard width > 0 else { return }
        let page = Int(round(scrollView.contentOffset.x / width))
        setCurrentPage(page)
    }

    // MARK: - Gesture Handling

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let lock = directionLock else { return }
        let location = recognizer.location(in: scrollView)

        switch recognizer.state {
        case .began:
            lock.touchBegan(at: location)
        case .changed:
            _ = lock.touchMoved(to: location)
        case .ended, .cancelled, .failed:
            lock.touchEnded()
        default:
            break
        }
    }
}

// MARK: - UIScrollViewDelegate

extension HorizontalPagerController: UIScrollViewDelegate {
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            syncCurrentPage()
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        syncCurrentPage()
        directionLock?.enableAllScrolling()
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let page = pendingPage {
            pendingPage = nil
            setCurrentPage(page)
        } else {
            syncCurrentPage()
        }
        directionLock?.enableAllScrolling()
    }
}

#endif
