// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "spm-ignore-warnings",
    products: [
        .executable(name: "Ignore", targets: ["Ignore"]),
		.library(name: "IgnoreConfig", targets: ["IgnoreConfig"]),
    ],
    dependencies: [
		.package(url: "https://github.com/AdevintaSpain/spm-PackageConfig.git", from: "0.0.1"),
//        .package(path: "../spm-PackageConfig"),
		.package(url: "https://github.com/f-meloni/Logger", from: "0.1.0"),
		.package(url: "https://github.com/tuist/xcodeproj.git", from: "6.6.0"),
		.package(url: "https://github.com/kylef/PathKit", from: "0.9.2"),

//		.package(url: "https://github.com/f-meloni/Rocket", from: "0.0.1"), // dev
    ],
    targets: [
        .executableTarget(name: "Ignore", dependencies: [
			"Logger",
			"xcodeproj",
			"PathKit",
			"IgnoreConfig",
		]),
		.target(
            name: "IgnoreConfig",
            dependencies: [
                .product(name: "PackageConfig", package: "spm-PackageConfig"),
            ]
        ),
		.target(name: "PackageConfigs", dependencies: ["IgnoreConfig"]),
    ]
)

#if canImport(IgnoreConfig)
import IgnoreConfig

IgnoreConfig(excludedTargets: ["PackageConfigs"]).write()
#endif
