import ProjectDescription

let project = Project(
    name: "DotLife",
    targets: [
        .target(
            name: "DotLifeApp",
            destinations: .iOS,
            product: .app,
            bundleId: "app.antran.dotlife",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .file(path: "DotLifeApp/SupportingFiles/Info.plist"),
            sources: ["DotLifeApp/Sources/**"],
            resources: ["DotLifeApp/Resources/**"],
            dependencies: [
                .external(name: "DotLifeAppKit")
            ]
        )
    ]
)
