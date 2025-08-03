import Foundation
import CryptoSwift

/// Represents a signed blockchain transaction
@available(iOS 15.0, *)
public struct SignedTransaction: Codable, Identifiable, Equatable {
    
    // MARK: - Properties
    
    /// Unique identifier for the signed transaction
    public let id: String
    
    /// Original transaction
    public let transaction: Transaction
    
    /// Signature components
    public let signature: TransactionSignature
    
    /// Raw signed transaction data
    public let rawTransaction: String
    
    /// Transaction hash (calculated from raw transaction)
    public var hash: String {
        return calculateHash()
    }
    
    /// Timestamp when transaction was signed
    public let signedAt: Date
    
    /// Signing wallet address
    public let signedBy: String
    
    /// Transaction metadata
    public var metadata: [String: String]
    
    // MARK: - Initialization
    
    /// Initialize a signed transaction
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - transaction: Original transaction
    ///   - signature: Transaction signature
    ///   - rawTransaction: Raw signed transaction data
    ///   - signedBy: Address that signed the transaction
    public init(
        id: String = UUID().uuidString,
        transaction: Transaction,
        signature: TransactionSignature,
        rawTransaction: String,
        signedBy: String
    ) {
        self.id = id
        self.transaction = transaction
        self.signature = signature
        self.rawTransaction = rawTransaction
        self.signedBy = signedBy
        self.signedAt = Date()
        self.metadata = [:]
    }
    
    // MARK: - Computed Properties
    
    /// Whether the signature is valid
    public var isValid: Bool {
        // Validate signature format
        guard signature.r.count == 32,
              signature.s.count == 32,
              signature.v >= 27 && signature.v <= 28 else {
            return false
        }
        
        // Validate raw transaction format
        guard rawTransaction.hasPrefix("0x") else {
            return false
        }
        
        return true
    }
    
    /// Recovery ID for the signature
    public var recoveryId: UInt8 {
        return UInt8(signature.v - 27)
    }
    
    // MARK: - Methods
    
    /// Calculates the transaction hash from raw transaction
    /// - Returns: Transaction hash
    private func calculateHash() -> String {
        let data = Data(hex: rawTransaction)
        let hash = data.sha3(.keccak256)
        return "0x" + hash.toHexString()
    }
    
    /// Adds metadata to the signed transaction
    /// - Parameters:
    ///   - key: Metadata key
    ///   - value: Metadata value
    public mutating func addMetadata(key: String, value: String) {
        metadata[key] = value
    }
    
    /// Removes metadata from the signed transaction
    /// - Parameter key: Metadata key to remove
    public mutating func removeMetadata(key: String) {
        metadata.removeValue(forKey: key)
    }
    
    /// Gets the transaction explorer URL
    /// - Returns: Explorer URL for the transaction
    public func explorerUrl() -> String {
        return "\(transaction.chain.explorerUrl)/tx/\(hash)"
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case id, transaction, signature, rawTransaction, signedAt, signedBy, metadata
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        transaction = try container.decode(Transaction.self, forKey: .transaction)
        signature = try container.decode(TransactionSignature.self, forKey: .signature)
        rawTransaction = try container.decode(String.self, forKey: .rawTransaction)
        signedAt = try container.decode(Date.self, forKey: .signedAt)
        signedBy = try container.decode(String.self, forKey: .signedBy)
        metadata = try container.decode([String: String].self, forKey: .metadata)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(transaction, forKey: .transaction)
        try container.encode(signature, forKey: .signature)
        try container.encode(rawTransaction, forKey: .rawTransaction)
        try container.encode(signedAt, forKey: .signedAt)
        try container.encode(signedBy, forKey: .signedBy)
        try container.encode(metadata, forKey: .metadata)
    }
}

// MARK: - Supporting Types

/// Transaction signature components
public struct TransactionSignature: Codable, Equatable {
    /// R component of the signature
    public let r: String
    
    /// S component of the signature
    public let s: String
    
    /// V component of the signature (recovery ID + 27)
    public let v: UInt8
    
    /// Initialize signature components
    /// - Parameters:
    ///   - r: R component
    ///   - s: S component
    ///   - v: V component
    public init(r: String, s: String, v: UInt8) {
        self.r = r
        self.s = s
        self.v = v
    }
    
    /// Initialize signature from hex string
    /// - Parameter hexString: Hex string containing signature
    public init?(hexString: String) {
        guard hexString.hasPrefix("0x"),
              hexString.count == 130 else {
            return nil
        }
        
        let signature = String(hexString.dropFirst(2))
        let r = String(signature.prefix(64))
        let s = String(signature.dropFirst(64).prefix(64))
        let v = String(signature.dropFirst(128))
        
        guard let vValue = UInt8(v, radix: 16) else {
            return nil
        }
        
        self.r = r
        self.s = s
        self.v = vValue
    }
    
    /// Convert signature to hex string
    /// - Returns: Hex string representation
    public func toHexString() -> String {
        return "0x\(r)\(s)\(String(format: "%02x", v))"
    }
} 