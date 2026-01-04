import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import DotLifeDomain
import DotLifePersistence
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

    /// Configures the application on launch.
    /// Call this from `AppDelegate.application(_:didFinishLaunchingWithOptions:)`.
    public static func configure() {
        // Initialize Core Data stack
        coreDataStack = CoreDataStack()

        // Initialize services
        bucketingService = TimeBucketingService.current

        // Initialize repository
        repository = CoreDataExperienceRepository(stack: coreDataStack!)
    }

    /// Creates the root SwiftUI view that wraps the UIKit shell.
    /// Use this in `WindowGroup` of your SwiftUI `App`.
    @MainActor
    public static func makeRootView() -> some View {
        #if canImport(UIKit)
        return RootViewControllerRepresentable(
            viewController: makeRootViewController()
        )
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

/// Placeholder view for non-iOS platforms.
struct PlaceholderView: View {
    var body: some View {
        Text("DotLife - iOS only")
            .font(.largeTitle)
    }
}
