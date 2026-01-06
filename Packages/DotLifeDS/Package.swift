// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DotLifeDS",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DotLifeDS",
            targets: ["DotLifeDS"]
        )
    ],
    targets: [
        .target(
            name: "DotLifeDS",
            dependencies: []
        ),
        .testTarget(
            name: "DotLifeDSTests",
            dependencies: ["DotLifeDS"]
        )
    ]
)
