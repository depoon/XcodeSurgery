// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VariantEncryption",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_12)
    ],
    products: [
        .library(name: "VariantEncryption", targets: ["VariantEncryption"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.3.8"))
    ],
    targets: [
        .target(name: "VariantEncryption",
                dependencies: [
                    .product(name: "CryptoSwift", package: "CryptoSwift")
                ])
    ]
)
