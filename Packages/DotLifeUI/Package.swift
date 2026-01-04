// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DotLifeUI",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DotLifeUI",
            targets: ["DotLifeUI"]
        )
    ],
    dependencies: [
        .package(path: "../DotLifeDomain")
    ],
    targets: [
        .target(
            name: "DotLifeUI",
            dependencies: ["DotLifeDomain"]
        ),
        .testTarget(
            name: "DotLifeUITests",
            dependencies: ["DotLifeUI"]
        )
    ]
)
