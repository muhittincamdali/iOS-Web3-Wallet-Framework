# 🚀 Getting Started Guide

<!-- TOC START -->
## Table of Contents
- [🚀 Getting Started Guide](#-getting-started-guide)
- [📋 Requirements](#-requirements)
- [⚡ Quick Installation](#-quick-installation)
  - [Swift Package Manager](#swift-package-manager)
  - [CocoaPods](#cocoapods)
- [🔧 Basic Setup](#-basic-setup)
- [📱 Create First Wallet](#-create-first-wallet)
- [🔐 Security Settings](#-security-settings)
- [📚 Next Steps](#-next-steps)
- [�� Help](#-help)
<!-- TOC END -->


## 📋 Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+
- CocoaPods or Swift Package Manager

## ⚡ Quick Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework", from: "1.0.0")
]
```

### CocoaPods

```ruby
pod 'iOS-Web3-Wallet-Framework', '~> 1.0.0'
```

## 🔧 Basic Setup

```swift
import Web3Wallet

// Initialize framework
Web3Wallet.initialize()

// Network configuration
let networkConfig = NetworkConfiguration()
networkConfig.addNetwork(.ethereum)
networkConfig.addNetwork(.polygon)
```

## 📱 Create First Wallet

```swift
// Create new wallet
let wallet = try Wallet.create()

// Get wallet address
let address = wallet.address

// Check balance
let balance = try await wallet.getBalance()
```

## 🔐 Security Settings

```swift
// Biometric authentication
let security = SecurityManager()
security.enableBiometricAuth()

// Secure storage
security.enableSecureStorage()
```

## 📚 Next Steps

- [Wallet Setup Guide](WalletSetup.md)
- [DeFi Integration Guide](DeFiIntegration.md)
- [Security Guide](SecurityGuide.md)
- [Performance Guide](PerformanceGuide.md)

## �� Help

If you encounter issues:
- [Issues](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/issues)
- [Discussions](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/discussions)
