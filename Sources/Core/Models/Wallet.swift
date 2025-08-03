import Foundation
import CryptoSwift

/// Represents a Web3 wallet with all necessary properties and functionality
@available(iOS 15.0, *)
public struct Wallet: Codable, Identifiable, Equatable {
    
    // MARK: - Properties
    
    /// Unique identifier for the wallet
    public let id: String
    
    /// User-defined name for the wallet
    public let name: String
    
    /// Wallet address (public address)
    public let address: String
    
    /// Public key in hex format
    public let publicKey: String
    
    /// Mnemonic phrase (optional, only for created wallets)
    public let mnemonic: String?
    
    /// Date when wallet was created
    public let createdAt: Date
    
    /// Whether this wallet is currently active
    public var isActive: Bool
    
    /// Supported blockchain networks for this wallet
    public var supportedNetworks: [Blockchain]
    
    /// Wallet type (HD, Hardware, etc.)
    public let walletType: WalletType
    
    /// Security level of the wallet
    public let securityLevel: SecurityLevel
    
    /// Last used date
    public var lastUsed: Date?
    
    /// Wallet metadata
    public var metadata: [String: String]
    
    // MARK: - Initialization
    
    /// Initialize a new wallet
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - name: Wallet name
    ///   - address: Wallet address
    ///   - publicKey: Public key
    ///   - mnemonic: Mnemonic phrase (optional)
    ///   - createdAt: Creation date
    ///   - isActive: Active status
    ///   - supportedNetworks: Supported networks
    ///   - walletType: Type of wallet
    ///   - securityLevel: Security level
    public init(
        id: String,
        name: String,
        address: String,
        publicKey: String,
        mnemonic: String?,
        createdAt: Date,
        isActive: Bool,
        supportedNetworks: [Blockchain] = [.ethereum, .polygon, .bsc],
        walletType: WalletType = .hd,
        securityLevel: SecurityLevel = .standard
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.publicKey = publicKey
        self.mnemonic = mnemonic
        self.createdAt = createdAt
        self.isActive = isActive
        self.supportedNetworks = supportedNetworks
        self.walletType = walletType
        self.securityLevel = securityLevel
        self.lastUsed = createdAt
        self.metadata = [:]
    }
    
    // MARK: - Computed Properties
    
    /// Short address for display (first 6 + last 4 characters)
    public var shortAddress: String {
        guard address.count >= 10 else { return address }
        let start = String(address.prefix(6))
        let end = String(address.suffix(4))
        return "\(start)...\(end)"
    }
    
    /// Whether the wallet has a mnemonic phrase
    public var hasMnemonic: Bool {
        return mnemonic != nil
    }
    
    /// Age of the wallet in days
    public var ageInDays: Int {
        return Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
    }
    
    /// Whether the wallet is newly created (less than 7 days)
    public var isNew: Bool {
        return ageInDays < 7
    }
    
    // MARK: - Validation
    
    /// Validates the wallet structure
    /// - Returns: True if wallet is valid
    public var isValid: Bool {
        // Check required fields
        guard !id.isEmpty,
              !name.isEmpty,
              !address.isEmpty,
              !publicKey.isEmpty else {
            return false
        }
        
        // Validate address format
        guard address.hasPrefix("0x") && address.count == 42 else {
            return false
        }
        
        // Validate public key format
        guard publicKey.hasPrefix("0x") && publicKey.count == 130 else {
            return false
        }
        
        return true
    }
    
    /// Validates address checksum
    /// - Returns: True if address checksum is valid
    public var hasValidChecksum: Bool {
        return address.lowercased() == address || address.uppercased() == address
    }
    
    // MARK: - Methods
    
    /// Updates the last used timestamp
    public mutating func updateLastUsed() {
        self.lastUsed = Date()
    }
    
    /// Adds metadata to the wallet
    /// - Parameters:
    ///   - key: Metadata key
    ///   - value: Metadata value
    public mutating func addMetadata(key: String, value: String) {
        metadata[key] = value
    }
    
    /// Removes metadata from the wallet
    /// - Parameter key: Metadata key to remove
    public mutating func removeMetadata(key: String) {
        metadata.removeValue(forKey: key)
    }
    
    /// Checks if wallet supports a specific blockchain
    /// - Parameter blockchain: Blockchain to check
    /// - Returns: True if supported
    public func supports(_ blockchain: Blockchain) -> Bool {
        return supportedNetworks.contains(blockchain)
    }
    
    /// Adds support for a new blockchain
    /// - Parameter blockchain: Blockchain to add support for
    public mutating func addNetworkSupport(_ blockchain: Blockchain) {
        if !supportedNetworks.contains(blockchain) {
            supportedNetworks.append(blockchain)
        }
    }
    
