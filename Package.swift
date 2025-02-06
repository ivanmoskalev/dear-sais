// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DearSAIS",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15)
    ],
    products: [
        .library(name: "DearSAIS", targets: ["DearSAIS"]),
    ],
    targets: [
        .target(name: "DearSAIS"),
        .testTarget(name: "DearSAISUnit", dependencies: ["DearSAIS"]),
        .testTarget(name: "DearSAISPerformance", dependencies: ["DearSAIS"]),
    ]
)
