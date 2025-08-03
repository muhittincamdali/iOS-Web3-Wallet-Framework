# Web3 Wallet Framework API Documentation

## Overview

The iOS Web3 Wallet Framework provides a comprehensive API for integrating Web3 wallet functionality into iOS applications. This document covers all public APIs, their parameters, return values, and usage examples.

## Table of Contents

1. [Core Classes](#core-classes)
2. [Wallet Management](#wallet-management)
3. [Transaction Management](#transaction-management)
4. [DeFi Integration](#defi-integration)
5. [Security Features](#security-features)
6. [Network Management](#network-management)
7. [Storage Management](#storage-management)
8. [Error Handling](#error-handling)

## Core Classes

### Web3WalletManager

The main entry point for wallet operations.

```swift
public class Web3WalletManager {
    public static let shared = Web3WalletManager()
    
    public init()
    public func createWallet(name: String, password: String) async throws -> Wallet
    public func importWallet(privateKey: String, name: String) async throws -> Wallet
    public func getWallets() async throws -> [Wallet]
    public func deleteWallet(_ wallet: Wallet) async throws
    public func signTransaction(_ transaction: Transaction, wallet: Wallet) async throws -> SignedTransaction
    public func sendTransaction(_ signedTransaction: SignedTransaction) async throws -> String
    public func getBalance(wallet: Wallet, chain: Blockchain) async throws -> String
    public func switchChain(_ chain: Blockchain) async throws
}
```

### Wallet

Represents a cryptocurrency wallet.

```swift
public struct Wallet: Codable, Equatable {
    public let id: String
    public let name: String
    public let address: String
    public let publicKey: String
    public let mnemonic: String?
    public let createdAt: Date
    public let isActive: Bool
    public let type: WalletType
    public let securityLevel: SecurityLevel
    public let supportedBlockchains: [Blockchain]
    public let metadata: [String: String]
    
    public var shortAddress: String { get }
    public var hasMnemonic: Bool { get }
    public var ageInDays: Int { get }
    public var isNew: Bool { get }
    
    public func validate() throws
    public mutating func updateLastUsed()
    public mutating func addMetadata(_ key: String, value: String)
    public mutating func removeMetadata(_ key: String)
    public func supportsBlockchain(_ blockchain: Blockchain) -> Bool
    public mutating func addNetworkSupport(_ blockchain: Blockchain)
    public mutating func removeNetworkSupport(_ blockchain: Blockchain)
}
```

### Transaction

Represents a blockchain transaction.

```swift
public struct Transaction: Codable, Equatable {
    public let from: String
    public let to: String
    public let value: String
    public let gasLimit: UInt64
    public let nonce: UInt64?
    public let data: Data?
    public let chain: Blockchain
    public let type: TransactionType
    
    public let id: String
    public let createdAt: Date
    public let status: TransactionStatus
    public let hash: String?
    public let blockNumber: UInt64?
    public let gasPrice: String?
    public let gasUsed: UInt64?
    public let fee: String?
    public let error: String?
    public let metadata: [String: String]
    
    public init(from: String, to: String, value: String, gasLimit: UInt64, chain: Blockchain)
    public func validate() throws
    public func estimateGas() async throws -> UInt64
    public func estimateFee() async throws -> String
}
```

### SignedTransaction

Represents a signed transaction ready for broadcasting.

```swift
public struct SignedTransaction: Codable, Equatable {
    public let rawTransaction: Data
    public let signature: String
    public let hash: String
    public let isValid: Bool
    public let createdAt: Date
    public let metadata: [String: String]
    
    public init(rawTransaction: Data, signature: String, hash: String)
    public func validate() throws
    public func broadcast() async throws -> String
}
```

## Wallet Management

### Creating a Wallet

```swift
let walletManager = Web3WalletManager()

do {
    let wallet = try await walletManager.createWallet(
        name: "My DeFi Wallet",
        password: "securePassword123"
    )
    print("Wallet created: \(wallet.address)")
} catch {
    print("Error creating wallet: \(error)")
}
```

### Importing a Wallet

```swift
do {
    let wallet = try await walletManager.importWallet(
        privateKey: "0x1234567890abcdef...",
        name: "Imported Wallet"
    )
    print("Wallet imported: \(wallet.address)")
} catch {
    print("Error importing wallet: \(error)")
}
```

### Getting All Wallets

```swift
do {
    let wallets = try await walletManager.getWallets()
    for wallet in wallets {
        print("Wallet: \(wallet.name) - \(wallet.shortAddress)")
    }
} catch {
    print("Error getting wallets: \(error)")
}
```

## Transaction Management

### Creating a Transaction

```swift
let transaction = Transaction(
    from: wallet.address,
    to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
    value: "0.1",
    gasLimit: 21000,
    chain: .ethereum
)
```

### Signing a Transaction

```swift
do {
    let signedTx = try await walletManager.signTransaction(
        transaction: transaction,
        wallet: wallet
    )
    print("Transaction signed: \(signedTx.hash)")
} catch {
    print("Error signing transaction: \(error)")
}
```

### Sending a Transaction

```swift
do {
    let txHash = try await walletManager.sendTransaction(signedTx)
    print("Transaction sent: \(txHash)")
} catch {
    print("Error sending transaction: \(error)")
}
```

### Getting Balance

```swift
do {
    let balance = try await walletManager.getBalance(
        wallet: wallet,
        chain: .ethereum
    )
    print("Balance: \(balance) ETH")
} catch {
    print("Error getting balance: \(error)")
}
```

## DeFi Integration

### DeFiManager

```swift
public class DeFiManager {
    public init()
    
    public func createSwapTransaction(_ request: SwapRequest) async throws -> Transaction
    public func createLiquidityTransaction(_ request: LiquidityRequest) async throws -> Transaction
    public func createLendingTransaction(_ request: LendingRequest) async throws -> Transaction
    public func getTokenPrice(_ token: String, chain: Blockchain) async throws -> String
    public func getPoolInfo(_ poolAddress: String, chain: Blockchain) async throws -> PoolInfo
}
```

### SwapRequest

```swift
public struct SwapRequest: Codable {
    public let fromToken: String
    public let toToken: String
    public let amount: String
    public let slippage: Double
    public let deadline: Date?
    public let recipient: String?
    
    public init(fromToken: String, toToken: String, amount: String, slippage: Double)
}
```

### Creating a Swap

```swift
let defiManager = DeFiManager()

do {
    let swapRequest = SwapRequest(
        fromToken: "ETH",
        toToken: "USDC",
        amount: "0.1",
        slippage: 0.5
    )
    
    let transaction = try await defiManager.createSwapTransaction(swapRequest)
    let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
    let txHash = try await walletManager.sendTransaction(signedTx)
    
    print("Swap completed: \(txHash)")
} catch {
    print("Error creating swap: \(error)")
}
```

## Security Features

### SecurityManager

```swift
public class SecurityManager {
    public static let shared = SecurityManager()
    
    public init()
    
    public func generateKeyPair() throws -> KeyPair
    public func encryptData(_ data: Data, with key: Data) throws -> Data
    public func decryptData(_ data: Data, with key: Data) throws -> Data
    public func storePrivateKey(_ privateKey: Data, for walletId: String) throws
    public func retrievePrivateKey(for walletId: String) throws -> Data
    public func authenticateWithBiometrics() async throws -> Bool
    public func validateAddress(_ address: String) -> Bool
}
```

### KeyPair

```swift
public struct KeyPair {
    public let privateKey: Data
    public let publicKey: Data
    public let address: String
    
    public init(privateKey: Data, publicKey: Data, address: String)
}
```

### Secure Storage Example

```swift
let securityManager = SecurityManager.shared

do {
    // Generate new key pair
    let keyPair = try securityManager.generateKeyPair()
    
    // Store private key securely
    try securityManager.storePrivateKey(keyPair.privateKey, for: wallet.id)
    
    // Authenticate with biometrics
    let authenticated = try await securityManager.authenticateWithBiometrics()
    if authenticated {
        let retrievedKey = try securityManager.retrievePrivateKey(for: wallet.id)
        print("Private key retrieved successfully")
    }
} catch {
    print("Security error: \(error)")
}
```

## Network Management

### NetworkManager

```swift
public class NetworkManager {
    public static let shared = NetworkManager()
    
    public init()
    
    public func configureNetworks(_ configs: [NetworkConfig])
    public func getNetworkConfig(for chain: Blockchain) -> NetworkConfig?
    public func switchToNetwork(_ chain: Blockchain) async throws
    public func getGasPrice(for chain: Blockchain) async throws -> String
    public func getNonce(for address: String, chain: Blockchain) async throws -> UInt64
    public func getTransactionReceipt(_ hash: String, chain: Blockchain) async throws -> TransactionReceipt
}
```

### NetworkConfig

```swift
public struct NetworkConfig {
    public let chainId: Int
    public let name: String
    public let rpcUrl: String
    public let explorerUrl: String
    public let nativeCurrency: NativeCurrency
    public let blockTime: TimeInterval
    
    public init(chainId: Int, name: String, rpcUrl: String, explorerUrl: String)
}
```

### Network Configuration Example

```swift
let networkManager = NetworkManager.shared

let ethereumConfig = NetworkConfig(
    chainId: 1,
    name: "Ethereum Mainnet",
    rpcUrl: "https://mainnet.infura.io/v3/YOUR_PROJECT_ID",
    explorerUrl: "https://etherscan.io"
)

let polygonConfig = NetworkConfig(
    chainId: 137,
    name: "Polygon Mainnet",
    rpcUrl: "https://polygon-rpc.com",
    explorerUrl: "https://polygonscan.com"
)

networkManager.configureNetworks([ethereumConfig, polygonConfig])
```

## Storage Management

### StorageManager

```swift
public class StorageManager {
    public static let shared = StorageManager()
    
    public init()
    
    public func saveWallet(_ wallet: Wallet) throws
    public func getWallet(id: String) throws -> Wallet?
    public func getAllWallets() throws -> [Wallet]
    public func deleteWallet(_ wallet: Wallet) throws
    public func saveTransaction(_ transaction: Transaction) throws
    public func getTransaction(id: String) throws -> Transaction?
    public func getTransactions(for walletId: String) throws -> [Transaction]
    public func deleteTransaction(_ transaction: Transaction) throws
    public func saveSettings(_ settings: [String: Any]) throws
    public func getSettings() throws -> [String: Any]
    public func clearCache() throws
    public func getStorageStatistics() throws -> StorageStatistics
}
```

### Storage Example

```swift
let storageManager = StorageManager.shared

do {
    // Save wallet
    try storageManager.saveWallet(wallet)
    
    // Retrieve wallet
    let retrievedWallet = try storageManager.getWallet(id: wallet.id)
    
    // Save transaction
    try storageManager.saveTransaction(transaction)
    
    // Get all transactions for wallet
    let transactions = try storageManager.getTransactions(for: wallet.id)
    
    // Save settings
    let settings = ["theme": "dark", "currency": "USD"]
    try storageManager.saveSettings(settings)
    
} catch {
    print("Storage error: \(error)")
}
```

## Error Handling

### WalletError

```swift
public enum WalletError: Error, LocalizedError {
    case invalidAddress
    case invalidPrivateKey
    case insufficientBalance
    case networkError(String)
    case authenticationFailed
    case encryptionFailed
    case decryptionFailed
    case storageError(String)
    case transactionFailed(String)
    case unsupportedChain
    case invalidTransaction
    case gasEstimationFailed
    case biometricNotAvailable
    case hardwareWalletNotConnected
    
    public var errorDescription: String? {
        switch self {
        case .invalidAddress:
            return "Invalid wallet address"
        case .invalidPrivateKey:
            return "Invalid private key"
        case .insufficientBalance:
            return "Insufficient balance for transaction"
        case .networkError(let message):
            return "Network error: \(message)"
        case .authenticationFailed:
            return "Authentication failed"
        case .encryptionFailed:
            return "Encryption failed"
        case .decryptionFailed:
            return "Decryption failed"
        case .storageError(let message):
            return "Storage error: \(message)"
        case .transactionFailed(let message):
            return "Transaction failed: \(message)"
        case .unsupportedChain:
            return "Unsupported blockchain"
        case .invalidTransaction:
            return "Invalid transaction"
        case .gasEstimationFailed:
            return "Gas estimation failed"
        case .biometricNotAvailable:
            return "Biometric authentication not available"
        case .hardwareWalletNotConnected:
            return "Hardware wallet not connected"
        }
    }
}
```

### Error Handling Example

```swift
do {
    let wallet = try await walletManager.createWallet(
        name: "My Wallet",
        password: "password"
    )
    
    let transaction = Transaction(
        from: wallet.address,
        to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
        value: "0.1",
        gasLimit: 21000,
        chain: .ethereum
    )
    
    let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
    let txHash = try await walletManager.sendTransaction(signedTx)
    
    print("Success: \(txHash)")
    
} catch WalletError.insufficientBalance {
    print("Insufficient balance for transaction")
} catch WalletError.networkError(let message) {
    print("Network error: \(message)")
} catch WalletError.authenticationFailed {
    print("Authentication failed")
} catch {
    print("Unexpected error: \(error)")
}
```

## Best Practices

### 1. Always Handle Errors

```swift
// Good
do {
    let wallet = try await walletManager.createWallet(name: "Wallet", password: "password")
} catch {
    // Handle specific errors
    switch error {
    case WalletError.authenticationFailed:
        // Handle authentication error
    case WalletError.encryptionFailed:
        // Handle encryption error
    default:
        // Handle other errors
    }
}

// Bad
let wallet = try! await walletManager.createWallet(name: "Wallet", password: "password")
```

### 2. Use Secure Storage

```swift
// Good
let securityManager = SecurityManager.shared
try securityManager.storePrivateKey(privateKey, for: wallet.id)

// Bad
UserDefaults.standard.set(privateKey, forKey: "privateKey")
```

### 3. Validate Inputs

```swift
// Good
guard let address = Address(hexString: inputAddress),
      address.isValid else {
    throw WalletError.invalidAddress
}

// Bad
let address = inputAddress // No validation
```

### 4. Use Async/Await

```swift
// Good
let balance = try await walletManager.getBalance(wallet: wallet, chain: .ethereum)

// Bad
walletManager.getBalance(wallet: wallet, chain: .ethereum) { result in
    // Handle result
}
```

### 5. Handle Network Errors

```swift
do {
    let transaction = try await walletManager.sendTransaction(signedTx)
} catch WalletError.networkError(let message) {
    // Retry logic or show user-friendly message
    print("Network error: \(message)")
    // Implement retry mechanism
} catch {
    print("Other error: \(error)")
}
```

## Performance Considerations

### 1. Batch Operations

```swift
// Good - Batch multiple operations
let wallets = try await walletManager.getWallets()
let balances = try await withThrowingTaskGroup(of: (String, String).self) { group in
    for wallet in wallets {
        group.addTask {
            let balance = try await walletManager.getBalance(wallet: wallet, chain: .ethereum)
            return (wallet.id, balance)
        }
    }
    
    var results: [(String, String)] = []
    for try await result in group {
        results.append(result)
    }
    return results
}
```

### 2. Caching

```swift
// Implement caching for frequently accessed data
class CacheManager {
    private var balanceCache: [String: (String, Date)] = [:]
    private let cacheExpiration: TimeInterval = 300 // 5 minutes
    
    func getCachedBalance(for walletId: String) -> String? {
        guard let (balance, timestamp) = balanceCache[walletId],
              Date().timeIntervalSince(timestamp) < cacheExpiration else {
            return nil
        }
        return balance
    }
    
    func cacheBalance(_ balance: String, for walletId: String) {
        balanceCache[walletId] = (balance, Date())
    }
}
```

### 3. Memory Management

```swift
// Use weak references to avoid retain cycles
class WalletViewController: UIViewController {
    private weak var walletManager: Web3WalletManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        walletManager = Web3WalletManager.shared
    }
}
```

## Testing

### Unit Tests

```swift
import XCTest
import Web3Wallet

class WalletManagerTests: XCTestCase {
    var walletManager: Web3WalletManager!
    
    override func setUp() {
        super.setUp()
        walletManager = Web3WalletManager()
    }
    
    func testWalletCreation() async throws {
        let wallet = try await walletManager.createWallet(
            name: "Test Wallet",
            password: "testPassword"
        )
        
        XCTAssertNotNil(wallet)
        XCTAssertEqual(wallet.name, "Test Wallet")
        XCTAssertTrue(wallet.isValid)
    }
    
    func testTransactionSigning() async throws {
        let wallet = try await walletManager.createWallet(
            name: "Test Wallet",
            password: "testPassword"
        )
        
        let transaction = Transaction(
            from: wallet.address,
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "0.1",
            gasLimit: 21000,
            chain: .ethereum
        )
        
        let signedTx = try await walletManager.signTransaction(
            transaction: transaction,
            wallet: wallet
        )
        
        XCTAssertNotNil(signedTx)
        XCTAssertTrue(signedTx.isValid)
    }
}
```

### Integration Tests

```swift
import XCTest
import Web3Wallet

class DeFiIntegrationTests: XCTestCase {
    var defiManager: DeFiManager!
    var walletManager: Web3WalletManager!
    
    override func setUp() {
        super.setUp()
        defiManager = DeFiManager()
        walletManager = Web3WalletManager()
    }
    
    func testUniswapIntegration() async throws {
        let swapRequest = SwapRequest(
            fromToken: "ETH",
            toToken: "USDC",
            amount: "0.1",
            slippage: 0.5
        )
        
        let transaction = try await defiManager.createSwapTransaction(swapRequest)
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction.to, "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D")
    }
}
```

## Migration Guide

### From v0.9.0 to v1.0.0

```swift
// Old API
let wallet = walletManager.createWalletSync(name: "Wallet", password: "password")

// New API
let wallet = try await walletManager.createWallet(name: "Wallet", password: "password")
```

### From v0.8.0 to v0.9.0

```swift
// Old API
let transaction = Transaction(from: from, to: to, value: value)

// New API
let transaction = Transaction(
    from: from,
    to: to,
    value: value,
    gasLimit: 21000,
    chain: .ethereum
)
```

## Troubleshooting

### Common Issues

1. **"Invalid Address" Error**
   - Ensure the address is a valid Ethereum address (42 characters, starts with 0x)
   - Check for proper checksum validation

2. **"Network Error"**
   - Verify internet connection
   - Check RPC endpoint configuration
   - Ensure API keys are valid

3. **"Authentication Failed"**
   - Verify biometric authentication is enabled
   - Check device supports biometric authentication
   - Ensure proper permissions are granted

4. **"Insufficient Balance"**
   - Check wallet balance before transaction
   - Account for gas fees in transaction amount
   - Verify correct network is selected

### Debug Mode

```swift
// Enable debug logging
Web3WalletConfig.shared.enableDebugMode()

// Check network status
let networkManager = NetworkManager.shared
let config = networkManager.getNetworkConfig(for: .ethereum)
print("RPC URL: \(config?.rpcUrl ?? "Not configured")")
```

## Support

For additional support:

- **Documentation**: [Full Documentation](Documentation/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/discussions)
- **Email**: support@web3wallet.com

---

*This documentation is maintained and updated regularly. For the latest version, please check the [GitHub repository](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework).* 