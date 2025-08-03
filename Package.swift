// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSWeb3WalletFramework",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        // Main framework product
        .library(
            name: "Web3Wallet",
            targets: ["Web3Wallet"]
        ),
        
        // Core wallet functionality
        .library(
            name: "Web3WalletCore",
            targets: ["Web3WalletCore"]
        ),
        
        // DeFi integration
        .library(
            name: "Web3WalletDeFi",
            targets: ["Web3WalletDeFi"]
        ),
        
        // Security components
        .library(
            name: "Web3WalletSecurity",
            targets: ["Web3WalletSecurity"]
        ),
        
        // UI components
        .library(
            name: "Web3WalletUI",
            targets: ["Web3WalletUI"]
        )
    ],
    dependencies: [
        // Crypto and security
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.0"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        
        // Network and HTTP
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        
        // JSON and serialization
        .package(url: "https://github.com/CoreOffice/XMLCoder.git", from: "0.17.0"),
        
        // Biometric authentication
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "20.0.0"),
        
        // QR code generation
        .package(url: "https://github.com/danielgindi/Charts.git", from: "4.1.0"),
        
        // Localization
        .package(url: "https://github.com/marmelroy/Localize-Swift.git", from: "3.2.0"),
        
        // Logging
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        
        // Testing
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.0.0")
    ],
    targets: [
        // Main Web3Wallet target
        .target(
            name: "Web3Wallet",
            dependencies: [
                "Web3WalletCore",
                "Web3WalletDeFi",
                "Web3WalletSecurity",
                "Web3WalletUI",
                "CryptoSwift",
                "BigInt",
                "Alamofire",
                "Kingfisher",
                "XMLCoder",
                "KeychainSwift",
                "Charts",
                "LocalizeSwift",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Web3Wallet",
            resources: [
                .process("Resources")
            ]
        ),
        
        // Core wallet functionality
        .target(
            name: "Web3WalletCore",
            dependencies: [
                "CryptoSwift",
                "BigInt",
                "Alamofire",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Core",
            resources: [
                .process("Resources")
            ]
        ),
        
        // DeFi integration
        .target(
            name: "Web3WalletDeFi",
            dependencies: [
                "Web3WalletCore",
                "Alamofire",
                "BigInt",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/DeFi"
        ),
        
        // Security components
        .target(
            name: "Web3WalletSecurity",
            dependencies: [
                "Web3WalletCore",
                "CryptoSwift",
                "KeychainSwift",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Security"
        ),
        
        // UI components
        .target(
            name: "Web3WalletUI",
            dependencies: [
                "Web3WalletCore",
                "Kingfisher",
                "Charts",
                "LocalizeSwift"
            ],
            path: "Sources/UI",
            resources: [
                .process("Resources")
            ]
        ),
        
        // Tests for main framework
        .testTarget(
            name: "Web3WalletTests",
            dependencies: [
                "Web3Wallet",
                "Quick",
                "Nimble"
            ],
            path: "Tests/Web3WalletTests"
        ),
        
        // Tests for core functionality
        .testTarget(
            name: "Web3WalletCoreTests",
            dependencies: [
                "Web3WalletCore",
                "Quick",
                "Nimble"
            ],
            path: "Tests/CoreTests"
        ),
        
        // Tests for DeFi functionality
        .testTarget(
            name: "Web3WalletDeFiTests",
            dependencies: [
                "Web3WalletDeFi",
                "Quick",
                "Nimble"
            ],
            path: "Tests/DeFiTests"
        ),
        
        // Tests for security functionality
        .testTarget(
            name: "Web3WalletSecurityTests",
            dependencies: [
                "Web3WalletSecurity",
                "Quick",
                "Nimble"
            ],
            path: "Tests/SecurityTests"
        ),
        
        // Tests for UI components
        .testTarget(
            name: "Web3WalletUITests",
            dependencies: [
                "Web3WalletUI",
                "Quick",
                "Nimble"
            ],
            path: "Tests/UITests"
        )
    ]
) 