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
        .library(name: "VariantEncryption", targets: ["VariantEncryption"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.3.8"))
    ],
    targets: [
        .target(
            name: "XcodeSurgery-CLI",
            dependencies: [
                "VariantEncryption",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .target(
            name: "XcodeSurgeryKit",
            dependencies: [
                "VariantEncryption",
                .product(name: "CryptoSwift", package: "CryptoSwift")
            ]),
        .target(
            name: "VariantEncryption",
            dependencies: [
                .product(name: "CryptoSwift", package: "CryptoSwift")
            ]),
//        .testTarget(
//            name: "XcodeSurgeryTests",
//            dependencies: ["XcodeSurgery"]),
    ]
)
