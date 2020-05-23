// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SwiftFX",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13)
    ],
    products: [
        .library(name: "SwiftFX",
                 targets: ["SwiftFX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hexagons/LiveValues.git", .exact("1.2.1")),
        .package(url: "https://github.com/hexagons/RenderKit.git", .exact("0.4.6")),
        .package(url: "https://github.com/hexagons/PixelKit.git", .exact("1.0.10")),
    ],
    targets: [
        .target(name: "SwiftFX",
                dependencies: [
                    "LiveValues",
                    "RenderKit",
                    "PixelKit",
                ]),
        .testTarget(name: "SwiftFXTests",
                    dependencies: ["SwiftFX"]),
    ]
)
