// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SteamShortcutCreator",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "SteamShortcutCreator",
            targets: ["SteamShortcutCreator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.3.0")
    ],
    targets: [
        .executableTarget(
            name: "SteamShortcutCreator",
            dependencies: [
                .product(name: "ShellOut", package: "ShellOut")
            ],
            resources: [
                .copy("Resources")
            ]
        )
    ]
) 