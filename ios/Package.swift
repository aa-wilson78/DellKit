// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DellKit",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "DellKit", targets: ["DellKit"]),
    ],
    targets: [
        .target(name: "DellKit", path: "Sources/DellKit"),
    ]
)
