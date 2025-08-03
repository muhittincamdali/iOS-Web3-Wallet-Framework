import Foundation

/// Represents a blockchain network
public struct Blockchain: Codable, Equatable, Hashable {
    
    /// Blockchain identifier
    public let id: String
    
    /// Human-readable name
    public let name: String
    
    /// Chain ID for the network
    public let chainId: Int
    
    /// RPC endpoint URL
    public let rpcUrl: String
    
    /// Block explorer URL
    public let explorerUrl: String
    
    /// Native currency information
    public let nativeCurrency: NativeCurrency
    
    /// Block time in seconds
    public let blockTime: TimeInterval
    
    /// Whether this is a testnet
    public let isTestnet: Bool
    
    /// Supported features
    public let features: [BlockchainFeature]
    
    /// Network status
    public let status: BlockchainStatus
    
    /// Creation date
    public let createdAt: Date
    
    /// Last updated date
    public let updatedAt: Date
    
    public init(
        id: String,
        name: String,
        chainId: Int,
        rpcUrl: String,
        explorerUrl: String,
        nativeCurrency: NativeCurrency,
        blockTime: TimeInterval,
        isTestnet: Bool = false,
        features: [BlockchainFeature] = [],
        status: BlockchainStatus = .active
    ) {
        self.id = id
        self.name = name
        self.chainId = chainId
        self.rpcUrl = rpcUrl
        self.explorerUrl = explorerUrl
        self.nativeCurrency = nativeCurrency
        self.blockTime = blockTime
        self.isTestnet = isTestnet
        self.features = features
        self.status = status
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Short name for display
    public var shortName: String {
        return name.components(separatedBy: " ").first ?? name
    }
    
    /// Full network name with testnet indicator
    public var fullName: String {
        return isTestnet ? "\(name) Testnet" : name
    }
    
    /// Whether the network supports smart contracts
    public var supportsSmartContracts: Bool {
        return features.contains(.smartContracts)
    }
    
    /// Whether the network supports DeFi protocols
    public var supportsDeFi: Bool {
        return features.contains(.deFi)
    }
    
    /// Whether the network supports NFTs
    public var supportsNFTs: Bool {
        return features.contains(.nfts)
    }
    
    /// Whether the network supports staking
    public var supportsStaking: Bool {
        return features.contains(.staking)
    }
    
    /// Validate blockchain configuration
    public func validate() throws {
        guard !id.isEmpty else {
            throw BlockchainError.invalidId
        }
        
        guard !name.isEmpty else {
            throw BlockchainError.invalidName
        }
        
        guard chainId > 0 else {
            throw BlockchainError.invalidChainId
        }
        
        guard !rpcUrl.isEmpty, URL(string: rpcUrl) != nil else {
            throw BlockchainError.invalidRpcUrl
        }
        
        guard !explorerUrl.isEmpty, URL(string: explorerUrl) != nil else {
            throw BlockchainError.invalidExplorerUrl
        }
        
        try nativeCurrency.validate()
    }
    
    /// Update blockchain configuration
    public mutating func update(
        name: String? = nil,
        rpcUrl: String? = nil,
        explorerUrl: String? = nil,
        status: BlockchainStatus? = nil,
        features: [BlockchainFeature]? = nil
    ) {
        if let name = name {
            self = Blockchain(
                id: self.id,
                name: name,
                chainId: self.chainId,
                rpcUrl: self.rpcUrl,
                explorerUrl: self.explorerUrl,
                nativeCurrency: self.nativeCurrency,
                blockTime: self.blockTime,
                isTestnet: self.isTestnet,
                features: self.features,
                status: self.status
            )
        }
        
        if let rpcUrl = rpcUrl {
            self = Blockchain(
                id: self.id,
                name: self.name,
                chainId: self.chainId,
                rpcUrl: rpcUrl,
                explorerUrl: self.explorerUrl,
                nativeCurrency: self.nativeCurrency,
                blockTime: self.blockTime,
                isTestnet: self.isTestnet,
                features: self.features,
                status: self.status
            )
        }
        
        if let explorerUrl = explorerUrl {
            self = Blockchain(
                id: self.id,
                name: self.name,
                chainId: self.chainId,
                rpcUrl: self.rpcUrl,
                explorerUrl: explorerUrl,
                nativeCurrency: self.nativeCurrency,
                blockTime: self.blockTime,
                isTestnet: self.isTestnet,
                features: self.features,
                status: self.status
            )
        }
        
        if let status = status {
            self = Blockchain(
                id: self.id,
                name: self.name,
                chainId: self.chainId,
                rpcUrl: self.rpcUrl,
                explorerUrl: self.explorerUrl,
                nativeCurrency: self.nativeCurrency,
                blockTime: self.blockTime,
                isTestnet: self.isTestnet,
                features: self.features,
                status: status
            )
        }
        
        if let features = features {
            self = Blockchain(
                id: self.id,
                name: self.name,
                chainId: self.chainId,
                rpcUrl: self.rpcUrl,
                explorerUrl: self.explorerUrl,
                nativeCurrency: self.nativeCurrency,
                blockTime: self.blockTime,
                isTestnet: self.isTestnet,
                features: features,
                status: self.status
            )
        }
    }
}

/// Native currency information
public struct NativeCurrency: Codable, Equatable {
    
