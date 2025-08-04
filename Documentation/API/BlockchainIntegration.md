# 🌐 Blockchain Integration

The Blockchain Integration API provides comprehensive functionality for interacting with multiple blockchain networks, managing transactions, and handling gas optimization.

## 📋 Overview

The `TransactionManager` class is the core component for blockchain operations, offering:

- ✅ Multi-chain support (Ethereum, Polygon, BSC, Arbitrum, Optimism)
- ✅ Transaction creation and signing
- ✅ Gas optimization
- ✅ Network switching
- ✅ Transaction history
- ✅ Real-time updates

## 🚀 Quick Start

### Basic Transaction

```swift
import iOSWeb3WalletFramework

// Create transaction manager
let transactionManager = TransactionManager()

// Create a transaction
let transaction = Transaction(
    to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
    value: "0.1",
    network: .ethereum
)

// Send transaction
transactionManager.sendTransaction(transaction) { result in
    switch result {
    case .success(let txHash):
        print("Transaction sent: \(txHash)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### Network Switching

```swift
// Switch to different networks
try await transactionManager.switchNetwork(.polygon)
try await transactionManager.switchNetwork(.binanceSmartChain)
try await transactionManager.switchNetwork(.arbitrum)
```

## 📚 API Reference

### TransactionManager

The main class for blockchain operations.

#### Initialization

```swift
// Default initialization
let transactionManager = TransactionManager()

// Custom configuration
let transactionManager = TransactionManager(
    network: .ethereum,
    customRPC: "https://mainnet.infura.io/v3/YOUR_KEY",
    gasStrategy: .automatic
)
```

#### Properties

```swift
// Current network
let currentNetwork: BlockchainNetwork = transactionManager.currentNetwork

// Gas price
let gasPrice: BigUInt = transactionManager.gasPrice

// Transaction history
let transactionHistory: [Transaction] = transactionManager.transactionHistory

// Pending transactions
let pendingTransactions: [Transaction] = transactionManager.pendingTransactions
```

#### Methods

##### sendTransaction

Sends a transaction to the blockchain.

```swift
func sendTransaction(_ transaction: Transaction, completion: @escaping (Result<String, TransactionError>) -> Void)
```

**Parameters:**
- `transaction`: Transaction to send
- `completion`: Completion handler with result

**Returns:**
- Transaction hash on success
- `TransactionError` on failure

**Example:**
```swift
let transaction = Transaction(
    to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
    value: "0.1",
    gasLimit: 21000,
    network: .ethereum
)

transactionManager.sendTransaction(transaction) { result in
    switch result {
    case .success(let txHash):
        print("Transaction sent: \(txHash)")
    case .failure(let error):
        print("Failed to send transaction: \(error)")
    }
}
```

##### estimateGas

Estimates gas for a transaction.

```swift
func estimateGas(for transaction: Transaction) async throws -> BigUInt
```

**Example:**
```swift
let transaction = Transaction(
    to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
    value: "0.1",
    network: .ethereum
)

do {
    let gasLimit = try await transactionManager.estimateGas(for: transaction)
    print("Estimated gas: \(gasLimit)")
} catch {
    print("Gas estimation failed: \(error)")
}
```

##### getCurrentGasPrice

Gets current gas price for the network.

```swift
func getCurrentGasPrice() async throws -> BigUInt
```

**Example:**
```swift
do {
    let gasPrice = try await transactionManager.getCurrentGasPrice()
    print("Current gas price: \(gasPrice) wei")
} catch {
    print("Failed to get gas price: \(error)")
}
```

##### switchNetwork

Switches to a different blockchain network.

```swift
func switchNetwork(_ network: BlockchainNetwork) async throws
```

**Example:**
```swift
do {
    try await transactionManager.switchNetwork(.polygon)
    print("Switched to Polygon network")
} catch {
    print("Network switch failed: \(error)")
}
```

##### getTransactionStatus

Gets the status of a transaction.

```swift
func getTransactionStatus(_ txHash: String) async throws -> TransactionStatus
```

**Example:**
```swift
do {
    let status = try await transactionManager.getTransactionStatus("0x123...")
    print("Transaction status: \(status)")
} catch {
    print("Failed to get transaction status: \(error)")
}
```

##### getTransactionReceipt

Gets the receipt of a transaction.

```swift
func getTransactionReceipt(_ txHash: String) async throws -> TransactionReceipt
```

**Example:**
```swift
do {
    let receipt = try await transactionManager.getTransactionReceipt("0x123...")
    print("Gas used: \(receipt.gasUsed)")
    print("Block number: \(receipt.blockNumber)")
} catch {
    print("Failed to get transaction receipt: \(error)")
}
```

##### batchTransactions

Batches multiple transactions into a single transaction.

```swift
func batchTransactions(_ transactions: [Transaction]) async throws -> String
```

**Example:**
```swift
let transactions = [
    Transaction(to: "0x123...", value: "0.1", network: .ethereum),
    Transaction(to: "0x456...", value: "0.2", network: .ethereum)
]

