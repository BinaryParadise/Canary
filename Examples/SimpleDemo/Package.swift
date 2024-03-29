// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleDemo",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "../.."),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", .upToNextMinor(from: "3.7.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "SimpleDemo",
            dependencies: [
                .product(name: "CanaryCore", package: "Canary"),
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
            ]),
        .testTarget(
            name: "SimpleDemoTests",
            dependencies: ["SimpleDemo"]),
    ]
)
