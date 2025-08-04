# 🚀 Getting Started

Welcome to the iOS Web3 Wallet Framework! This guide will help you get up and running in just 5 minutes.

## 📋 Prerequisites

Before you begin, ensure you have:

- **iOS 15.0+** or **macOS 12.0+**
- **Xcode 15.0+**
- **Swift 5.9+**
- Basic knowledge of Swift and iOS development

## ⚡ Quick Setup

### 1. Add the Framework

#### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework.git", from: "3.2.0")
]
```

Or add it directly in Xcode:

1. File → Add Package Dependencies
2. Enter: `https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework.git`
3. Select version: `3.2.0`

### 2. Import the Framework

```swift
import SwiftUI
import iOSWeb3WalletFramework
```

### 3. Create Your First Wallet

```swift
struct ContentView: View {
    @StateObject private var walletManager = WalletManager()
    
    var body: some View {
        VStack {
            if walletManager.isWalletCreated {
                Text("Wallet is ready!")
            } else {
                Button("Create Wallet") {
                    walletManager.createWallet { result in
                        switch result {
                        case .success(let wallet):
                            print("Wallet created: \(wallet.address)")
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    }
                }
            }
        }
    }
}
```

## 🎯 Basic Usage

### Wallet Management

```swift
// Create a new wallet
let walletManager = WalletManager()
walletManager.createWallet { result in
    switch result {
    case .success(let wallet):
        print("Wallet address: \(wallet.address)")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// Import existing wallet
walletManager.importWallet(privateKey: "0x...") { result in
    // Handle result
}
```

### Transaction Management

```swift
// Create transaction manager
let transactionManager = TransactionManager()

// Send a transaction
let transaction = Transaction(
    to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
    value: "0.1",
    network: .ethereum
)

transactionManager.sendTransaction(transaction) { result in
    switch result {
    case .success(let txHash):
        print("Transaction sent: \(txHash)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### DeFi Integration

```swift
// Create Uniswap manager
let uniswapManager = UniswapManager()

// Perform a swap
let swap = UniswapSwap(
    tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
    tokenOut: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
    amountIn: "1.0",
    slippageTolerance: 0.5,
    recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
    deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
)

uniswapManager.swap(swap) { result in
    switch result {
    case .success(let txHash):
        print("Swap completed: \(txHash)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

## 🔧 Configuration

### Network Selection

```swift
// Switch to different networks
try await transactionManager.switchNetwork(.polygon)
try await transactionManager.switchNetwork(.binanceSmartChain)
try await transactionManager.switchNetwork(.arbitrum)
```

### Custom RPC Endpoints

```swift
// Use custom RPC endpoint
let transactionManager = TransactionManager(
    network: .ethereum,
    customRPC: "https://mainnet.infura.io/v3/YOUR_PROJECT_ID"
)
```

## 🛡️ Security Setup

### Biometric Authentication

```swift
// Enable biometric authentication
let securityManager = SecurityManager()
securityManager.enableBiometricAuthentication()
```

### Hardware Wallet Support

```swift
// Connect hardware wallet
let hardwareWalletManager = HardwareWalletManager()
hardwareWalletManager.connectLedger { result in
    // Handle connection
}
```

## 📱 UI Components

### Pre-built Wallet UI

```swift
struct WalletView: View {
    @StateObject private var walletManager = WalletManager()
    
    var body: some View {
        VStack {
            // Wallet address display
            Text(walletManager.walletAddress)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Balance display
            Text("\(walletManager.balance) ETH")
                .font(.title)
                .fontWeight(.bold)
            
            // Send button
            Button("Send") {
                // Handle send action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

## 🧪 Testing

### Run Tests

```bash
# Run all tests
swift test

# Run specific test category
swift test --filter TransactionManagerTests
```

### Test Coverage

The framework includes comprehensive tests:
- ✅ Unit tests for all components
- ✅ Integration tests
- ✅ Performance tests
- ✅ Security tests

## 📚 Next Steps

1. **Explore Examples**: Check out the [Examples](../Examples/README.md) for complete sample applications
2. **Read Documentation**: Review the [API Documentation](API/README.md) for detailed reference
3. **Security Guidelines**: Read [Security Best Practices](Security.md) for production deployment
4. **Advanced Features**: Explore [DeFi Integration](API/DeFiProtocols.md) for advanced use cases

## 🆘 Need Help?

- **Documentation**: Check the main [README](../../README.md)
- **Issues**: Create an [Issue](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/issues)
- **Discussions**: Join [GitHub Discussions](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/discussions)

---

**Ready to build amazing Web3 apps?** Start with our examples and create something incredible! 🚀 