do {
    let txHash = try await transactionManager.batchTransactions(transactions)
    print("Batch transaction sent: \(txHash)")
} catch {
    print("Batch transaction failed: \(error)")
}
```

## 🏗️ Data Models

### Transaction

Represents a blockchain transaction.

```swift
public struct Transaction: Identifiable, Codable {
    public let id = UUID()
    public let to: String
    public let value: String
    public let gasLimit: BigUInt?
    public let network: BlockchainNetwork
    public let data: Data?
    public let nonce: BigUInt?
}
```

**Properties:**
- `to`: Recipient address
- `value`: Amount to send
- `gasLimit`: Gas limit (optional, will be estimated)
- `network`: Blockchain network
- `data`: Additional transaction data
- `nonce`: Transaction nonce

### BlockchainNetwork

Supported blockchain networks.

```swift
public enum BlockchainNetwork: String, CaseIterable {
    case ethereum = "ethereum"
    case polygon = "polygon"
    case binanceSmartChain = "bsc"
    case arbitrum = "arbitrum"
    case optimism = "optimism"
}
```

**Properties:**
- `chainId`: Network chain ID
- `name`: Network name
- `defaultRPC`: Default RPC endpoint

### TransactionStatus

Transaction status enumeration.

```swift
public enum TransactionStatus: String, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case failed = "failed"
    case dropped = "dropped"
}
```

### TransactionReceipt

Transaction receipt information.

```swift
public struct TransactionReceipt: Codable {
    public let transactionHash: String
    public let blockNumber: BigUInt
    public let gasUsed: BigUInt
    public let status: TransactionStatus
    public let logs: [TransactionLog]
}
```

### GasStrategy

Gas estimation strategies.

```swift
public enum GasStrategy {
    case automatic
    case conservative
    case aggressive
    case custom(BigUInt)
}
```

## 🔧 Network Configuration

### Supported Networks

```swift
// Ethereum Mainnet
let ethereum = BlockchainNetwork.ethereum
// Chain ID: 1
// RPC: https://mainnet.infura.io/v3/YOUR_KEY

// Polygon
let polygon = BlockchainNetwork.polygon
// Chain ID: 137
// RPC: https://polygon-rpc.com

// Binance Smart Chain
let bsc = BlockchainNetwork.binanceSmartChain
// Chain ID: 56
// RPC: https://bsc-dataseed.binance.org

// Arbitrum
let arbitrum = BlockchainNetwork.arbitrum
// Chain ID: 42161
// RPC: https://arb1.arbitrum.io/rpc

// Optimism
let optimism = BlockchainNetwork.optimism
// Chain ID: 10
// RPC: https://mainnet.optimism.io
```

### Custom RPC Configuration

```swift
// Use custom RPC endpoint
let transactionManager = TransactionManager(
    network: .ethereum,
    customRPC: "https://mainnet.infura.io/v3/YOUR_PROJECT_ID"
)

// Use multiple RPC endpoints for redundancy
let transactionManager = TransactionManager(
    network: .ethereum,
    customRPC: "https://mainnet.infura.io/v3/YOUR_KEY",
    backupRPC: "https://eth-mainnet.alchemyapi.io/v2/YOUR_KEY"
)
```

## ⛽ Gas Optimization

### Automatic Gas Estimation

```swift
// Framework automatically estimates gas
let transaction = Transaction(
    to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
    value: "0.1",
    network: .ethereum
    // gasLimit will be estimated automatically
)

transactionManager.sendTransaction(transaction) { result in
    // Transaction sent with optimal gas
}
```

### Manual Gas Configuration

```swift
// Set custom gas limit
let transaction = Transaction(
    to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
    value: "0.1",
    gasLimit: 50000, // Custom gas limit
    network: .ethereum
)

// Use different gas strategies
let conservativeManager = TransactionManager(
    network: .ethereum,
    gasStrategy: .conservative
)

let aggressiveManager = TransactionManager(
    network: .ethereum,
    gasStrategy: .aggressive
)
```

### Gas Price Optimization

```swift
// Get current gas price
let gasPrice = try await transactionManager.getCurrentGasPrice()

