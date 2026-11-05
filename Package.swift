// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "RudderIntegrationCleverTap",
    platforms: [.iOS(.v15)],
    products: [.library(name: "RudderIntegrationCleverTap", targets: ["RudderIntegrationCleverTap"])],
    dependencies: [.package(url: "https://github.com/rudderlabs/rudder-sdk-swift.git", from: "2.0.0"), .package(url: "https://github.com/CleverTap/clevertap-ios-sdk.git", .upToNextMajor(from: "7.8.1"))],
    targets: [.target(name: "RudderIntegrationCleverTap", dependencies: [.product(name: "RudderStackAnalytics", package: "rudder-sdk-swift"), .product(name: "CleverTapSDK", package: "clevertap-ios-sdk")])]
)
