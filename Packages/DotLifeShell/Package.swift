// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DotLifeShell",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DotLifeShell",
            targets: ["DotLifeShell"]
        )
    ],
    dependencies: [
        .package(path: "../DotLifeDomain"),
        .package(path: "../DotLifeDS"),
        .package(path: "../DotLifeUI")
    ],
    targets: [
        .target(
            name: "DotLifeShell",
            dependencies: ["DotLifeDomain", "DotLifeDS", "DotLifeUI"]
        ),
        .testTarget(
            name: "DotLifeShellTests",
            dependencies: ["DotLifeShell"]
        )
    ]
)
