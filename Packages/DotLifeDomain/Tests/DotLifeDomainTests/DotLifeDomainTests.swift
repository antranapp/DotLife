import Testing
@testable import DotLifeDomain

@Test func moduleVersionExists() async throws {
    #expect(DotLifeDomainModule.version == "0.1.0")
}
