// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ClawInstaller",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "ClawInstaller", targets: ["ClawInstaller"])
    ],
    targets: [
        .executableTarget(
            name: "ClawInstaller",
            path: "Sources/ClawInstaller",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
    ]
)
