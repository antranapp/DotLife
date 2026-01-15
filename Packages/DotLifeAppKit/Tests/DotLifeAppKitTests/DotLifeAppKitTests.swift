import Testing
import DotLifeAppKit

@Test @MainActor func appKitBootstrapperConfigureDoesNotThrow() async throws {
    // Just ensure configure() can be called without crashing
    AppBootstrapper.configure()
}
