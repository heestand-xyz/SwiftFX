// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SwiftFX",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "SwiftFX",
                 targets: ["SwiftFX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/heestand-xyz/RenderKit", from: "1.0.0"),
        .package(url: "https://github.com/heestand-xyz/PixelKit", from: "2.0.3"),
        .package(url: "https://github.com/heestand-xyz/PixelColor", from: "1.2.3"),
    ],
    targets: [
        .target(name: "SwiftFX",
                dependencies: [
                    "RenderKit",
                    "PixelKit",
                    "PixelColor",
                ]),
    ]
)
