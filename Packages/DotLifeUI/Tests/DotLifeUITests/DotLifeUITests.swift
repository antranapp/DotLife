import Testing
@testable import DotLifeUI

@Test func uiModuleVersionExists() async throws {
    #expect(DotLifeUIModule.version == "0.1.0")
}
