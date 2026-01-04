// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DotLifePersistence",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "DotLifePersistence",
            targets: ["DotLifePersistence"]
        )
    ],
    dependencies: [
        .package(path: "../DotLifeDomain")
    ],
    targets: [
        .target(
            name: "DotLifePersistence",
            dependencies: ["DotLifeDomain"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "DotLifePersistenceTests",
            dependencies: ["DotLifePersistence"]
        )
    ]
)
