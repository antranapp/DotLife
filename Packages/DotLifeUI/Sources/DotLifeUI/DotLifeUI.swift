import SwiftUI
import DotLifeDomain

/// Placeholder to ensure the module exports at least one public symbol.
/// SwiftUI views will be implemented in later milestones.
public enum DotLifeUIModule {
    public static let version = "0.1.0"
}

/// Placeholder view for the Capture screen.
public struct CaptureView: View {
    public init() {}

    public var body: some View {
        Text("Capture")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
    }
}

/// Placeholder view for the Visualize screen.
public struct VisualizeView: View {
    public init() {}

    public var body: some View {
        Text("Visualize")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
    }
}
