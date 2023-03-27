// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "ytMusic",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "yt-music",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")],
            path: "Sources"),
    ]
)
