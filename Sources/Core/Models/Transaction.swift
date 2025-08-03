import Foundation
import BigInt

/// Represents a blockchain transaction with all necessary properties
@available(iOS 15.0, *)
public struct Transaction: Codable, Identifiable, Equatable {
    
    // MARK: - Properties
    
    /// Unique identifier for the transaction
    public let id: String
    
    /// Transaction hash (set after sending)
    public var hash: String?
    
    /// From address (sender)
    public let from: String
    
    /// To address (recipient)
    public let to: String
    
    /// Transaction value in wei
    public let value: String
    
    /// Gas limit for the transaction
    public let gasLimit: UInt64
    
    /// Gas price in wei
    public var gasPrice: String?
    
    /// Max fee per gas (EIP-1559)
    public var maxFeePerGas: String?
    
    /// Max priority fee per gas (EIP-1559)
    public var maxPriorityFeePerGas: String?
    
    /// Nonce for the transaction
    public let nonce: UInt64
    
    /// Transaction data (for smart contract interactions)
    public let data: String
    
    /// Blockchain network
    public let chain: Blockchain
    
    /// Transaction status
    public var status: TransactionStatus
    
    /// Transaction type (legacy, EIP-1559, etc.)
    public let type: TransactionType
    
    /// Block number where transaction was included
    public var blockNumber: UInt64?
    
    /// Block hash where transaction was included
    public var blockHash: String?
    
    /// Gas used by the transaction
    public var gasUsed: UInt64?
    
    /// Effective gas price
    public var effectiveGasPrice: String?
    
    /// Transaction receipt
    public var receipt: TransactionReceipt?
    
    /// Timestamp when transaction was created
    public let createdAt: Date
    
    /// Timestamp when transaction was confirmed
    public var confirmedAt: Date?
    
    /// Transaction metadata
    public var metadata: [String: String]
    
    // MARK: - Initialization
    
    /// Initialize a new transaction
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - from: Sender address
    ///   - to: Recipient address
    ///   - value: Transaction value in wei
    ///   - gasLimit: Gas limit
    ///   - nonce: Transaction nonce
    ///   - data: Transaction data
    ///   - chain: Blockchain network
    ///   - type: Transaction type
    public init(
        id: String = UUID().uuidString,
        from: String,
        to: String,
        value: String,
        gasLimit: UInt64,
        nonce: UInt64,
        data: String = "0x",
        chain: Blockchain,
        type: TransactionType = .legacy
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.value = value
        self.gasLimit = gasLimit
        self.nonce = nonce
        self.data = data
        self.chain = chain
        self.type = type
        self.status = .pending
        self.createdAt = Date()
        self.metadata = [:]
    }
    
    // MARK: - Computed Properties
    
    /// Transaction value in ETH (converted from wei)
    public var valueInEth: String {
        guard let weiValue = BigInt(value) else { return "0" }
        let ethValue = weiValue / BigInt(10).power(18)
        return ethValue.description
    }
    
    /// Gas price in Gwei
    public var gasPriceInGwei: String? {
        guard let gasPrice = gasPrice,
              let weiPrice = BigInt(gasPrice) else { return nil }
        let gweiPrice = weiPrice / BigInt(10).power(9)
        return gweiPrice.description
    }
    
    /// Estimated gas cost in wei
    public var estimatedGasCost: String? {
        guard let gasPrice = gasPrice,
              let price = BigInt(gasPrice) else { return nil }
        let cost = price * BigInt(gasLimit)
        return cost.description
    }
    
    /// Whether transaction is confirmed
    public var isConfirmed: Bool {
        return status == .confirmed
    }
    
    /// Whether transaction failed
    public var isFailed: Bool {
        return status == .failed
    }
    
    /// Whether transaction is pending
    public var isPending: Bool {
        return status == .pending
    }
    
    /// Transaction age in minutes
    public var ageInMinutes: Int {
        return Calendar.current.dateComponents([.minute], from: createdAt, to: Date()).minute ?? 0
    }
    
