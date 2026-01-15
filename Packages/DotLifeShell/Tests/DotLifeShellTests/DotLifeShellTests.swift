import Testing
import DotLifeShell

@Test func shellModuleVersionExists() async throws {
    #expect(DotLifeShellModule.version == "0.1.0")
}
