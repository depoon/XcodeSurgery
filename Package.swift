// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XcodeSurgery",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v13)
    ],
    products: [
        .executable(name: "xcodesurgery", targets: ["XcodeSurgery-CLI"]),
        .library(name: "XcodeSurgeryKit", targets: ["XcodeSurgeryKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.3.8")),
        .package(path: "Sources/VariantEncryption")
    ],
    targets: [
        .target(
            name: "XcodeSurgery-CLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "VariantEncryption", package: "VariantEncryption")
            ]),
        .target(
            name: "XcodeSurgeryKit",
            dependencies: [
                .product(name: "VariantEncryption", package: "VariantEncryption")
            ]),
//        .testTarget(
//            name: "XcodeSurgeryTests",
//            dependencies: ["XcodeSurgery"]),
    ]
)
