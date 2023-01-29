// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TinyFaces",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.68.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.6.0"),
        .package(url: "https://github.com/vapor/fluent-mysql-driver.git", from: "4.2.0"),
        .package(url: "https://github.com/nodes-vapor/gatekeeper.git", from: "4.2.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.2.4"),
        .package(url: "https://github.com/vapor-community/google-cloud-kit.git", from: "1.0.0-alpha.1"),
        .package(url: "https://github.com/vapor-community/stripe-kit.git", from: "17.0.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentMySQLDriver", package: "fluent-mysql-driver"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Gatekeeper", package: "gatekeeper"),
                .product(name: "GoogleCloudKit", package: "google-cloud-kit"),
                .product(name: "StripeKit", package: "stripe-kit"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .executableTarget(name: "Run", dependencies: [.target(name: "App")]),
    ]
)
