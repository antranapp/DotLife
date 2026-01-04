#if canImport(UIKit)
import UIKit
#endif
import SwiftUI
import DotLifeDomain
import DotLifeUI

/// DotLifeShell module version.
public enum DotLifeShellModule {
    public static let version = "0.1.0"
}

#if canImport(UIKit)
/// Root view controller that hosts the horizontal pager with direction lock.
public final class RootViewController: UIViewController {
    /// The view model for capture, injected from AppKit
    public var captureViewModel: CaptureViewModel?

    /// The view model for visualize, injected from AppKit
    public var visualizeViewModel: VisualizeViewModel?

    /// Direction lock coordinator
    private let directionLock = DirectionLock()

    /// The horizontal pager
    private var horizontalPager: HorizontalPagerController?

    public override func viewDidLoad() {
        super.viewDidLoad()

        let pager = HorizontalPagerController()
        pager.captureViewModel = captureViewModel
        pager.visualizeViewModel = visualizeViewModel
        pager.directionLock = directionLock
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
    }
}
#endif

/// Placeholder SwiftUI view shown when no view model is available.
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
