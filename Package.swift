// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GTFSModel",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GTFSModel",
            targets: ["GTFSModel"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "GRDB", url: "https://github.com/groue/GRDB.swift.git", from: "4.13.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GTFSModel",
            dependencies: ["GRDB"]),
        .testTarget(
            name: "GTFSModelTests",
            dependencies: ["GTFSModel"]),
    ]
)
