# Transaction API Documentation

## Overview

The Transaction API provides comprehensive transaction management capabilities for Web3 wallet applications, including transaction creation, signing, broadcasting, monitoring, and advanced transaction features. This API is designed for high performance and reliability.

## Table of Contents

- [Transaction Creation](#transaction-creation)
- [Transaction Signing](#transaction-signing)
- [Transaction Broadcasting](#transaction-broadcasting)
- [Transaction Monitoring](#transaction-monitoring)
- [Gas Management](#gas-management)
- [Transaction History](#transaction-history)
- [Batch Transactions](#batch-transactions)
- [Advanced Features](#advanced-features)

## Transaction Creation

### TransactionManager

```swift
public class TransactionManager: ObservableObject {
    @Published public var pendingTransactions: [Transaction]
    @Published public var recentTransactions: [Transaction]
    
    public func createTransaction(
        to: String,
        value: String,
        gasLimit: Int? = nil,
        gasPrice: String? = nil,
        data: String = "0x"
    ) async throws -> Transaction {
        // Create new transaction
    }
    
    public func createTokenTransaction(
        tokenAddress: String,
        to: String,
        amount: String,
        gasLimit: Int? = nil,
        gasPrice: String? = nil
    ) async throws -> Transaction {
        // Create token transaction
    }
    
    public func createContractTransaction(
        contractAddress: String,
        method: String,
        parameters: [String],
        gasLimit: Int? = nil,
        gasPrice: String? = nil
    ) async throws -> Transaction {
        // Create contract transaction
    }
}
```

### Transaction

```swift
public struct Transaction {
    public let from: String
    public let to: String
    public let value: String
    public let gasLimit: Int
    public let gasPrice: String
    public let nonce: Int
    public let data: String
    public let chainId: Int
    public let network: BlockchainNetwork
    
    public var estimatedGas: Int?
    public var maxFeePerGas: String?
    public var maxPriorityFeePerGas: String?
    
    public init(
        from: String,
        to: String,
        value: String,
        gasLimit: Int,
        gasPrice: String,
        nonce: Int,
        data: String = "0x",
        chainId: Int,
        network: BlockchainNetwork
    ) {
        self.from = from
        self.to = to
        self.value = value
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.nonce = nonce
        self.data = data
        self.chainId = chainId
        self.network = network
    }
}
```

### TransactionBuilder

```swift
public class TransactionBuilder {
    public func buildTransaction(
        to: String,
        value: String
    ) -> TransactionBuilder {
        // Start building transaction
    }
    
    public func withGasLimit(_ gasLimit: Int) -> TransactionBuilder {
        // Set gas limit
    }
    
    public func withGasPrice(_ gasPrice: String) -> TransactionBuilder {
        // Set gas price
    }
    
    public func withData(_ data: String) -> TransactionBuilder {
        // Set transaction data
    }
    
    public func withNonce(_ nonce: Int) -> TransactionBuilder {
        // Set nonce
    }
    
    public func build() async throws -> Transaction {
        // Build final transaction
    }
}
```

## Transaction Signing

### TransactionSigner

```swift
public class TransactionSigner {
    public func signTransaction(
        transaction: Transaction,
        privateKey: String
    ) async throws -> String {
        // Sign transaction with private key
    }
    
    public func signTransactionWithHardwareWallet(
        transaction: Transaction,
        hardwareWallet: HardwareWallet
    ) async throws -> String {
        // Sign transaction with hardware wallet
    }
    
    public func signMessage(
        message: String,
        privateKey: String
    ) async throws -> String {
        // Sign message
    }
    
    public func verifySignature(
        message: String,
        signature: String,
        publicKey: String
    ) async throws -> Bool {
        // Verify signature
    }
}
```

### Signature

```swift
public struct Signature {
    public let r: String
    public let s: String
    public let v: Int
    
    public var signature: String {
        // Combine r, s, v into signature
    }
    
    public init(r: String, s: String, v: Int) {
        self.r = r
        self.s = s
        self.v = v
    }
}
```

## Transaction Broadcasting

### TransactionBroadcaster

```swift
public class TransactionBroadcaster: ObservableObject {
    @Published public var isBroadcasting: Bool
    @Published public var broadcastProgress: Double
    
    public func broadcastTransaction(
        signedTransaction: String,
        network: BlockchainNetwork
    ) async throws -> String {
        // Broadcast signed transaction
    }
    
    public func broadcastWithRetry(
        signedTransaction: String,
        network: BlockchainNetwork,
        maxRetries: Int = 3
    ) async throws -> String {
        // Broadcast with retry mechanism
    }
    
    public func validateTransaction(
        transaction: Transaction,
        beforeBroadcast: Bool = true
    ) async throws -> Bool {
        // Validate transaction before broadcasting
    }
}
```

### BroadcastResult

```swift
public struct BroadcastResult {
    public let transactionHash: String
    public let network: BlockchainNetwork
    public let timestamp: Date
    public let status: BroadcastStatus
    public let error: String?
}

public enum BroadcastStatus {
    case pending
    case confirmed
    case failed
    case dropped
}
```

## Transaction Monitoring

### TransactionMonitor

```swift
public class TransactionMonitor: ObservableObject {
    @Published public var transactionStatus: [String: TransactionStatus]
    @Published public var pendingTransactions: [Transaction]
    
    public func monitorTransaction(
        hash: String,
        network: BlockchainNetwork
    ) async throws -> TransactionStatus {
        // Monitor transaction status
    }
    
    public func getTransactionReceipt(
        hash: String,
        network: BlockchainNetwork
    ) async throws -> TransactionReceipt {
        // Get transaction receipt
    }
    
    public func waitForConfirmation(
        hash: String,
        network: BlockchainNetwork,
        confirmations: Int = 1
    ) async throws -> TransactionReceipt {
        // Wait for transaction confirmation
    }
}
```

### TransactionStatus

```swift
public enum TransactionStatus {
    case pending
    case confirmed
    case failed
    case dropped
    case replaced
}

public struct TransactionReceipt {
    public let transactionHash: String
    public let blockNumber: Int
    public let blockHash: String
    public let gasUsed: Int
    public let status: Bool
    public let logs: [Log]
    public let effectiveGasPrice: String
}
```

### Log

```swift
public struct Log {
    public let address: String
    public let topics: [String]
    public let data: String
    public let blockNumber: Int
    public let transactionHash: String
    public let logIndex: Int
}
```

## Gas Management

### GasManager

```swift
public class GasManager {
    public func estimateGas(
        transaction: Transaction
    ) async throws -> Int {
        // Estimate gas for transaction
    }
    
    public func getGasPrice(
        network: BlockchainNetwork
    ) async throws -> GasPrice {
        // Get current gas price
    }
    
    public func optimizeGasPrice(
        transaction: Transaction,
        maxGasPrice: String? = nil
    ) async throws -> String {
        // Optimize gas price
    }
    
    public func calculateGasCost(
        gasUsed: Int,
        gasPrice: String
    ) -> String {
        // Calculate total gas cost
    }
}
```

### GasPrice

```swift
public struct GasPrice {
    public let slow: String
    public let standard: String
    public let fast: String
    public let rapid: String
    
    public var recommended: String {
        // Return recommended gas price
    }
}
```

## Transaction History

### TransactionHistoryManager

```swift
public class TransactionHistoryManager: ObservableObject {
    @Published public var transactions: [Transaction]
    @Published public var isLoading: Bool
    
    public func getTransactionHistory(
        address: String,
        network: BlockchainNetwork,
        limit: Int = 50,
        offset: Int = 0
    ) async throws -> [Transaction] {
        // Get transaction history
    }
    
    public func getTransactionDetails(
        hash: String,
        network: BlockchainNetwork
    ) async throws -> TransactionDetails {
        // Get detailed transaction information
    }
    
    public func exportTransactionHistory(
        format: ExportFormat
    ) async throws -> Data {
        // Export transaction history
    }
}
```

### TransactionDetails

```swift
public struct TransactionDetails {
    public let hash: String
    public let from: String
    public let to: String
    public let value: String
    public let gasUsed: Int
    public let gasPrice: String
    public let nonce: Int
    public let blockNumber: Int
    public let timestamp: Date
    public let status: TransactionStatus
    public let logs: [Log]
    public let internalTransactions: [InternalTransaction]
}
```

### InternalTransaction

```swift
public struct InternalTransaction {
    public let from: String
    public let to: String
    public let value: String
    public let type: String
    public let gas: Int
    public let gasUsed: Int
}
```

## Batch Transactions

### BatchTransactionManager

```swift
public class BatchTransactionManager {
    public func createBatchTransaction(
        transactions: [Transaction]
    ) async throws -> BatchTransaction {
        // Create batch transaction
    }
    
    public func executeBatch(
        batchTransaction: BatchTransaction
    ) async throws -> [String] {
        // Execute batch transaction
    }
    
    public func estimateBatchGas(
        transactions: [Transaction]
    ) async throws -> Int {
        // Estimate gas for batch
    }
}
```

### BatchTransaction

```swift
public struct BatchTransaction {
    public let transactions: [Transaction]
    public let totalGas: Int
    public let estimatedCost: String
    public let network: BlockchainNetwork
    
    public var isExecutable: Bool {
        // Check if batch is executable
    }
}
```

## Advanced Features

### TransactionSimulator

```swift
public class TransactionSimulator {
    public func simulateTransaction(
        transaction: Transaction
    ) async throws -> TransactionSimulation {
        // Simulate transaction
    }
    
    public func estimateTransactionCost(
        transaction: Transaction
    ) async throws -> TransactionCost {
        // Estimate transaction cost
    }
    
    public func validateTransaction(
        transaction: Transaction
    ) async throws -> ValidationResult {
        // Validate transaction
    }
}
```

### TransactionSimulation

```swift
public struct TransactionSimulation {
    public let success: Bool
    public let gasUsed: Int
    public let error: String?
    public let logs: [Log]
    public let balanceChanges: [String: String]
    public let stateChanges: [String: String]
}
```

### TransactionCost

```swift
public struct TransactionCost {
    public let gasUsed: Int
    public let gasPrice: String
    public let totalCost: String
    public let networkFee: String
    public let priorityFee: String?
}
```

### ValidationResult

```swift
public struct ValidationResult {
    public let isValid: Bool
    public let errors: [String]
    public let warnings: [String]
    public let recommendations: [String]
}
```

## Usage Examples

### Basic Transaction

```swift
import iOSWeb3WalletFramework

class TransactionExample {
    private let transactionManager = TransactionManager()
    private let signer = TransactionSigner()
    private let broadcaster = TransactionBroadcaster()
    
    func sendTransaction() async throws {
        // Create transaction
        let transaction = try await transactionManager.createTransaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "0.1",
            gasLimit: 21000
        )
        
        // Sign transaction
        let signedTransaction = try await signer.signTransaction(
            transaction: transaction,
            privateKey: "your-private-key"
        )
        
        // Broadcast transaction
        let transactionHash = try await broadcaster.broadcastTransaction(
            signedTransaction: signedTransaction,
            network: .ethereum(.mainnet)
        )
        
        print("Transaction sent: \(transactionHash)")
    }
}
```

### Token Transaction

```swift
func sendTokenTransaction() async throws {
    let transaction = try await transactionManager.createTokenTransaction(
        tokenAddress: "0xA0b86a33E6441b8C4C8C8C8C8C8C8C8C8C8C8C8",
        to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
        amount: "100"
    )
    
    let signedTransaction = try await signer.signTransaction(
        transaction: transaction,
        privateKey: "your-private-key"
    )
    
    let transactionHash = try await broadcaster.broadcastTransaction(
        signedTransaction: signedTransaction,
        network: .ethereum(.mainnet)
    )
    
    print("Token transaction sent: \(transactionHash)")
}
```

### Transaction Monitoring

```swift
func monitorTransaction() async throws {
    let monitor = TransactionMonitor()
    let transactionHash = "0x123..."
    
    // Monitor transaction status
    let status = try await monitor.monitorTransaction(
        hash: transactionHash,
        network: .ethereum(.mainnet)
    )
    
    print("Transaction status: \(status)")
    
    // Wait for confirmation
    let receipt = try await monitor.waitForConfirmation(
        hash: transactionHash,
        network: .ethereum(.mainnet),
        confirmations: 1
    )
    
    print("Transaction confirmed in block: \(receipt.blockNumber)")
}
```

### Batch Transactions

```swift
func executeBatchTransactions() async throws {
    let batchManager = BatchTransactionManager()
    
    let transactions = [
        try await transactionManager.createTransaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "0.1"
        ),
        try await transactionManager.createTransaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "0.05"
        )
    ]
    
    let batchTransaction = try await batchManager.createBatchTransaction(
        transactions: transactions
    )
    
    let transactionHashes = try await batchManager.executeBatch(
        batchTransaction: batchTransaction
    )
    
    print("Batch executed: \(transactionHashes)")
}
```

### Transaction Simulation

```swift
func simulateTransaction() async throws {
    let simulator = TransactionSimulator()
    
    let transaction = try await transactionManager.createTransaction(
        to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
        value: "0.1"
    )
    
    let simulation = try await simulator.simulateTransaction(transaction)
    
    if simulation.success {
        print("Transaction simulation successful")
        print("Gas used: \(simulation.gasUsed)")
        
        let cost = try await simulator.estimateTransactionCost(transaction)
        print("Estimated cost: \(cost.totalCost)")
    } else {
        print("Transaction simulation failed: \(simulation.error ?? "Unknown error")")
    }
}
```

## Best Practices

### Transaction Guidelines

1. **Gas Estimation**: Always estimate gas before sending transactions
2. **Nonce Management**: Properly manage nonce values
3. **Error Handling**: Handle transaction failures gracefully
4. **Confirmation**: Wait for transaction confirmations
5. **Validation**: Validate transactions before sending

### Security Guidelines

1. **Private Key Security**: Never expose private keys
2. **Transaction Validation**: Validate all transaction parameters
3. **Network Security**: Use secure network connections
4. **Error Messages**: Don't expose sensitive information in errors
5. **Confirmation**: Require user confirmation for high-value transactions

### Performance Guidelines

1. **Gas Optimization**: Optimize gas usage for cost efficiency
2. **Batch Transactions**: Use batch transactions when possible
3. **Caching**: Cache transaction data for better performance
4. **Async Operations**: Use async/await for non-blocking operations
5. **Memory Management**: Clear sensitive data from memory

## Integration

### SwiftUI Integration

```swift
import SwiftUI
import iOSWeb3WalletFramework

struct TransactionView: View {
    @StateObject private var transactionManager = TransactionManager()
    @StateObject private var monitor = TransactionMonitor()
    
    var body: some View {
        NavigationView {
            List {
                Section("Recent Transactions") {
                    ForEach(transactionManager.recentTransactions, id: \.hash) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
                
                Section("Pending Transactions") {
                    ForEach(transactionManager.pendingTransactions, id: \.hash) { transaction in
                        PendingTransactionRow(transaction: transaction)
                    }
                }
            }
            .navigationTitle("Transactions")
        }
    }
}
```

### UIKit Integration

```swift
import UIKit
import iOSWeb3WalletFramework

class TransactionViewController: UIViewController {
    private let transactionManager = TransactionManager()
    private let monitor = TransactionMonitor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTransactionUI()
        loadTransactionHistory()
    }
    
    private func setupTransactionUI() {
        // Setup transaction UI components
    }
    
    private func loadTransactionHistory() {
        Task {
            // Load transaction history
        }
    }
}
```

This comprehensive Transaction API provides everything needed to handle transactions securely and efficiently in Web3 wallet applications.
