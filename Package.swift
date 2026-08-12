// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RudderIntegrationCleverTap",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RudderIntegrationCleverTap",
            targets: ["RudderIntegrationCleverTap"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CleverTap/clevertap-ios-sdk.git", .upToNextMajor(from: "7.8.1")),
        .package(url: "https://github.com/rudderlabs/rudder-sdk-swift.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RudderIntegrationCleverTap",
            dependencies: [
                .product(name: "CleverTapSDK", package: "clevertap-ios-sdk"),
                .product(name: "RudderStackAnalytics", package: "rudder-sdk-swift")
            ]
        ),
        .testTarget(
            name: "RudderIntegrationCleverTapTests",
            dependencies: ["RudderIntegrationCleverTap"]
        )
    ]
)
