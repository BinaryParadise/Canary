// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Canary",
    platforms: [.macOS(.v10_15), .iOS(.v10)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "CanaryiOS", targets: ["CanaryiOS"]),
        .library(name: "CanaryCore", targets: ["CanaryCore"]),
        .library(name: "CanaryProto", targets: ["CanaryProto"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMinor(from: "5.0.0")),
        .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMinor(from: "4.0.0")),
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", .upToNextMinor(from: "5.1.0")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMinor(from: "5.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "CanaryiOS", dependencies: ["CanaryCore"]),
        .target(
            name: "CanaryCore",
            dependencies: ["Starscream", "CanaryProto", "SwiftyJSON", "SwifterSwift"],
            exclude: ["Configuration/ProjectConfigurator.rb"]),
        .target(name: "CanaryProto", dependencies: ["SwiftyJSON"])
    ]
)
