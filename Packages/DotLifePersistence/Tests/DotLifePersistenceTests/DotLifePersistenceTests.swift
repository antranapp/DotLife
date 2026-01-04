import Testing
@testable import DotLifePersistence

@Test func moduleVersionExists() async throws {
    #expect(DotLifePersistenceModule.version == "0.1.0")
}
