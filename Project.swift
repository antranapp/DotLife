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
                "Packages/DotLifeDomain/Tests/DotLifeDomainTests/**",
                "Packages/DotLifeUI/Tests/DotLifeUITests/**",
                "Packages/DotLifeShell/Tests/DotLifeShellTests/**",
                "Packages/DotLifePersistence/Tests/DotLifePersistenceTests/**",
                "Packages/DotLifeAppKit/Tests/DotLifeAppKitTests/**"
            ],
            dependencies: [
                .target(name: "DotLifeApp"),
                .external(name: "DotLifeDomain"),
                .external(name: "DotLifeUI"),
                .external(name: "DotLifeShell"),
                .external(name: "DotLifePersistence"),
                .external(name: "DotLifeAppKit")
            ]
        )
    ],
    additionalFiles: [
        .folderReference(path: "ci_scripts")
    ]
)
