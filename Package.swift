// swift-tools-version:5.6

/**
 *  Automation
 *  Copyright (c) Duc Nguyen 2022
 *  Licensed under the MIT license. See LICENSE file.
 */
import PackageDescription

let enableLogging = true

extension Target {
    static func loggable() -> [Target.Dependency] {
        enableLogging ? [Target.Dependency.product(name: "Logger", package: "Logger")] : []
    }
}

let package = Package(
    name: "Automation",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "Automation", type: .dynamic, targets: ["Automation"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(path: "../Logger")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Automation",
            dependencies: Target.loggable(),
            path: "Sources"),
        .testTarget(
            name: "AutomationTests",
            dependencies: ["Automation"],
            path: "AutomationTests"
        ),
    ]
)
