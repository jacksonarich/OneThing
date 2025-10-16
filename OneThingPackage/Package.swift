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
      name: "CompletedDetail",
      targets: ["CompletedDetail"]
    ),
    .library(
      name: "Dashboard",
      targets: ["Dashboard"]
    ),
    .library(
      name: "DeletedDetail",
      targets: ["DeletedDetail"]
    ),
    .library(
      name: "InProgressDetail",
      targets: ["InProgressDetail"]
    ),
    .library(
      name: "ListDetail",
      targets: ["ListDetail"]
    ),
    .library(
      name: "ModelActions",
      targets: ["ModelActions"]
    ),
    .library(
      name: "NewList",
      targets: ["NewList"]
    ),
    .library(
      name: "ScheduledDetail",
      targets: ["ScheduledDetail"]
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
        "CompletedDetail",
        "Dashboard",
        "DeletedDetail",
        "InProgressDetail",
        "ListDetail",
        "ScheduledDetail",
        "Schema",
        "Utilities",
      ]
    ),
    .target(
      name: "CompletedDetail",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "ModelActions",
        "Schema",
        "Utilities",
      ]
    ),
    .target(
      name: "Dashboard",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "ModelActions",
        "NewList",
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
      name: "DeletedDetail",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "ModelActions",
        "Schema",
        "Utilities",
      ]
    ),
    .target(
      name: "InProgressDetail",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "ModelActions",
        "Schema",
        "Utilities",
      ]
    ),
    .target(
      name: "ListDetail",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
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
      name: "NewList",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "ModelActions",
        "Schema",
        "Utilities",
      ]
    ),
    .target(
      name: "ScheduledDetail",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "ModelActions",
        "Schema",
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
  ]
)
