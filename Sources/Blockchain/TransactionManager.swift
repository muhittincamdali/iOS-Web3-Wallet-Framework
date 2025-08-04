import Foundation
import CryptoKit
import BigInt

/// Comprehensive transaction management for Web3 wallet operations
public class TransactionManager: ObservableObject {
    
    // MARK: - Properties
    
    /// Current network configuration
    @Published public var currentNetwork: BlockchainNetwork = .ethereum
    
    /// Gas price estimation
    @Published public var gasPrice: BigUInt = 0
    
    /// Transaction history
    @Published public var transactionHistory: [Transaction] = []
    
    /// Pending transactions
    @Published public var pendingTransactions: [Transaction] = []
    
    /// Network manager for blockchain interactions
    private let networkManager: NetworkManager
    
    /// Security manager for transaction signing
    private let securityManager: SecurityManager
    
    /// Gas estimator for optimal gas calculation
    private let gasEstimator: GasEstimator
    
    // MARK: - Initializers
    
    /// Creates a transaction manager with default configuration
    public init() {
        self.networkManager = NetworkManager()
        self.securityManager = SecurityManager()
        self.gasEstimator = GasEstimator()
        setupNetworkMonitoring()
    }
    
    /// Creates a transaction manager with custom configuration
    /// - Parameters:
    ///   - network: Initial blockchain network
    ///   - customRPC: Custom RPC endpoint
    ///   - gasStrategy: Gas estimation strategy
    public init(network: BlockchainNetwork, customRPC: String? = nil, gasStrategy: GasStrategy = .automatic) {
        self.currentNetwork = network
        self.networkManager = NetworkManager(customRPC: customRPC)
        self.securityManager = SecurityManager()
        self.gasEstimator = GasEstimator(strategy: gasStrategy)
        setupNetworkMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Creates and sends a transaction
    /// - Parameters:
    ///   - transaction: Transaction to send
    ///   - completion: Completion handler with result
    public func sendTransaction(_ transaction: Transaction, completion: @escaping (Result<String, TransactionError>) -> Void) {
        Task {
            do {
                // Validate transaction
                try validateTransaction(transaction)
                
                // Estimate gas if not provided
                let gasLimit = transaction.gasLimit ?? try await estimateGas(for: transaction)
                
                // Get current gas price
                let currentGasPrice = try await getCurrentGasPrice()
                
                // Create signed transaction
                let signedTransaction = try await createSignedTransaction(
                    transaction: transaction,
                    gasLimit: gasLimit,
                    gasPrice: currentGasPrice
                )
                
                // Send transaction
                let txHash = try await networkManager.sendTransaction(signedTransaction)
                
                // Update local state
                await MainActor.run {
                    self.pendingTransactions.append(transaction)
                    self.transactionHistory.append(transaction)
                }
                
                completion(.success(txHash))
                
            } catch {
                completion(.failure(TransactionError.failed(error)))
            }
        }
    }
    
    /// Estimates gas for a transaction
    /// - Parameter transaction: Transaction to estimate gas for
    /// - Returns: Estimated gas limit
    public func estimateGas(for transaction: Transaction) async throws -> BigUInt {
        return try await gasEstimator.estimateGas(for: transaction, network: currentNetwork)
    }
    
    /// Gets current gas price for the network
    /// - Returns: Current gas price in wei
    public func getCurrentGasPrice() async throws -> BigUInt {
        return try await networkManager.getGasPrice(network: currentNetwork)
    }
    
    /// Switches to a different blockchain network
    /// - Parameter network: New network to switch to
    public func switchNetwork(_ network: BlockchainNetwork) async throws {
        try await networkManager.switchNetwork(network)
        await MainActor.run {
            self.currentNetwork = network
        }
    }
    
    /// Gets transaction status
    /// - Parameter txHash: Transaction hash
    /// - Returns: Transaction status
    public func getTransactionStatus(_ txHash: String) async throws -> TransactionStatus {
        return try await networkManager.getTransactionStatus(txHash, network: currentNetwork)
    }
    
    /// Gets transaction receipt
    /// - Parameter txHash: Transaction hash
    /// - Returns: Transaction receipt
    public func getTransactionReceipt(_ txHash: String) async throws -> TransactionReceipt {
        return try await networkManager.getTransactionReceipt(txHash, network: currentNetwork)
    }
    
    /// Batches multiple transactions
    /// - Parameter transactions: Array of transactions to batch
    /// - Returns: Batch transaction hash
    public func batchTransactions(_ transactions: [Transaction]) async throws -> String {
        guard !transactions.isEmpty else {
            throw TransactionError.invalidTransaction("No transactions to batch")
        }
        
        // Validate all transactions
        for transaction in transactions {
            try validateTransaction(transaction)
        }
        
        // Create batch transaction
        let batchTransaction = try await createBatchTransaction(transactions)
        
        // Send batch transaction
        let txHash = try await networkManager.sendTransaction(batchTransaction)
        
        // Update local state
        await MainActor.run {
            self.pendingTransactions.append(contentsOf: transactions)
            self.transactionHistory.append(contentsOf: transactions)
        }
        
        return txHash
    }
    
    // MARK: - Private Methods
    
    /// Validates transaction parameters
    /// - Parameter transaction: Transaction to validate
    /// - Throws: TransactionError if validation fails
    private func validateTransaction(_ transaction: Transaction) throws {
        // Validate recipient address
        guard isValidAddress(transaction.to) else {
            throw TransactionError.invalidAddress(transaction.to)
        }
        
        // Validate amount
        guard let amount = BigUInt(transaction.value), amount > 0 else {
            throw TransactionError.invalidAmount(transaction.value)
        }
        
        // Validate gas limit
        if let gasLimit = transaction.gasLimit {
            guard gasLimit > 0 else {
                throw TransactionError.invalidGasLimit(gasLimit)
            }
        }
        
        // Validate network compatibility
        guard transaction.network == currentNetwork else {
            throw TransactionError.networkMismatch(transaction.network, currentNetwork)
        }
    }
    
    /// Creates a signed transaction
    /// - Parameters:
    ///   - transaction: Original transaction
    ///   - gasLimit: Gas limit for transaction
    ///   - gasPrice: Gas price for transaction
    /// - Returns: Signed transaction data
    private func createSignedTransaction(transaction: Transaction, gasLimit: BigUInt, gasPrice: BigUInt) async throws -> Data {
        // Create transaction data
        let txData = try createTransactionData(transaction)
        
        // Sign transaction
        let signature = try await securityManager.signTransaction(txData)
        
        // Create signed transaction
        return try createSignedTransactionData(transaction, signature, gasLimit, gasPrice)
    }
    
    /// Creates transaction data for signing
    /// - Parameter transaction: Transaction to create data for
    /// - Returns: Transaction data
    private func createTransactionData(_ transaction: Transaction) throws -> Data {
        var data = Data()
        
        // Add recipient address
        data.append(Data(hex: transaction.to))
        
        // Add amount
        let amount = BigUInt(transaction.value)
        data.append(amount.serialize())
        
        // Add gas limit
        if let gasLimit = transaction.gasLimit {
            data.append(gasLimit.serialize())
        }
        
        // Add gas price
        data.append(gasPrice.serialize())
        
        // Add nonce
        let nonce = try getCurrentNonce()
        data.append(nonce.serialize())
        
        return data
    }
    
    /// Creates signed transaction data
    /// - Parameters:
    ///   - transaction: Original transaction
    ///   - signature: Transaction signature
    ///   - gasLimit: Gas limit
    ///   - gasPrice: Gas price
    /// - Returns: Signed transaction data
    private func createSignedTransactionData(_ transaction: Transaction, _ signature: Data, _ gasLimit: BigUInt, _ gasPrice: BigUInt) throws -> Data {
        var signedData = Data()
        
        // Add signature components
        let r = signature.prefix(32)
        let s = signature.dropFirst(32).prefix(32)
        let v = signature.last ?? 0
        
        signedData.append(r)
        signedData.append(s)
        signedData.append(v)
        
        // Add transaction data
        let txData = try createTransactionData(transaction)
        signedData.append(txData)
        
        return signedData
    }
    
    /// Creates a batch transaction
    /// - Parameter transactions: Transactions to batch
    /// - Returns: Batch transaction data
    private func createBatchTransaction(_ transactions: [Transaction]) async throws -> Data {
        var batchData = Data()
        
        for transaction in transactions {
            let txData = try createTransactionData(transaction)
            batchData.append(txData)
        }
        
        return batchData
    }
    
    /// Gets current nonce for the wallet
    /// - Returns: Current nonce
    private func getCurrentNonce() throws -> BigUInt {
        // This would typically get the nonce from the wallet
        // For now, we'll use a placeholder
        return BigUInt(0)
    }
    
    /// Validates Ethereum address format
    /// - Parameter address: Address to validate
    /// - Returns: True if valid address
    private func isValidAddress(_ address: String) -> Bool {
        // Basic Ethereum address validation
        let pattern = "^0x[a-fA-F0-9]{40}$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: address.utf16.count)
        return regex.firstMatch(in: address, range: range) != nil
    }
    
    /// Sets up network monitoring
    private func setupNetworkMonitoring() {
        // Monitor network changes and update gas prices
        Task {
            while true {
                do {
                    let newGasPrice = try await getCurrentGasPrice()
                    await MainActor.run {
                        self.gasPrice = newGasPrice
                    }
                } catch {
                    print("Failed to update gas price: \(error)")
                }
                
                try await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
            }
        }
    }
}

// MARK: - Supporting Types

/// Blockchain network configuration
public enum BlockchainNetwork: String, CaseIterable {
    case ethereum = "ethereum"
    case polygon = "polygon"
    case binanceSmartChain = "bsc"
    case arbitrum = "arbitrum"
    case optimism = "optimism"
    
