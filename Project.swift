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
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "69HZYGNPYT",
                    "CODE_SIGN_STYLE": "Automatic"
                ]
            )
        ),
        .target(
            name: "DotLifeAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "app.antran.dotlife.tests",
            deploymentTargets: .iOS("17.0"),
            sources: [
                "Packages/DotLifeUI/Tests/DotLifeUITests/**",
                "Packages/DotLifeDomain/Tests/DotLifeDomainTests/**"
            ],
            dependencies: [
                .target(name: "DotLifeApp"),
                .external(name: "DotLifeUI"),
                .external(name: "DotLifeDomain")
            ]
        )
    ]
)
