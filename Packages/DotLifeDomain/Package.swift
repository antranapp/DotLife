// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DotLifeDomain",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DotLifeDomain",
            targets: ["DotLifeDomain"]
        )
    ],
    targets: [
        .target(
            name: "DotLifeDomain",
            dependencies: []
        ),
        .testTarget(
            name: "DotLifeDomainTests",
            dependencies: ["DotLifeDomain"]
        )
    ]
)
