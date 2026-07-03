// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TMDBUXLib",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TMDBUXLib",
            targets: ["TMDBUXLib"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/RustyKnight/TMDBLib-2.0",
            branch: "main"
        ),
        .package(
            url: "https://github.com/RustyKnight/ImageCacheLib-1.0",
            branch: "main"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TMDBUXLib",
            dependencies: [
                .product(name: "TMDBLib", package: "TMDBLib-2.0"),
                .product(name: "ImageCacheLib", package: "ImageCacheLib-1.0"),
            ]
        ),
        .testTarget(
            name: "TMDBUXLibTests",
            dependencies: [
                "TMDBUXLib",
                .product(name: "TMDBLib", package: "TMDBLib-2.0"),
                .product(name: "ImageCacheLib", package: "ImageCacheLib-1.0"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
