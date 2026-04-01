// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Moya",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(name: "Moya", targets: ["Moya"]),
        .library(name: "CombineMoya", targets: ["CombineMoya"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(
            name: "Moya",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire")
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "CombineMoya",
            dependencies: [
                "Moya"
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
