// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Letterpress",
    platforms: [.iOS(.v16), .macOS(.v14), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(
            name: "Letterpress",
            targets: ["Letterpress"]),
    ],
    dependencies: [
        .package(url: "https://github.com/lovetodream/swift-markdown-ui.git", branch: "main"),
//       .package(url: "https://github.com/gonzalezreal/swift-markdown-ui.git", from: "2.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Letterpress",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui")
            ]
        ),
        .testTarget(
            name: "LetterpressTests",
            dependencies: ["Letterpress"]
        ),
    ]
)