// Use custom gas price
let transaction = Transaction(
    to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
    value: "0.1",
    gasLimit: 21000,
    network: .ethereum
)

// Set custom gas price
transactionManager.setCustomGasPrice(gasPrice * 2) // 2x current price
```

## 📱 UI Integration

### SwiftUI Integration

```swift
struct TransactionView: View {
    @StateObject private var transactionManager = TransactionManager()
    @State private var recipientAddress = ""
    @State private var amount = ""
    @State private var isSending = false
    
    var body: some View {
        VStack {
            TextField("Recipient Address", text: $recipientAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Amount (ETH)", text: $amount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            
            Button("Send Transaction") {
                sendTransaction()
            }
            .disabled(isSending || recipientAddress.isEmpty || amount.isEmpty)
            
            if isSending {
                ProgressView()
            }
        }
        .padding()
    }
    
    private func sendTransaction() {
        isSending = true
        
        let transaction = Transaction(
            to: recipientAddress,
            value: amount,
            network: transactionManager.currentNetwork
        )
        
        transactionManager.sendTransaction(transaction) { result in
            DispatchQueue.main.async {
                isSending = false
                
                switch result {
                case .success(let txHash):
                    print("Transaction sent: \(txHash)")
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
}
```

### Network Selection

```swift
struct NetworkSelectionView: View {
    @StateObject private var transactionManager = TransactionManager()
    
    var body: some View {
        VStack {
            Text("Select Network")
                .font(.headline)
            
            Picker("Network", selection: $transactionManager.currentNetwork) {
                ForEach(BlockchainNetwork.allCases, id: \.self) { network in
                    Text(network.name).tag(network)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: transactionManager.currentNetwork) { newNetwork in
                Task {
                    try await transactionManager.switchNetwork(newNetwork)
                }
            }
        }
        .padding()
    }
}
```

## 🧪 Testing

### Unit Tests

```swift
import XCTest
@testable import iOSWeb3WalletFramework

class TransactionManagerTests: XCTestCase {
    var transactionManager: TransactionManager!
    
    override func setUp() {
        super.setUp()
        transactionManager = TransactionManager()
    }
    
    func testTransactionCreation() {
        let transaction = Transaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "0.1",
            network: .ethereum
        )
        
        XCTAssertEqual(transaction.to, "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6")
        XCTAssertEqual(transaction.value, "0.1")
        XCTAssertEqual(transaction.network, .ethereum)
    }
    
    func testNetworkSwitching() async throws {
        try await transactionManager.switchNetwork(.polygon)
        XCTAssertEqual(transactionManager.currentNetwork, .polygon)
        
        try await transactionManager.switchNetwork(.ethereum)
        XCTAssertEqual(transactionManager.currentNetwork, .ethereum)
    }
    
    func testGasEstimation() async throws {
        let transaction = Transaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "0.1",
            network: .ethereum
        )
        
        let gasLimit = try await transactionManager.estimateGas(for: transaction)
        XCTAssertGreaterThan(gasLimit, 0)
    }
}
```

## 🚀 Best Practices

### Security Guidelines

1. **Validate all addresses before sending**
2. **Use appropriate gas limits**
3. **Handle network failures gracefully**
4. **Implement proper error handling**
5. **Use secure RPC endpoints**

### Performance Optimization

1. **Cache gas prices appropriately**
2. **Use background tasks for network operations**
3. **Implement proper retry logic**
4. **Optimize for memory usage**

### Error Handling

```swift
transactionManager.sendTransaction(transaction) { result in
    switch result {
    case .success(let txHash):
        print("Transaction sent: \(txHash)")
    case .failure(let error):
        switch error {
        case .invalidAddress(let address):
            print("Invalid address: \(address)")
        case .invalidAmount(let amount):
            print("Invalid amount: \(amount)")
        case .networkMismatch(let expected, let actual):
            print("Network mismatch: expected \(expected), got \(actual)")
        case .failed(let underlyingError):
            print("Transaction failed: \(underlyingError)")
        default:
            print("Unknown error: \(error)")
        }
    }
}
```

## 📚 Related Documentation

- [Wallet Management](WalletManagement.md)
- [DeFi Protocols](DeFiProtocols.md)
- [Security Features](SecurityFeatures.md)
- [Gas Optimization](GasOptimization.md)

---

**Need help?** Check our [Support Guide](../../README.md#support) or create an [Issue](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/issues). 