    /// Network chain ID
    public var chainId: Int {
        switch self {
        case .ethereum: return 1
        case .polygon: return 137
        case .binanceSmartChain: return 56
        case .arbitrum: return 42161
        case .optimism: return 10
        }
    }
    
    /// Network name
    public var name: String {
        switch self {
        case .ethereum: return "Ethereum"
        case .polygon: return "Polygon"
        case .binanceSmartChain: return "Binance Smart Chain"
        case .arbitrum: return "Arbitrum"
        case .optimism: return "Optimism"
        }
    }
    
    /// Default RPC URL
    public var defaultRPC: String {
        switch self {
        case .ethereum: return "https://mainnet.infura.io/v3/YOUR_PROJECT_ID"
        case .polygon: return "https://polygon-rpc.com"
        case .binanceSmartChain: return "https://bsc-dataseed.binance.org"
        case .arbitrum: return "https://arb1.arbitrum.io/rpc"
        case .optimism: return "https://mainnet.optimism.io"
        }
    }
}

/// Transaction model
public struct Transaction: Identifiable, Codable {
    public let id = UUID()
    public let to: String
    public let value: String
    public let gasLimit: BigUInt?
    public let network: BlockchainNetwork
    public let data: Data?
    public let nonce: BigUInt?
    
    /// Creates a transaction
    /// - Parameters:
    ///   - to: Recipient address
    ///   - value: Amount to send
    ///   - gasLimit: Gas limit (optional, will be estimated)
    ///   - network: Blockchain network
    ///   - data: Additional transaction data
    ///   - nonce: Transaction nonce (optional)
    public init(to: String, value: String, gasLimit: BigUInt? = nil, network: BlockchainNetwork, data: Data? = nil, nonce: BigUInt? = nil) {
        self.to = to
        self.value = value
        self.gasLimit = gasLimit
        self.network = network
        self.data = data
        self.nonce = nonce
    }
}

/// Transaction status
public enum TransactionStatus: String, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case failed = "failed"
    case dropped = "dropped"
}

