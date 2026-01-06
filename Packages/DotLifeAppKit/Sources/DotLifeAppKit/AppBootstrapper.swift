import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import DotLifeDomain
import DotLifePersistence
import DotLifeDS
import DotLifeUI
import DotLifeShell

/// The composition root for DotLife.
/// Boots services, repositories, and constructs the root UI.
public enum AppBootstrapper {
    /// Shared Core Data stack
    private static var coreDataStack: CoreDataStack?

    /// Shared repository
    private static var repository: CoreDataExperienceRepository?

    /// Shared bucketing service
    private static var bucketingService: TimeBucketingService?

    /// Shared theme manager
    private static var themeManager: ThemeManager?

    /// Configures the application on launch.
    /// Call this from `AppDelegate.application(_:didFinishLaunchingWithOptions:)`.
    @MainActor
    public static func configure() {
        // Initialize Core Data stack
        coreDataStack = CoreDataStack()

        // Initialize services
        bucketingService = TimeBucketingService.current

        // Initialize repository
        repository = CoreDataExperienceRepository(stack: coreDataStack!)

        // Initialize theme manager
        if themeManager == nil {
            themeManager = ThemeManager()
        }
    }

    /// Creates the root SwiftUI view that wraps the UIKit shell.
    /// Use this in `WindowGroup` of your SwiftUI `App`.
    @MainActor
    public static func makeRootView() -> some View {
        #if canImport(UIKit)
        if themeManager == nil {
            themeManager = ThemeManager()
        }
        let activeThemeManager = themeManager ?? ThemeManager()
        let controller = makeRootViewController()
        let rootView = RootViewControllerRepresentable(viewController: controller)
        return RootContainerView(rootView: rootView)
            .environmentObject(activeThemeManager)
            .preferredColorScheme(activeThemeManager.preferredColorScheme)
        #else
        return PlaceholderView()
        #endif
    }

    #if canImport(UIKit)
    /// Creates the root UIKit view controller directly.
    /// Use this if you need to set up a UIKit-based window manually.
    @MainActor
    public static func makeRootViewController() -> RootViewController {
        let controller = RootViewController()
        if themeManager == nil {
            themeManager = ThemeManager()
        }
        controller.themeManager = themeManager

        // Create the view models with dependencies
        if let repo = repository {
            let captureVM = CaptureViewModel(
                repository: repo,
                bucketingService: bucketingService ?? .current
            )
            controller.captureViewModel = captureVM

            let visualizeVM = VisualizeViewModel(
                repository: repo,
                bucketingService: bucketingService ?? .current
            )
            controller.visualizeViewModel = visualizeVM
        }

        return controller
    }
    #endif
}

#if canImport(UIKit)
/// A `UIViewControllerRepresentable` that wraps the UIKit root controller
/// for use in SwiftUI's `WindowGroup`.
struct RootViewControllerRepresentable: UIViewControllerRepresentable {
    let viewController: RootViewController

    func makeUIViewController(context: Context) -> RootViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: RootViewController, context: Context) {
        // No updates needed for now
    }
}
#endif

/// Ensures the app background fills the full screen behind the UIKit shell.
struct RootContainerView: View {
    let rootView: RootViewControllerRepresentable
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let colors = themeManager.tokens(for: colorScheme).colors
        ZStack {
            colors.appBackground.ignoresSafeArea()
            rootView
        }
    }
}

/// Placeholder view for non-iOS platforms.
struct PlaceholderView: View {
    var body: some View {
        Text("DotLife - iOS only")
            .font(.largeTitle)
    }
}
