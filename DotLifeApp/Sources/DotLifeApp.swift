import SwiftUI
import DotLifeAppKit

@main
struct DotLifeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AppBootstrapper.makeRootView()
        }
    }
}
