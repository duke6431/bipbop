// swift-tools-version:5.10

/**
 *  BipBop
 *  Copyright (c) Duc Nguyen 2022
 *  Licensed under the MIT license. See LICENSE file.
 */
import PackageDescription

let package = Package(
    name: "BipBop",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "BipBop", targets: ["BipBop"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BipBop",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources"
        ),
    ]
)
