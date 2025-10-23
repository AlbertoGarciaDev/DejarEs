import ProjectDescription

let project = Project(
  name: "DejarEsApp",
  settings: .settings(
    base: ["SWIFT_VERSION": "5.10"],
    configurations: [.debug(name: "Debug"), .release(name: "Release")]
  ),
  targets: [
    .target(
      name: "DejarEsApp",
      destinations: [.iPhone],
      product: .app,
      bundleId: "com.alberto.DejarEs",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .extendingDefault(with: [
        "UILaunchScreen": [:]
      ]),
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: [
        .project(target: "FeatureHabits", path: "../../Modules/FeatureHabits"),
        .project(target: "DesignSystem",  path: "../../Dependencies/DesignSystem")
      ]
    )
  ]
)
