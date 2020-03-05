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
//        .package(url: "https://github.com/hexagons/LiveValues.git", from: "1.1.7"),
//        .package(url: "https://github.com/hexagons/RenderKit.git", from: "0.3.5"),
//        .package(url: "https://github.com/hexagons/PixelKit.git", from: "0.9.9"),
        .package(path: "~/Code/Frameworks/Production/LiveValues"),
        .package(path: "~/Code/Frameworks/Production/RenderKit"),
        .package(path: "~/Code/Frameworks/Production/PixelKit"),
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