    /// Whether transaction is recent (less than 1 hour)
    public var isRecent: Bool {
        return ageInMinutes < 60
    }
    
    // MARK: - Validation
    
    /// Validates the transaction structure
    /// - Returns: True if transaction is valid
    public var isValid: Bool {
        // Check required fields
        guard !id.isEmpty,
              !from.isEmpty,
              !to.isEmpty,
              !value.isEmpty else {
            return false
        }
        
        // Validate addresses
        guard from.hasPrefix("0x") && from.count == 42,
              to.hasPrefix("0x") && to.count == 42 else {
            return false
        }
        
        // Validate value
        guard let _ = BigInt(value) else {
            return false
        }
        
        // Validate gas limit
        guard gasLimit > 0 else {
            return false
        }
        
        return true
    }
    
    // MARK: - Methods
    
    /// Updates transaction status
    /// - Parameter status: New status
    public mutating func updateStatus(_ status: TransactionStatus) {
        self.status = status
        if status == .confirmed {
            self.confirmedAt = Date()
        }
    }
    
    /// Sets transaction hash
    /// - Parameter hash: Transaction hash
    public mutating func setHash(_ hash: String) {
        self.hash = hash
    }
    
    /// Sets block information
    /// - Parameters:
    ///   - blockNumber: Block number
    ///   - blockHash: Block hash
    public mutating func setBlockInfo(blockNumber: UInt64, blockHash: String) {
        self.blockNumber = blockNumber
        self.blockHash = blockHash
    }
    
    /// Sets gas information
    /// - Parameters:
    ///   - gasUsed: Gas used
    ///   - effectiveGasPrice: Effective gas price
    public mutating func setGasInfo(gasUsed: UInt64, effectiveGasPrice: String) {
        self.gasUsed = gasUsed
        self.effectiveGasPrice = effectiveGasPrice
    }
    
    /// Sets transaction receipt
    /// - Parameter receipt: Transaction receipt
    public mutating func setReceipt(_ receipt: TransactionReceipt) {
        self.receipt = receipt
    }
    
    /// Adds metadata to the transaction
    /// - Parameters:
    ///   - key: Metadata key
    ///   - value: Metadata value
    public mutating func addMetadata(key: String, value: String) {
        metadata[key] = value
    }
    
    /// Removes metadata from the transaction
    /// - Parameter key: Metadata key to remove
    public mutating func removeMetadata(key: String) {
        metadata.removeValue(forKey: key)
    }
    
