import ProjectDescription

let project = Project(
  name: "FeatureHabits",
  targets: [
    .target(
      name: "FeatureHabits",
      destinations: [.iPhone],
      product: .framework,
      bundleId: "com.alberto.DejarEs.feature.habits",
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: []
    ),
    .target(
      name: "FeatureHabitsTests",
      destinations: [.iPhone],
      product: .unitTests,
      bundleId: "com.alberto.DejarEs.feature.habits.tests",
      sources: ["Tests/**"],
      dependencies: [.target(name: "FeatureHabits")]
    )
  ]
)