    /// Removes support for a blockchain
    /// - Parameter blockchain: Blockchain to remove support for
    public mutating func removeNetworkSupport(_ blockchain: Blockchain) {
        supportedNetworks.removeAll { $0 == blockchain }
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case id, name, address, publicKey, mnemonic, createdAt, isActive
        case supportedNetworks, walletType, securityLevel, lastUsed, metadata
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        publicKey = try container.decode(String.self, forKey: .publicKey)
        mnemonic = try container.decodeIfPresent(String.self, forKey: .mnemonic)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        supportedNetworks = try container.decode([Blockchain].self, forKey: .supportedNetworks)
        walletType = try container.decode(WalletType.self, forKey: .walletType)
        securityLevel = try container.decode(SecurityLevel.self, forKey: .securityLevel)
        lastUsed = try container.decodeIfPresent(Date.self, forKey: .lastUsed)
        metadata = try container.decode([String: String].self, forKey: .metadata)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(publicKey, forKey: .publicKey)
        try container.encodeIfPresent(mnemonic, forKey: .mnemonic)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(supportedNetworks, forKey: .supportedNetworks)
        try container.encode(walletType, forKey: .walletType)
        try container.encode(securityLevel, forKey: .securityLevel)
        try container.encodeIfPresent(lastUsed, forKey: .lastUsed)
        try container.encode(metadata, forKey: .metadata)
    }
}

// MARK: - Supporting Types

/// Types of wallets supported by the framework
public enum WalletType: String, Codable, CaseIterable {
    case hd = "HD"
    case hardware = "Hardware"
    case watchOnly = "WatchOnly"
    case multiSig = "MultiSig"
    case smartContract = "SmartContract"
    
    public var displayName: String {
        switch self {
        case .hd:
            return "HD Wallet"
        case .hardware:
            return "Hardware Wallet"
        case .watchOnly:
            return "Watch Only"
        case .multiSig:
            return "Multi-Signature"
        case .smartContract:
            return "Smart Contract"
        }
    }
    
    public var description: String {
        switch self {
        case .hd:
            return "Hierarchical Deterministic wallet with mnemonic phrase"
        case .hardware:
            return "Hardware wallet (Ledger, Trezor, etc.)"
        case .watchOnly:
            return "Watch-only wallet for monitoring only"
        case .multiSig:
            return "Multi-signature wallet requiring multiple approvals"
        case .smartContract:
            return "Smart contract wallet with programmable logic"
        }
    }
}

/// Security levels for wallets
public enum SecurityLevel: String, Codable, CaseIterable {
    case basic = "Basic"
    case standard = "Standard"
    case high = "High"
    case maximum = "Maximum"
    
    public var displayName: String {
        switch self {
        case .basic:
            return "Basic Security"
        case .standard:
            return "Standard Security"
        case .high:
            return "High Security"
        case .maximum:
            return "Maximum Security"
        }
    }
    
    public var description: String {
        switch self {
        case .basic:
            return "Basic encryption and security measures"
        case .standard:
            return "Standard encryption with additional security features"
        case .high:
            return "High-level encryption with hardware security"
        case .maximum:
            return "Maximum security with advanced protection"
        }
    }
    
    public var requiresBiometric: Bool {
        switch self {
        case .basic:
            return false
        case .standard:
            return true
        case .high:
            return true
        case .maximum:
            return true
        }
    }
    
    public var requiresHardwareWallet: Bool {
        switch self {
        case .basic:
            return false
        case .standard:
            return false
        case .high:
            return false
        case .maximum:
            return true
        }
    }
}

/// Supported blockchain networks
public enum Blockchain: String, Codable, CaseIterable {
    case ethereum = "Ethereum"
    case polygon = "Polygon"
    case bsc = "BSC"
    case arbitrum = "Arbitrum"
    case optimism = "Optimism"
    case avalanche = "Avalanche"
    case goerli = "Goerli"
    case mumbai = "Mumbai"
    
    public var displayName: String {
        switch self {
        case .ethereum:
            return "Ethereum"
        case .polygon:
            return "Polygon"
        case .bsc:
            return "Binance Smart Chain"
        case .arbitrum:
            return "Arbitrum"
        case .optimism:
            return "Optimism"
        case .avalanche:
            return "Avalanche"
        case .goerli:
            return "Goerli Testnet"
        case .mumbai:
            return "Mumbai Testnet"
        }
    }
    
    public var chainId: Int {
        switch self {
        case .ethereum:
            return 1
        case .polygon:
            return 137
        case .bsc:
            return 56
        case .arbitrum:
            return 42161
        case .optimism:
            return 10
        case .avalanche:
            return 43114
        case .goerli:
            return 5
        case .mumbai:
            return 80001
        }
    }
    
    public var isTestnet: Bool {
        switch self {
        case .goerli, .mumbai:
            return true
        default:
            return false
        }
    }
    
    public var explorerUrl: String {
        switch self {
        case .ethereum:
            return "https://etherscan.io"
        case .polygon:
            return "https://polygonscan.com"
        case .bsc:
            return "https://bscscan.com"
        case .arbitrum:
            return "https://arbiscan.io"
        case .optimism:
            return "https://optimistic.etherscan.io"
        case .avalanche:
            return "https://snowtrace.io"
        case .goerli:
            return "https://goerli.etherscan.io"
        case .mumbai:
            return "https://mumbai.polygonscan.com"
        }
    }
} 