    /// Currency name
    public let name: String
    
    /// Currency symbol
    public let symbol: String
    
    /// Number of decimals
    public let decimals: Int
    
    /// Currency logo URL
    public let logoUrl: String?
    
    public init(
        name: String,
        symbol: String,
        decimals: Int,
        logoUrl: String? = nil
    ) {
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.logoUrl = logoUrl
    }
    
    /// Validate native currency
    public func validate() throws {
        guard !name.isEmpty else {
            throw BlockchainError.invalidCurrencyName
        }
        
        guard !symbol.isEmpty else {
            throw BlockchainError.invalidCurrencySymbol
        }
        
        guard decimals >= 0 && decimals <= 18 else {
            throw BlockchainError.invalidCurrencyDecimals
        }
    }
    
    /// Format amount with proper decimals
    public func formatAmount(_ amount: String) -> String {
        guard let amountValue = Double(amount) else {
            return amount
        }
        
        let divisor = pow(10.0, Double(decimals))
        let formattedAmount = amountValue / divisor
        
        return String(format: "%.\(decimals)f", formattedAmount)
    }
    
    /// Convert from wei to main unit
    public func fromWei(_ weiAmount: String) -> String {
        guard let weiValue = Double(weiAmount) else {
            return weiAmount
        }
        
        let divisor = pow(10.0, Double(decimals))
        let mainUnit = weiValue / divisor
        
        return String(format: "%.\(decimals)f", mainUnit)
    }
    
    /// Convert to wei from main unit
    public func toWei(_ mainUnitAmount: String) -> String {
        guard let mainUnitValue = Double(mainUnitAmount) else {
            return mainUnitAmount
        }
        
        let multiplier = pow(10.0, Double(decimals))
        let weiAmount = mainUnitValue * multiplier
        
        return String(format: "%.0f", weiAmount)
    }
}

/// Blockchain features
public enum BlockchainFeature: String, Codable, CaseIterable {
    case smartContracts = "smart_contracts"
    case deFi = "defi"
    case nfts = "nfts"
    case staking = "staking"
    case governance = "governance"
    case privacy = "privacy"
    case scalability = "scalability"
    case interoperability = "interoperability"
    
    /// Display name for the feature
    public var displayName: String {
        switch self {
        case .smartContracts:
            return "Smart Contracts"
        case .deFi:
            return "DeFi"
        case .nfts:
            return "NFTs"
        case .staking:
            return "Staking"
        case .governance:
            return "Governance"
        case .privacy:
            return "Privacy"
        case .scalability:
            return "Scalability"
        case .interoperability:
            return "Interoperability"
        }
    }
    
    /// Description of the feature
    public var description: String {
        switch self {
        case .smartContracts:
            return "Support for smart contract execution"
        case .deFi:
            return "Decentralized Finance protocols"
        case .nfts:
            return "Non-Fungible Token support"
        case .staking:
            return "Proof of Stake consensus"
        case .governance:
            return "On-chain governance mechanisms"
        case .privacy:
            return "Privacy-preserving features"
        case .scalability:
            return "High transaction throughput"
        case .interoperability:
            return "Cross-chain communication"
        }
    }
}

/// Blockchain status
public enum BlockchainStatus: String, Codable, CaseIterable {
    case active = "active"
    case inactive = "inactive"
    case maintenance = "maintenance"
    case deprecated = "deprecated"
    
