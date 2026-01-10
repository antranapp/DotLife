#if canImport(UIKit)
import Combine
import UIKit
#endif
import SwiftUI
import DotLifeDomain
import DotLifeDS
import DotLifeUI

// Re-export DetailView and DetailViewModel for UIKit presentation
#if canImport(UIKit)
public typealias ShellDetailView = DotLifeUI.DetailView
public typealias ShellDetailViewModel = DotLifeUI.DetailViewModel
#endif

/// DotLifeShell module version.
public enum DotLifeShellModule {
    public static let version = "0.1.0"
}

#if canImport(UIKit)
/// Root view controller that hosts the horizontal pager with direction lock.
public final class RootViewController: UIViewController {
    /// The view model for year visualization, injected from AppKit
    public var yearViewModel: YearViewModel?

    /// The view model for capture, injected from AppKit
    public var captureViewModel: CaptureViewModel?

    /// The view model for visualize, injected from AppKit
    public var visualizeViewModel: VisualizeViewModel?

    /// Direction lock coordinator
    private let directionLock = DirectionLock()

    /// The horizontal pager
    private var horizontalPager: HorizontalPagerController?

    /// Theme manager injected from AppKit
    public var themeManager: ThemeManager?

    private var themeObservation: AnyCancellable?

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Set up detail presentation callback BEFORE creating pager
        setupDetailPresentationCallback()

        let pager = HorizontalPagerController()
        pager.yearViewModel = yearViewModel
        pager.captureViewModel = captureViewModel
        pager.visualizeViewModel = visualizeViewModel
        pager.directionLock = directionLock
        pager.themeManager = themeManager
        horizontalPager = pager

        addChild(pager)
        view.addSubview(pager.view)
        pager.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pager.view.topAnchor.constraint(equalTo: view.topAnchor),
            pager.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pager.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pager.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        pager.didMove(toParent: self)

        applyTheme()
        observeThemeChanges()
    }

    // MARK: - Detail Presentation

    private func setupDetailPresentationCallback() {
        visualizeViewModel?.onPresentDetail = { [weak self] bucket in
            self?.presentDetail(for: bucket)
        }
    }

    private func presentDetail(for bucket: TimeBucket) {
        guard let visualizeVM = visualizeViewModel else { return }

        // Create the detail view model
        let detailVM = DetailViewModel(
            bucket: bucket,
            repository: visualizeVM.repository,
            bucketingService: visualizeVM.bucketingService
        )

        // Create the SwiftUI view with Done button for modal dismiss
        let detailView = DetailView(
            viewModel: detailVM,
            onDismiss: { [weak self] in
                self?.dismiss(animated: false) {
                    Task {
                        await self?.visualizeViewModel?.refresh()
                    }
                }
            }
        )

        // Wrap in hosting controller with theme
        let hostingController: UIHostingController<AnyView>
        if let tm = themeManager {
            hostingController = UIHostingController(
                rootView: AnyView(detailView.environmentObject(tm))
            )
            hostingController.overrideUserInterfaceStyle = tm.interfaceStyleOverride
            let colors = tm.uiColors(for: traitCollection.userInterfaceStyle)
            hostingController.view.backgroundColor = colors.appBackground
        } else {
            hostingController = UIHostingController(rootView: AnyView(detailView))
        }

        // Present modally - completely outside scroll view hierarchy
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme()
    }

    private func observeThemeChanges() {
        themeObservation = themeManager?.objectWillChange.sink { [weak self] _ in
            self?.applyTheme()
        }
    }

    private func applyTheme() {
        guard let themeManager else { return }
        overrideUserInterfaceStyle = themeManager.interfaceStyleOverride
        let colors = themeManager.uiColors(for: traitCollection.userInterfaceStyle)
        view.backgroundColor = colors.appBackground
    }
}
#endif

/// Placeholder SwiftUI view shown when no view model is available.
struct PlaceholderRootView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    var body: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        VStack(spacing: 20) {
            Image(systemName: "circle.dotted")
                .font(.system(size: 80))
                .foregroundStyle(colors.textSecondary)

            Text("DotLife")
                .font(typography.title)
                .foregroundStyle(colors.textPrimary)

            Text("Capture moments. See time as dots.")
                .font(typography.body)
                .foregroundStyle(colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.appBackground.ignoresSafeArea())
    }
}
