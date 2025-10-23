import ProjectDescription

let project = Project(
  name: "DesignSystem",
  targets: [
    .target(
      name: "DesignSystem",
      destinations: [.iPhone],
      product: .framework,
      bundleId: "com.alberto.DejarEs.designsystem",
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: []
    )
  ]
)
