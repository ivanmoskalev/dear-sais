// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DearTemplate",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15)
    ],
    products: [
        .library(name: "DearTemplate", targets: ["DearTemplate"]),
    ],
    targets: [
        .target(name: "DearTemplate"),
        .testTarget(name: "DearTemplateUnit", dependencies: ["DearTemplate"]),
        .testTarget(name: "DearTemplatePerformance", dependencies: ["DearTemplate"]),
    ]
)
