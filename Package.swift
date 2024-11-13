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
    
    dependencies: [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.57.0")
    ],
    
    targets: [
        .target(
            name: "MyToastersFramework",
            path: "Sources",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
        .testTarget(
            name: "MyToastersFrameworkTests",
            dependencies: ["MyToastersFramework"],
            path: "Tests/MyToastersFrameworkTests",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
    ]
)