    /// Display name for the status
    public var displayName: String {
        switch self {
        case .active:
            return "Active"
        case .inactive:
            return "Inactive"
        case .maintenance:
            return "Maintenance"
        case .deprecated:
            return "Deprecated"
        }
    }
    
    /// Whether the blockchain is available for use
    public var isAvailable: Bool {
        switch self {
        case .active:
            return true
        case .inactive, .maintenance, .deprecated:
            return false
        }
    }
    
    /// Color for UI display
    public var color: String {
        switch self {
        case .active:
            return "green"
        case .inactive:
            return "red"
        case .maintenance:
            return "yellow"
        case .deprecated:
            return "gray"
        }
    }
}

/// Blockchain errors
public enum BlockchainError: Error, LocalizedError {
    case invalidId
    case invalidName
    case invalidChainId
    case invalidRpcUrl
    case invalidExplorerUrl
    case invalidCurrencyName
    case invalidCurrencySymbol
    case invalidCurrencyDecimals
    case networkNotSupported
    case featureNotSupported(BlockchainFeature)
    case networkUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .invalidId:
            return "Invalid blockchain ID"
        case .invalidName:
            return "Invalid blockchain name"
        case .invalidChainId:
            return "Invalid chain ID"
        case .invalidRpcUrl:
            return "Invalid RPC URL"
        case .invalidExplorerUrl:
            return "Invalid explorer URL"
        case .invalidCurrencyName:
            return "Invalid currency name"
        case .invalidCurrencySymbol:
            return "Invalid currency symbol"
        case .invalidCurrencyDecimals:
            return "Invalid currency decimals"
        case .networkNotSupported:
            return "Network not supported"
        case .featureNotSupported(let feature):
            return "Feature not supported: \(feature.displayName)"
        case .networkUnavailable:
            return "Network is currently unavailable"
        }
    }
}

/// Predefined blockchain networks
public extension Blockchain {
    
    /// Ethereum Mainnet
    static let ethereum = Blockchain(
        id: "ethereum",
        name: "Ethereum",
        chainId: 1,
        rpcUrl: "https://mainnet.infura.io/v3/YOUR_PROJECT_ID",
        explorerUrl: "https://etherscan.io",
        nativeCurrency: NativeCurrency(
            name: "Ether",
            symbol: "ETH",
            decimals: 18,
            logoUrl: "https://assets.coingecko.com/coins/images/279/small/ethereum.png"
        ),
        blockTime: 12,
        features: [.smartContracts, .deFi, .nfts, .staking, .governance]
    )
    
    /// Polygon Mainnet
    static let polygon = Blockchain(
        id: "polygon",
        name: "Polygon",
        chainId: 137,
        rpcUrl: "https://polygon-rpc.com",
        explorerUrl: "https://polygonscan.com",
        nativeCurrency: NativeCurrency(
            name: "MATIC",
            symbol: "MATIC",
            decimals: 18,
            logoUrl: "https://assets.coingecko.com/coins/images/4713/small/matic-token-icon.png"
        ),
        blockTime: 2,
        features: [.smartContracts, .deFi, .nfts, .scalability]
    )
    
    /// Binance Smart Chain
    static let binanceSmartChain = Blockchain(
        id: "binance-smart-chain",
        name: "Binance Smart Chain",
        chainId: 56,
        rpcUrl: "https://bsc-dataseed.binance.org",
        explorerUrl: "https://bscscan.com",
        nativeCurrency: NativeCurrency(
            name: "BNB",
            symbol: "BNB",
            decimals: 18,
            logoUrl: "https://assets.coingecko.com/coins/images/825/small/bnb-icon2_2x.png"
        ),
        blockTime: 3,
        features: [.smartContracts, .deFi, .nfts, .scalability]
    )
    
