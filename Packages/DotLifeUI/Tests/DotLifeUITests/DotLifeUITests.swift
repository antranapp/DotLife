import Testing
@testable import DotLifeUI

@Test func moduleVersionExists() async throws {
    #expect(DotLifeUIModule.version == "0.1.0")
}
