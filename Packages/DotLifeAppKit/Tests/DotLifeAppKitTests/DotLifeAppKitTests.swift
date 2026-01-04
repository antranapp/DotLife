import Testing
@testable import DotLifeAppKit

@Test func bootstrapperConfigureDoesNotThrow() async throws {
    // Just ensure configure() can be called without crashing
    AppBootstrapper.configure()
}
