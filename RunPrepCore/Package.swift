// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RunPrepCore",
    platforms: [.iOS("26.0"), .macOS("15.0")],
    products: [
        .library(name: "RunPrepCore", targets: ["RunPrepCore"])
    ],
    targets: [
        .target(name: "RunPrepCore"),
        .testTarget(name: "RunPrepCoreTests", dependencies: ["RunPrepCore"])
    ]
)
