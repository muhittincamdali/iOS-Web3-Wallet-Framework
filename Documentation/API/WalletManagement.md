# 🔐 Wallet Management

The Wallet Management API provides comprehensive functionality for creating, importing, and managing cryptocurrency wallets in your iOS applications.

## 📋 Overview

The `WalletManager` class is the core component for wallet operations, offering:

- ✅ Secure wallet creation
- ✅ Private key import
- ✅ Multi-account support
- ✅ Balance management
- ✅ Transaction history
- ✅ Backup and recovery

## 🚀 Quick Start

### Basic Wallet Creation

```swift
import iOSWeb3WalletFramework

// Create wallet manager
let walletManager = WalletManager()

// Create new wallet
walletManager.createWallet { result in
    switch result {
    case .success(let wallet):
        print("Wallet created: \(wallet.address)")
        print("Private key: \(wallet.privateKey)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### Import Existing Wallet

```swift
// Import wallet with private key
walletManager.importWallet(privateKey: "0x1234567890abcdef...") { result in
    switch result {
    case .success(let wallet):
        print("Wallet imported: \(wallet.address)")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// Import wallet with mnemonic
walletManager.importWallet(mnemonic: "word1 word2 word3...") { result in
    switch result {
    case .success(let wallet):
        print("Wallet imported: \(wallet.address)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

## 📚 API Reference

### WalletManager

The main class for wallet operations.

#### Initialization

```swift
// Default initialization
let walletManager = WalletManager()

// Custom configuration
let walletManager = WalletManager(
    network: .ethereum,
    securityLevel: .high,
    enableBiometrics: true
)
```

#### Properties

```swift
// Check if wallet exists
let isWalletCreated: Bool = walletManager.isWalletCreated

// Get wallet address
let address: String = walletManager.walletAddress

// Get wallet balance
let balance: String = walletManager.balance

// Get transaction history
let transactions: [Transaction] = walletManager.transactionHistory
```

#### Methods

##### createWallet

Creates a new wallet with secure key generation.

```swift
func createWallet(completion: @escaping (Result<Wallet, WalletError>) -> Void)
```

**Parameters:**
- `completion`: Completion handler with result

**Returns:**
- `Wallet` object on success
- `WalletError` on failure

**Example:**
```swift
walletManager.createWallet { result in
    switch result {
    case .success(let wallet):
        print("Wallet created successfully")
        print("Address: \(wallet.address)")
    case .failure(let error):
        print("Failed to create wallet: \(error)")
    }
}
```

##### importWallet

Imports an existing wallet using private key or mnemonic.

```swift
func importWallet(privateKey: String, completion: @escaping (Result<Wallet, WalletError>) -> Void)
func importWallet(mnemonic: String, completion: @escaping (Result<Wallet, WalletError>) -> Void)
```

**Parameters:**
- `privateKey`: Private key in hex format
- `mnemonic`: BIP-39 mnemonic phrase
- `completion`: Completion handler with result

**Example:**
```swift
// Import with private key
walletManager.importWallet(privateKey: "0x1234567890abcdef...") { result in
    switch result {
    case .success(let wallet):
        print("Wallet imported: \(wallet.address)")
    case .failure(let error):
        print("Import failed: \(error)")
    }
}

// Import with mnemonic
walletManager.importWallet(mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about") { result in
    switch result {
    case .success(let wallet):
        print("Wallet imported: \(wallet.address)")
    case .failure(let error):
        print("Import failed: \(error)")
    }
}
```

##### getBalance

Retrieves the current balance for the wallet.

```swift
func getBalance(completion: @escaping (Result<String, WalletError>) -> Void)
```

**Example:**
```swift
walletManager.getBalance { result in
    switch result {
    case .success(let balance):
        print("Balance: \(balance) ETH")
    case .failure(let error):
        print("Failed to get balance: \(error)")
    }
}
```

##### exportWallet

Exports wallet data for backup.

```swift
func exportWallet(completion: @escaping (Result<WalletExport, WalletError>) -> Void)
```

**Example:**
```swift
walletManager.exportWallet { result in
    switch result {
    case .success(let export):
        print("Private key: \(export.privateKey)")
        print("Mnemonic: \(export.mnemonic)")
    case .failure(let error):
        print("Export failed: \(error)")
    }
}
```

##### deleteWallet

Deletes the current wallet and all associated data.

```swift
func deleteWallet(completion: @escaping (Result<Void, WalletError>) -> Void)
```

**Example:**
```swift
walletManager.deleteWallet { result in
    switch result {
    case .success:
        print("Wallet deleted successfully")
    case .failure(let error):
        print("Delete failed: \(error)")
    }
}
```

## 🏗️ Data Models

### Wallet

Represents a cryptocurrency wallet.

```swift
public struct Wallet: Codable {
    public let address: String
    public let privateKey: String
    public let mnemonic: String?
    public let network: BlockchainNetwork
    public let createdAt: Date
    public let isBackedUp: Bool
}
```

**Properties:**
- `address`: Wallet address in hex format
- `privateKey`: Private key (encrypted in storage)
- `mnemonic`: BIP-39 mnemonic phrase (optional)
- `network`: Blockchain network
- `createdAt`: Wallet creation timestamp
- `isBackedUp`: Backup status

### WalletExport

Export data for wallet backup.

```swift
public struct WalletExport: Codable {
    public let privateKey: String
    public let mnemonic: String?
    public let address: String
    public let network: BlockchainNetwork
    public let exportDate: Date
}
```

### WalletError

Error types for wallet operations.

```swift
public enum WalletError: Error, LocalizedError {
    case invalidPrivateKey(String)
    case invalidMnemonic(String)
    case walletAlreadyExists
    case walletNotFound
    case insufficientFunds
    case networkError(String)
    case securityError(String)
    case backupFailed(String)
}
```

## 🔐 Security Features

### Biometric Authentication

```swift
// Enable biometric authentication
walletManager.enableBiometricAuthentication()

// Check if biometrics are available
let isBiometricsAvailable = walletManager.isBiometricsAvailable

// Authenticate before sensitive operations
walletManager.authenticateWithBiometrics { result in
    switch result {
    case .success:
        // Proceed with operation
        walletManager.exportWallet { /* ... */ }
    case .failure(let error):
        print("Authentication failed: \(error)")
    }
}
```

### Hardware Wallet Support

```swift
// Connect hardware wallet
let hardwareWalletManager = HardwareWalletManager()
hardwareWalletManager.connectLedger { result in
    switch result {
    case .success(let wallet):
        print("Hardware wallet connected: \(wallet.address)")
    case .failure(let error):
        print("Connection failed: \(error)")
    }
}
```

### Encrypted Storage

All sensitive data is automatically encrypted using iOS Keychain:

```swift
// Private keys are automatically encrypted
let wallet = walletManager.currentWallet
// wallet.privateKey is encrypted in storage

// Access requires authentication
walletManager.getPrivateKey { result in
    switch result {
    case .success(let privateKey):
        // Use private key for signing
    case .failure(let error):
        print("Failed to access private key: \(error)")
    }
}
```

## 📱 UI Integration

### SwiftUI Integration

```swift
struct WalletView: View {
    @StateObject private var walletManager = WalletManager()
    @State private var showingCreateWallet = false
    @State private var showingImportWallet = false
    
    var body: some View {
        VStack {
            if walletManager.isWalletCreated {
                // Wallet dashboard
                VStack {
                    Text("Wallet Address")
                        .font(.headline)
                    Text(walletManager.walletAddress)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Balance")
                        .font(.headline)
                    Text("\(walletManager.balance) ETH")
                        .font(.title)
                        .fontWeight(.bold)
                }
            } else {
                // Wallet creation/import
                VStack {
                    Button("Create New Wallet") {
                        showingCreateWallet = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Import Existing Wallet") {
                        showingImportWallet = true
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .sheet(isPresented: $showingCreateWallet) {
            CreateWalletView()
        }
        .sheet(isPresented: $showingImportWallet) {
            ImportWalletView()
        }
    }
}
```

### UIKit Integration

```swift
class WalletViewController: UIViewController {
    private let walletManager = WalletManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWalletManager()
    }
    
    private func setupWalletManager() {
        walletManager.createWallet { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wallet):
                    self?.showWalletDashboard(wallet)
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
}
```

## 🧪 Testing

### Unit Tests

```swift
import XCTest
@testable import iOSWeb3WalletFramework

class WalletManagerTests: XCTestCase {
    var walletManager: WalletManager!
    
    override func setUp() {
        super.setUp()
        walletManager = WalletManager()
    }
    
    func testWalletCreation() {
        let expectation = XCTestExpectation(description: "Wallet creation")
        
        walletManager.createWallet { result in
            switch result {
            case .success(let wallet):
                XCTAssertFalse(wallet.address.isEmpty)
                XCTAssertEqual(wallet.network, .ethereum)
            case .failure(let error):
                XCTFail("Wallet creation failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWalletImport() {
        let expectation = XCTestExpectation(description: "Wallet import")
        
        walletManager.importWallet(privateKey: "0x1234567890abcdef...") { result in
            switch result {
            case .success(let wallet):
                XCTAssertEqual(wallet.address, "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6")
            case .failure(let error):
                XCTFail("Wallet import failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
```

## 🚀 Best Practices

### Security Guidelines

1. **Never store private keys in plain text**
2. **Use hardware wallets for large amounts**
3. **Implement proper backup procedures**
4. **Validate all user inputs**
5. **Handle errors without exposing sensitive information**

### Performance Optimization

1. **Cache wallet data appropriately**
2. **Use background tasks for balance updates**
3. **Implement proper error handling**
4. **Optimize for memory usage**

### Error Handling

```swift
walletManager.createWallet { result in
    switch result {
    case .success(let wallet):
        // Handle success
        print("Wallet created: \(wallet.address)")
    case .failure(let error):
        // Handle specific errors
        switch error {
        case .walletAlreadyExists:
            print("Wallet already exists")
        case .networkError(let message):
            print("Network error: \(message)")
        case .securityError(let message):
            print("Security error: \(message)")
        default:
            print("Unknown error: \(error)")
        }
    }
}
```

## 📚 Related Documentation

- [Transaction Management](TransactionManagement.md)
- [Security Features](SecurityFeatures.md)
- [Hardware Wallet Integration](HardwareWallets.md)
- [Backup and Recovery](BackupRecovery.md)

---

**Need help?** Check our [Support Guide](../../README.md#support) or create an [Issue](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/issues). 