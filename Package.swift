// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSWeb3WalletFramework",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "iOSWeb3WalletFramework",
            targets: ["iOSWeb3WalletFramework"]
        ),
        .library(
            name: "Web3Core",
            targets: ["Web3Core"]
        ),
        .library(
            name: "BlockchainCore",
            targets: ["BlockchainCore"]
        ),
        .library(
            name: "WalletUI",
            targets: ["WalletUI"]
        ),
        .library(
            name: "WalletUtils",
            targets: ["WalletUtils"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "iOSWeb3WalletFramework",
            dependencies: [
                "Web3Core",
                "BlockchainCore",
                "WalletUI",
                "WalletUtils",
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            path: "Sources/Web3"
        ),
        .target(
            name: "Web3Core",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Collections", package: "swift-collections")
            ],
            path: "Sources/Web3"
        ),
        .target(
            name: "BlockchainCore",
            dependencies: [
                "Web3Core",
                .product(name: "Crypto", package: "swift-crypto")
            ],
            path: "Sources/Blockchain"
        ),
        .target(
            name: "WalletUI",
            dependencies: [
                "Web3Core",
                "BlockchainCore"
            ],
            path: "Sources/UI"
        ),
        .target(
            name: "WalletUtils",
            dependencies: [
                "Web3Core",
                .product(name: "Crypto", package: "swift-crypto")
            ],
            path: "Sources/Utils"
        ),
        .testTarget(
            name: "iOSWeb3WalletFrameworkTests",
            dependencies: [
                "iOSWeb3WalletFramework",
                "Web3Core",
                "BlockchainCore",
                "WalletUI",
                "WalletUtils"
            ],
            path: "Tests"
        )
    ]
) 