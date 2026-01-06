// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DotLifeAppKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DotLifeAppKit",
            targets: ["DotLifeAppKit"]
        )
    ],
    dependencies: [
        .package(path: "../DotLifeDomain"),
        .package(path: "../DotLifePersistence"),
        .package(path: "../DotLifeDS"),
        .package(path: "../DotLifeUI"),
        .package(path: "../DotLifeShell")
    ],
    targets: [
        .target(
            name: "DotLifeAppKit",
            dependencies: [
                "DotLifeDomain",
                "DotLifePersistence",
                "DotLifeDS",
                "DotLifeUI",
                "DotLifeShell"
            ]
        ),
        .testTarget(
            name: "DotLifeAppKitTests",
            dependencies: ["DotLifeAppKit"]
        )
    ]
)
