// swift-tools-version:5.6
import PackageDescription
let package = Package(
    name: "TokamakRouter",
	platforms: [.macOS(.v12), .iOS(.v14)],
    products: [
        .library(name: "TokamakRouter", targets: ["TokamakRouter"])
    ],
    dependencies: [
        .package(url: "https://github.com/TokamakUI/Tokamak", from: "0.11.0")
    ],
    targets: [
        .target(
            name: "TokamakRouter",
            dependencies: [
                .product(name: "TokamakShim", package: "Tokamak")
            ]),
        .testTarget(
            name: "TokamakRouterTests",
            dependencies: ["TokamakRouter"]),
    ]
)