    /// Gets transaction explorer URL
    /// - Returns: Explorer URL for the transaction
    public func explorerUrl() -> String? {
        guard let hash = hash else { return nil }
        return "\(chain.explorerUrl)/tx/\(hash)"
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case id, hash, from, to, value, gasLimit, gasPrice, maxFeePerGas
        case maxPriorityFeePerGas, nonce, data, chain, status, type
        case blockNumber, blockHash, gasUsed, effectiveGasPrice, receipt
        case createdAt, confirmedAt, metadata
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        hash = try container.decodeIfPresent(String.self, forKey: .hash)
        from = try container.decode(String.self, forKey: .from)
        to = try container.decode(String.self, forKey: .to)
        value = try container.decode(String.self, forKey: .value)
        gasLimit = try container.decode(UInt64.self, forKey: .gasLimit)
        gasPrice = try container.decodeIfPresent(String.self, forKey: .gasPrice)
        maxFeePerGas = try container.decodeIfPresent(String.self, forKey: .maxFeePerGas)
        maxPriorityFeePerGas = try container.decodeIfPresent(String.self, forKey: .maxPriorityFeePerGas)
        nonce = try container.decode(UInt64.self, forKey: .nonce)
        data = try container.decode(String.self, forKey: .data)
        chain = try container.decode(Blockchain.self, forKey: .chain)
        status = try container.decode(TransactionStatus.self, forKey: .status)
        type = try container.decode(TransactionType.self, forKey: .type)
        blockNumber = try container.decodeIfPresent(UInt64.self, forKey: .blockNumber)
        blockHash = try container.decodeIfPresent(String.self, forKey: .blockHash)
        gasUsed = try container.decodeIfPresent(UInt64.self, forKey: .gasUsed)
        effectiveGasPrice = try container.decodeIfPresent(String.self, forKey: .effectiveGasPrice)
        receipt = try container.decodeIfPresent(TransactionReceipt.self, forKey: .receipt)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        confirmedAt = try container.decodeIfPresent(Date.self, forKey: .confirmedAt)
        metadata = try container.decode([String: String].self, forKey: .metadata)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(hash, forKey: .hash)
        try container.encode(from, forKey: .from)
        try container.encode(to, forKey: .to)
        try container.encode(value, forKey: .value)
        try container.encode(gasLimit, forKey: .gasLimit)
        try container.encodeIfPresent(gasPrice, forKey: .gasPrice)
        try container.encodeIfPresent(maxFeePerGas, forKey: .maxFeePerGas)
        try container.encodeIfPresent(maxPriorityFeePerGas, forKey: .maxPriorityFeePerGas)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(data, forKey: .data)
        try container.encode(chain, forKey: .chain)
        try container.encode(status, forKey: .status)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(blockNumber, forKey: .blockNumber)
        try container.encodeIfPresent(blockHash, forKey: .blockHash)
        try container.encodeIfPresent(gasUsed, forKey: .gasUsed)
        try container.encodeIfPresent(effectiveGasPrice, forKey: .effectiveGasPrice)
        try container.encodeIfPresent(receipt, forKey: .receipt)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(confirmedAt, forKey: .confirmedAt)
        try container.encode(metadata, forKey: .metadata)
    }
}

// MARK: - Supporting Types

/// Transaction status
public enum TransactionStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case failed = "Failed"
    case cancelled = "Cancelled"
    
    public var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .confirmed:
            return "Confirmed"
        case .failed:
            return "Failed"
        case .cancelled:
            return "Cancelled"
        }
    }
    
    public var color: String {
        switch self {
        case .pending:
            return "#FFA500"
        case .confirmed:
            return "#00FF00"
        case .failed:
            return "#FF0000"
        case .cancelled:
            return "#808080"
        }
    }
}

/// Transaction types
public enum TransactionType: String, Codable, CaseIterable {
    case legacy = "Legacy"
    case eip1559 = "EIP-1559"
    case eip2930 = "EIP-2930"
    
    public var displayName: String {
        switch self {
        case .legacy:
            return "Legacy"
        case .eip1559:
            return "EIP-1559"
        case .eip2930:
            return "EIP-2930"
        }
    }
}

/// Transaction receipt
public struct TransactionReceipt: Codable, Equatable {
    public let transactionHash: String
    public let blockNumber: UInt64
    public let blockHash: String
    public let gasUsed: UInt64
    public let effectiveGasPrice: String
    public let status: Bool
    public let logs: [TransactionLog]
    
    public init(
        transactionHash: String,
        blockNumber: UInt64,
        blockHash: String,
        gasUsed: UInt64,
        effectiveGasPrice: String,
        status: Bool,
        logs: [TransactionLog] = []
    ) {
        self.transactionHash = transactionHash
        self.blockNumber = blockNumber
        self.blockHash = blockHash
        self.gasUsed = gasUsed
        self.effectiveGasPrice = effectiveGasPrice
        self.status = status
        self.logs = logs
    }
}

/// Transaction log
public struct TransactionLog: Codable, Equatable {
    public let address: String
    public let topics: [String]
    public let data: String
    public let logIndex: UInt64
    public let transactionIndex: UInt64
    public let blockNumber: UInt64
    
    public init(
        address: String,
        topics: [String],
        data: String,
        logIndex: UInt64,
        transactionIndex: UInt64,
        blockNumber: UInt64
    ) {
        self.address = address
        self.topics = topics
        self.data = data
        self.logIndex = logIndex
        self.transactionIndex = transactionIndex
        self.blockNumber = blockNumber
    }
} 