    /// Arbitrum One
    static let arbitrum = Blockchain(
        id: "arbitrum",
        name: "Arbitrum One",
        chainId: 42161,
        rpcUrl: "https://arb1.arbitrum.io/rpc",
        explorerUrl: "https://arbiscan.io",
        nativeCurrency: NativeCurrency(
            name: "Ether",
            symbol: "ETH",
            decimals: 18,
            logoUrl: "https://assets.coingecko.com/coins/images/279/small/ethereum.png"
        ),
        blockTime: 1,
        features: [.smartContracts, .deFi, .nfts, .scalability]
    )
    
    /// Optimism
    static let optimism = Blockchain(
        id: "optimism",
        name: "Optimism",
        chainId: 10,
        rpcUrl: "https://mainnet.optimism.io",
        explorerUrl: "https://optimistic.etherscan.io",
        nativeCurrency: NativeCurrency(
            name: "Ether",
            symbol: "ETH",
            decimals: 18,
            logoUrl: "https://assets.coingecko.com/coins/images/279/small/ethereum.png"
        ),
        blockTime: 2,
        features: [.smartContracts, .deFi, .nfts, .scalability]
    )
    
    /// Avalanche C-Chain
    static let avalanche = Blockchain(
        id: "avalanche",
        name: "Avalanche C-Chain",
        chainId: 43114,
        rpcUrl: "https://api.avax.network/ext/bc/C/rpc",
        explorerUrl: "https://snowtrace.io",
        nativeCurrency: NativeCurrency(
            name: "Avalanche",
            symbol: "AVAX",
            decimals: 18,
            logoUrl: "https://assets.coingecko.com/coins/images/12559/small/avalanche-avax-logo.png"
        ),
        blockTime: 2,
        features: [.smartContracts, .deFi, .nfts, .staking, .scalability]
    )
    
    /// Ethereum Goerli Testnet
    static let goerli = Blockchain(
        id: "goerli",
        name: "Goerli",
        chainId: 5,
        rpcUrl: "https://goerli.infura.io/v3/YOUR_PROJECT_ID",
        explorerUrl: "https://goerli.etherscan.io",
        nativeCurrency: NativeCurrency(
            name: "Goerli Ether",
            symbol: "ETH",
            decimals: 18
        ),
        blockTime: 12,
        isTestnet: true,
        features: [.smartContracts, .deFi, .nfts]
    )
    
    /// Polygon Mumbai Testnet
    static let mumbai = Blockchain(
        id: "mumbai",
        name: "Mumbai",
        chainId: 80001,
        rpcUrl: "https://rpc-mumbai.maticvigil.com",
        explorerUrl: "https://mumbai.polygonscan.com",
        nativeCurrency: NativeCurrency(
            name: "MATIC",
            symbol: "MATIC",
            decimals: 18
        ),
        blockTime: 2,
        isTestnet: true,
        features: [.smartContracts, .deFi, .nfts]
    )
    
    /// All supported mainnets
    static let allMainnets: [Blockchain] = [
        .ethereum,
        .polygon,
        .binanceSmartChain,
        .arbitrum,
        .optimism,
        .avalanche
    ]
    
    /// All supported testnets
    static let allTestnets: [Blockchain] = [
        .goerli,
        .mumbai
    ]
    
    /// All supported networks
    static let allNetworks: [Blockchain] = allMainnets + allTestnets
}

/// Blockchain utilities
public extension Blockchain {
    
    /// Find blockchain by chain ID
    static func findByChainId(_ chainId: Int) -> Blockchain? {
        return allNetworks.first { $0.chainId == chainId }
    }
    
    /// Find blockchain by ID
    static func findById(_ id: String) -> Blockchain? {
        return allNetworks.first { $0.id == id }
    }
    
    /// Get all active networks
    static var activeNetworks: [Blockchain] {
        return allNetworks.filter { $0.status.isAvailable }
    }
    
    /// Get networks supporting specific feature
    static func networksSupporting(_ feature: BlockchainFeature) -> [Blockchain] {
        return allNetworks.filter { $0.features.contains(feature) }
    }
    
    /// Get mainnet networks
    static var mainnetNetworks: [Blockchain] {
        return allMainnets.filter { $0.status.isAvailable }
    }
    
    /// Get testnet networks
    static var testnetNetworks: [Blockchain] {
        return allTestnets.filter { $0.status.isAvailable }
    }
} 