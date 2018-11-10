// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TILApp",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        // PostgreSQL
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.1"),
        // Leaf
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.1")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Authentication", "Vapor", "Leaf"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

