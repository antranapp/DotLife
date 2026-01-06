#if canImport(UIKit)
import Combine
import UIKit
import SwiftUI
import DotLifeUI
import DotLifeDomain
import DotLifeDS

/// Vertical pager that contains Today and This Week views.
public final class VerticalPagerController: UIViewController {

    // MARK: - Properties

    public let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.bounces = true
        sv.alwaysBounceHorizontal = false
        sv.alwaysBounceVertical = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    /// Direction lock coordinator
    public weak var directionLock: DirectionLock?

    /// View model for visualization (injected from AppKit)
    public var visualizeViewModel: VisualizeViewModel?

    /// Theme manager injected from AppKit
    public var themeManager: ThemeManager?

    /// Child hosting controllers
    private var todayHostingController: UIViewController?
    private var weekHostingController: UIViewController?

    private var themeObservation: AnyCancellable?

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupPages()
        setupPinchObserver()
        applyTheme()
        observeThemeChanges()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme()
    }

    // MARK: - Pinch Observation

    private func setupPinchObserver() {
        // Connect visualize view model's pinching callback to direction lock
        visualizeViewModel?.onPinchingChanged = { [weak self] isPinching in
            if isPinching {
                self?.directionLock?.disableAllScrolling()
            } else {
                self?.directionLock?.enableAllScrolling()
            }
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
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            // Width must equal scroll view visible width (no horizontal scrolling)
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            // Height is 2x scroll view visible height (2 pages)
            contentView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, multiplier: 2)
        ])

        scrollView.delegate = self
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
    }

    private func setupPages() {
        // Page 1: Today view
        setupTodayPage()

        // Page 2: This Week view
        setupWeekPage()
    }

    private func setupTodayPage() {
        let hostingController: UIViewController

        if let viewModel = visualizeViewModel {
            let todayView = TodayGridView(viewModel: viewModel)
            hostingController = makeHostingController(rootView: todayView)
        } else {
            hostingController = makeHostingController(rootView: TodayPlaceholderView())
        }

        todayHostingController = hostingController

        addChild(hostingController)
        contentView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    private func setupWeekPage() {
        let hostingController: UIViewController

        if let viewModel = visualizeViewModel {
            let weekView = WeekGridView(viewModel: viewModel)
            hostingController = makeHostingController(rootView: weekView)
        } else {
            hostingController = makeHostingController(rootView: WeekPlaceholderView())
        }

        weekHostingController = hostingController

        addChild(hostingController)
        contentView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.centerYAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    // MARK: - Public API

    /// Scrolls to a specific page (0 = Today, 1 = Week).
    public func scrollTo(page: Int, animated: Bool = true) {
        let y = CGFloat(page) * scrollView.bounds.height
        scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: animated)
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
        todayHostingController?.overrideUserInterfaceStyle = themeManager.interfaceStyleOverride
        weekHostingController?.overrideUserInterfaceStyle = themeManager.interfaceStyleOverride
        let colors = themeManager.uiColors(for: traitCollection.userInterfaceStyle)
        view.backgroundColor = colors.appBackground
        scrollView.backgroundColor = colors.appBackground
        contentView.backgroundColor = colors.appBackground
        todayHostingController?.view.backgroundColor = colors.appBackground
        weekHostingController?.view.backgroundColor = colors.appBackground
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

extension VerticalPagerController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Direction lock handled by gesture coordinator
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        directionLock?.enableAllScrolling()
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        directionLock?.enableAllScrolling()
    }
}


// MARK: - Placeholder Views

struct TodayPlaceholderView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    var body: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        VStack(spacing: 20) {
            Image(systemName: "clock")
                .font(.system(size: 60))
                .foregroundStyle(colors.textSecondary)

            Text("Today")
                .font(typography.title)
                .foregroundStyle(colors.textPrimary)

            Text("Swipe down for This Week")
                .font(typography.body)
                .foregroundStyle(colors.textSecondary)

            Spacer()

            Image(systemName: "chevron.down")
                .font(.title2)
                .foregroundStyle(colors.textSecondary.opacity(0.7))
                .padding(.bottom, 40)
        }
        .padding(.top, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.appBackground.ignoresSafeArea())
    }
}

struct WeekPlaceholderView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    var body: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        VStack(spacing: 20) {
            Image(systemName: "chevron.up")
                .font(.title2)
                .foregroundStyle(colors.textSecondary.opacity(0.7))
                .padding(.top, 40)

            Spacer()

            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundStyle(colors.textSecondary)

            Text("This Week")
                .font(typography.title)
                .foregroundStyle(colors.textPrimary)

            Text("Swipe up for Today")
                .font(typography.body)
                .foregroundStyle(colors.textSecondary)
        }
        .padding(.bottom, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.appBackground.ignoresSafeArea())
    }
}
#endif
