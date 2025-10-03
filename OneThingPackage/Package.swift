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
      name: "Dashboard",
      targets: ["Dashboard"]
    ),
    .library(
      name: "ModelActions",
      targets: ["ModelActions"]
    ),
    .library(
      name: "Utilities",
      targets: ["Utilities"]
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
        .product(name: "SQLiteData", package: "sqlite-data"),
        "Schema",
      ]
    ),
    .target(
      name: "AppFeature",
      dependencies: [
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "Dashboard",
        "Schema",
      ]
    ),
    .target(
      name: "Dashboard",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "ModelActions",
        "Schema",
        "Utilities",
      ]
    ),
    .testTarget(
      name: "DashboardTests",
      dependencies: [
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
        "AppDatabase",
        "Dashboard",
        "ModelActions",
        "Schema",
        "Utilities",
      ]
    ),
    .target(
      name: "ModelActions",
      dependencies: [
        .product(name: "SQLiteData", package: "sqlite-data"),
        "Schema",
      ]
    ),
    .testTarget(
      name: "ModelActionsTests",
      dependencies: [
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
        .product(name: "GRDB", package: "GRDB.swift"),
        "AppDatabase",
        "ModelActions",
        "Schema",
        "Utilities",
      ]
    ),
    .target(
      name: "Utilities",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        "Schema",
      ]
    ),
    .testTarget(
      name: "UtilitiesTests",
      dependencies: [
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
        "AppDatabase",
        "Utilities",
      ]
    ),
    .target(
      name: "Schema",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
      ]
    ),
  ]
)
