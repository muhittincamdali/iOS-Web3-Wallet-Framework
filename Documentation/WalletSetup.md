# 🔧 Wallet Setup Guide

<!-- TOC START -->
## Table of Contents
- [🔧 Wallet Setup Guide](#-wallet-setup-guide)
- [📋 Wallet Setup Options](#-wallet-setup-options)
  - [1. Create New Wallet](#1-create-new-wallet)
  - [2. Import Existing Wallet](#2-import-existing-wallet)
- [🔐 Security Setup](#-security-setup)
  - [Biometric Authentication](#biometric-authentication)
  - [Secure Storage](#secure-storage)
- [🌐 Network Configuration](#-network-configuration)
  - [Supported Networks](#supported-networks)
  - [Add Custom Network](#add-custom-network)
- [💰 Token Configuration](#-token-configuration)
  - [Add ERC-20 Token](#add-erc-20-token)
- [📊 Backup and Restore](#-backup-and-restore)
  - [Wallet Backup](#wallet-backup)
  - [Wallet Restore](#wallet-restore)
- [🔧 Advanced Settings](#-advanced-settings)
  - [Gas Settings](#gas-settings)
  - [Transaction Settings](#transaction-settings)
- [📱 UI Integration](#-ui-integration)
  - [Wallet Connection](#wallet-connection)
- [🚨 Error Handling](#-error-handling)
- [📚 Related Documentation](#-related-documentation)
<!-- TOC END -->


## 📋 Wallet Setup Options

### 1. Create New Wallet

```swift
// Create new wallet
let wallet = try Wallet.create()

// Get wallet information
let address = wallet.address
let privateKey = wallet.privateKey
let mnemonic = wallet.mnemonic
```

### 2. Import Existing Wallet

```swift
// Import with private key
let wallet = try Wallet.import(privateKey: "0x...")

// Import with mnemonic
let wallet = try Wallet.import(mnemonic: "word1 word2 word3...")

// Import with keystore file
let wallet = try Wallet.import(keystore: keystoreData, password: "password")
```

## 🔐 Security Setup

### Biometric Authentication

```swift
let security = SecurityManager()

// Enable Touch ID / Face ID
security.enableBiometricAuth()

// Authentication requirements
security.setAuthRequirement(.always)
```

### Secure Storage

```swift
// Use Keychain
security.enableKeychainStorage()

// Encryption level
security.setEncryptionLevel(.aes256)
```

## 🌐 Network Configuration

### Supported Networks

```swift
let networkConfig = NetworkConfiguration()

// Ethereum Mainnet
networkConfig.addNetwork(.ethereum)

// Polygon Mainnet
networkConfig.addNetwork(.polygon)

// Binance Smart Chain
networkConfig.addNetwork(.bsc)

// Arbitrum
networkConfig.addNetwork(.arbitrum)

// Optimism
networkConfig.addNetwork(.optimism)
```

### Add Custom Network

```swift
let customNetwork = Network(
    name: "Custom Network",
    chainId: 1337,
    rpcUrl: "https://your-rpc-url.com",
    explorerUrl: "https://your-explorer.com"
)

networkConfig.addCustomNetwork(customNetwork)
```

## 💰 Token Configuration

### Add ERC-20 Token

```swift
let tokenManager = TokenManager()

// Add USDT token
let usdt = Token(
    symbol: "USDT",
    name: "Tether USD",
    address: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
    decimals: 6
)

tokenManager.addToken(usdt, network: .ethereum)
```

## 📊 Backup and Restore

### Wallet Backup

```swift
// Backup mnemonic
let mnemonic = wallet.exportMnemonic()

// Backup private key (be careful!)
let privateKey = wallet.exportPrivateKey()

// Create keystore file
let keystore = try wallet.exportKeystore(password: "secure-password")
```

### Wallet Restore

```swift
// Restore with mnemonic
let restoredWallet = try Wallet.import(mnemonic: mnemonic)

// Restore with keystore
let restoredWallet = try Wallet.import(keystore: keystoreData, password: "password")
```

## 🔧 Advanced Settings

### Gas Settings

```swift
let gasConfig = GasConfiguration()

// Auto gas estimation
gasConfig.enableAutoGasEstimation()

// Manual gas settings
gasConfig.setGasPrice(20) // Gwei
gasConfig.setGasLimit(21000)
```

### Transaction Settings

```swift
let txConfig = TransactionConfiguration()

// Transaction timeout
txConfig.setTimeout(300) // 5 minutes

// Retry settings
txConfig.setRetryCount(3)
txConfig.setRetryDelay(5) // seconds
```

## 📱 UI Integration

### Wallet Connection

```swift
class WalletViewController: UIViewController {
    private let walletManager = WalletManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWallet()
    }
    
    private func setupWallet() {
        walletManager.delegate = self
        walletManager.connect()
    }
}

extension WalletViewController: WalletManagerDelegate {
    func walletDidConnect(_ wallet: Wallet) {
        // Wallet connected
        updateUI(with: wallet)
    }
    
    func walletDidDisconnect() {
        // Wallet disconnected
        showDisconnectAlert()
    }
}
```

## 🚨 Error Handling

```swift
do {
    let wallet = try Wallet.create()
} catch WalletError.invalidPrivateKey {
    // Invalid private key
} catch WalletError.invalidMnemonic {
    // Invalid mnemonic
} catch WalletError.networkError {
    // Network error
} catch {
    // Other errors
}
```

## 📚 Related Documentation

- [Getting Started Guide](GettingStarted.md)
- [Security Guide](SecurityGuide.md)
- [DeFi Integration Guide](DeFiIntegration.md)
- [Performance Guide](PerformanceGuide.md)
