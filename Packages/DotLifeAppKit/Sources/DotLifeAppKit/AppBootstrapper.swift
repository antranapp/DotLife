import SwiftUI
import UIKit
import DotLifeDomain
import DotLifePersistence
import DotLifeUI
import DotLifeShell

/// The composition root for DotLife.
/// Boots services, repositories, and constructs the root UI.
public enum AppBootstrapper {

    /// Configures the application on launch.
    /// Call this from `AppDelegate.application(_:didFinishLaunchingWithOptions:)`.
    public static func configure() {
        // Future: Initialize Core Data stack, services, etc.
    }

    /// Creates the root SwiftUI view that wraps the UIKit shell.
    /// Use this in `WindowGroup` of your SwiftUI `App`.
    @MainActor
    public static func makeRootView() -> some View {
        RootViewControllerRepresentable()
    }

    /// Creates the root UIKit view controller directly.
    /// Use this if you need to set up a UIKit-based window manually.
    @MainActor
    public static func makeRootViewController() -> UIViewController {
        RootViewController()
    }
}

/// A `UIViewControllerRepresentable` that wraps the UIKit root controller
/// for use in SwiftUI's `WindowGroup`.
struct RootViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> RootViewController {
        RootViewController()
    }

    func updateUIViewController(_ uiViewController: RootViewController, context: Context) {
        // No updates needed for now
    }
}