/// Transaction receipt
public struct TransactionReceipt: Codable {
    public let transactionHash: String
    public let blockNumber: BigUInt
    public let gasUsed: BigUInt
    public let status: TransactionStatus
    public let logs: [TransactionLog]
    
    public init(transactionHash: String, blockNumber: BigUInt, gasUsed: BigUInt, status: TransactionStatus, logs: [TransactionLog]) {
        self.transactionHash = transactionHash
        self.blockNumber = blockNumber
        self.gasUsed = gasUsed
        self.status = status
        self.logs = logs
    }
}

/// Transaction log
public struct TransactionLog: Codable {
    public let address: String
    public let topics: [String]
    public let data: String
    
    public init(address: String, topics: [String], data: String) {
        self.address = address
        self.topics = topics
        self.data = data
    }
}

/// Gas estimation strategy
public enum GasStrategy {
    case automatic
    case conservative
    case aggressive
    case custom(BigUInt)
}

/// Transaction errors
public enum TransactionError: Error, LocalizedError {
    case invalidAddress(String)
    case invalidAmount(String)
    case invalidGasLimit(BigUInt)
    case networkMismatch(BlockchainNetwork, BlockchainNetwork)
    case failed(Error)
    case invalidTransaction(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidAddress(let address):
            return "Invalid address format: \(address)"
        case .invalidAmount(let amount):
            return "Invalid amount: \(amount)"
        case .invalidGasLimit(let gasLimit):
            return "Invalid gas limit: \(gasLimit)"
        case .networkMismatch(let expected, let actual):
            return "Network mismatch: expected \(expected), got \(actual)"
        case .failed(let error):
            return "Transaction failed: \(error.localizedDescription)"
        case .invalidTransaction(let message):
            return "Invalid transaction: \(message)"
        }
    }
}

// MARK: - Extensions

extension Data {
    /// Creates Data from hex string
    /// - Parameter hex: Hex string
    init(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hex.index(hex.startIndex, offsetBy: i * 2)
            let k = hex.index(j, offsetBy: 2)
            let bytes = hex[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            }
        }
        self = data
    }
}

extension BigUInt {
    /// Serializes BigUInt to Data
    /// - Returns: Serialized data
    func serialize() -> Data {
        return Data(self.serialize())
    }
} 