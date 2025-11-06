// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "OneThingPackage",
  platforms: [.iOS(.v26)],
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
      name: "ModelTransitions",
      targets: ["ModelTransitions"]
    ),
    .library(
      name: "NewList",
      targets: ["NewList"]
    ),
    .library(
      name: "NewTodo",
      targets: ["NewTodo"]
    ),
    .library(
      name: "Search",
      targets: ["Search"]
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
      name: "AppModels",
      targets: ["AppModels"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/groue/GRDB.swift", from: "7.6.0"),
    .package(url: "https://github.com/pointfreeco/sqlite-data", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.1"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.0"),
    .package(url: "https://github.com/pointfreeco/swift-nonempty", from: "0.4.0"),
  ],
  targets: [
    .target(
      name: "AppDatabase",
      dependencies: [
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppModels",
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
        "AppModels",
        "Utilities",
      ]
    ),
    .target(
      name: "AppModels",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        .product(name: "NonEmpty", package: "swift-nonempty"),
      ]
    ),
    .target(
      name: "CompletedDetail",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "ModelActions",
        "AppModels",
        "Utilities",
      ]
    ),
    .target(
      name: "Dashboard",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "AppModels",
        "ModelActions",
        "ModelTransitions",
        "NewList",
        "Search",
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
        "AppModels",
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
        "AppModels",
        "Utilities",
      ]
    ),
    .target(
      name: "InProgressDetail",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "AppModels",
        "ModelActions",
        "ModelTransitions",
        "Utilities",
      ]
    ),
    .testTarget(
      name: "InProgressDetailTests",
      dependencies: [
        "InProgressDetail",
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
      ]
    ),
    .target(
      name: "ListDetail",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "AppModels",
        "ModelActions",
        "ModelTransitions",
        "NewTodo",
        "Utilities",
      ]
    ),
    .target(
      name: "ModelActions",
      dependencies: [
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppModels",
        "Utilities",
      ]
    ),
    .testTarget(
      name: "ModelActionsTests",
      dependencies: [
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
        .product(name: "GRDB", package: "GRDB.swift"),
        "AppDatabase",
        "ModelActions",
        "AppModels",
        "Utilities",
      ]
    ),
    .target(
      name: "ModelTransitions",
      dependencies: [
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppModels",
        "ModelActions",
      ]
    ),
    .testTarget(
      name: "ModelTransitionsTests",
      dependencies: [
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
//        .product(name: "GRDB", package: "GRDB.swift"),
        "AppDatabase",
        "ModelTransitions",
//        "AppModels",
//        "Utilities",
      ]
    ),
    .target(
      name: "NewList",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "ModelActions",
        "AppModels",
        "Utilities",
      ]
    ),
    .target(
      name: "NewTodo",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "AppModels",
        "ModelActions",
        "Utilities",
      ]
    ),
    
    .target(
      name: "Search",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SQLiteData", package: "sqlite-data"),
        "AppDatabase",
        "AppModels",
        "ModelActions",
        "ModelTransitions",
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
        "AppModels",
        "Utilities",
      ]
    ),
    .target(
      name: "Utilities",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        "AppModels",
      ]
    ),
    .testTarget(
      name: "UtilitiesTests",
      dependencies: [
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
        "AppDatabase",
        "Utilities",
      ]
    ),
  ]
)
