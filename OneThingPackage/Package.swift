// swift-tools-version: 6.1


import PackageDescription


let package = Package(
  name: "OneThingPackage",
  platforms: [.iOS(.v18)],
  products: [
    .library(
      name: "AppDatabase",
      targets: ["AppDatabase"]
    ),
    .library(
      name: "AppFeature",
      targets: ["AppFeature"]
    ),
    .library(
      name: "BaseTestSuite",
      targets: ["BaseTestSuite"]
    ),
    .library(
      name: "ModelActions",
      targets: ["ModelActions"]
    ),
    .library(
      name: "Schema",
      targets: ["Schema"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/groue/GRDB.swift", from: "7.6.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.0"),
    .package(url: "https://github.com/pointfreeco/sqlite-data", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "AppDatabase",
      dependencies: [
        "Schema",
      ]
    ),
    .target(
      name: "AppFeature",
      dependencies: []
    ),
    .target(
      name: "BaseTestSuite",
      dependencies: [
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
        "AppDatabase",
      ]
    ),
    .target(
      name: "ModelActions",
      dependencies: [
        "Schema",
      ]
    ),
    .testTarget(
      name: "ModelActionsTests",
      dependencies: [
//        "BaseTestSuite",
//        "ModelActions",
//        "Schema",
      ]
    ),
    .target(
      name: "Schema",
      dependencies: [
        .product(name: "SQLiteData", package: "sqlite-data"),
      ]
    ),
    .testTarget(
      name: "SchemaTests",
      dependencies: [
        "Schema",
      ]
    ),
  ]
)
