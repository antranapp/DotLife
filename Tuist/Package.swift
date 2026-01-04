// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "DotLifeDomain": .framework,
        "DotLifePersistence": .framework,
        "DotLifeUI": .framework,
        "DotLifeShell": .framework,
        "DotLifeAppKit": .framework
    ]
)
#endif

let package = Package(
    name: "DotLifeDependencies",
    platforms: [.iOS(.v17)],
    products: [],
    dependencies: [
        .package(path: "../Packages/DotLifeDomain"),
        .package(path: "../Packages/DotLifePersistence"),
        .package(path: "../Packages/DotLifeUI"),
        .package(path: "../Packages/DotLifeShell"),
        .package(path: "../Packages/DotLifeAppKit")
    ]
)
