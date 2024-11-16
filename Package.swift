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
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.57.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
    ],
    
    targets: [
        .target(
            name: "MyToastersFramework",
            dependencies: ["SnapKit"],
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
