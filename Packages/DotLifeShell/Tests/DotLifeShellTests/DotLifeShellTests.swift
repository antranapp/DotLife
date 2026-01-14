import Testing
import DotLifeShell

@Test func moduleVersionExists() async throws {
    #expect(DotLifeShellModule.version == "0.1.0")
}
