import UIKit
import SwiftUI
import DotLifeDomain
import DotLifeUI

/// Placeholder to ensure the module exports at least one public symbol.
/// UIKit pagers and direction lock will be implemented in a later milestone.
public enum DotLifeShellModule {
    public static let version = "0.1.0"
}

/// Placeholder root view controller that hosts the SwiftUI content.
/// Will be replaced with proper paging controllers in a later milestone.
public final class RootViewController: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()

        let placeholderView = PlaceholderRootView()
        let hostingController = UIHostingController(rootView: placeholderView)

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
}

/// Placeholder SwiftUI view shown inside the root controller.
struct PlaceholderRootView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "circle.dotted")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)

            Text("DotLife")
                .font(.largeTitle)
                .fontWeight(.semibold)

            Text("Capture moments. See time as dots.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
