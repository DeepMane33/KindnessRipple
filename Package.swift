// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KindnessRipple",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .executable(
            name: "KindnessRipple",
            targets: ["AppModule"]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            exclude: ["Watch"]
        )
    ]
)
