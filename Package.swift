// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyToastersFramework",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "MyToastersFramework",
            targets: ["MyToastersFramework"]),
    ],
    targets: [
        .target(
            name: "MyToastersFramework",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "MyToastersFrameworkTests",
            dependencies: ["MyToastersFramework"],
            path: "Tests/MyToastersFrameworkTests"
        ),
    ]
)
