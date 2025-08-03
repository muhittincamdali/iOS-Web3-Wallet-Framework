import Foundation

/// Represents a cryptocurrency token
public struct Token: Codable, Equatable, Hashable {
    
    /// Token contract address
    public let address: String
    
    /// Token name
    public let name: String
    
    /// Token symbol
    public let symbol: String
    
    /// Number of decimals
    public let decimals: Int
    
    /// Total supply
    public let totalSupply: String?
    
    /// Token logo URL
    public let logoUrl: String?
    
    /// Token website URL
    public let websiteUrl: String?
    
    /// Token description
    public let description: String?
    
    /// Blockchain network
    public let blockchain: Blockchain
    
    /// Token type
    public let type: TokenType
    
    /// Token standard
    public let standard: TokenStandard
    
    /// Whether token is verified
    public let isVerified: Bool
    
    /// Creation date
    public let createdAt: Date
    
    /// Last updated date
    public let updatedAt: Date
    
    public init(
        address: String,
        name: String,
        symbol: String,
        decimals: Int,
        totalSupply: String? = nil,
        logoUrl: String? = nil,
        websiteUrl: String? = nil,
        description: String? = nil,
        blockchain: Blockchain,
        type: TokenType = .fungible,
        standard: TokenStandard = .erc20,
        isVerified: Bool = false
    ) {
        self.address = address
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.totalSupply = totalSupply
        self.logoUrl = logoUrl
        self.websiteUrl = websiteUrl
        self.description = description
        self.blockchain = blockchain
        self.type = type
        self.standard = standard
        self.isVerified = isVerified
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Short address for display
    public var shortAddress: String {
        guard address.count > 10 else { return address }
        let start = address.prefix(6)
        let end = address.suffix(4)
        return "\(start)...\(end)"
    }
    
    /// Whether this is a native token
    public var isNative: Bool {
        return address.isEmpty || address == "0x0000000000000000000000000000000000000000"
    }
    
    /// Whether this is a stablecoin
    public var isStablecoin: Bool {
        let stablecoins = ["USDC", "USDT", "DAI", "BUSD", "TUSD", "FRAX", "USDP", "GUSD"]
        return stablecoins.contains(symbol.uppercased())
    }
    
    /// Whether this is a governance token
    public var isGovernanceToken: Bool {
        let governanceTokens = ["UNI", "AAVE", "COMP", "CRV", "SUSHI", "YFI", "BAL", "SNX"]
        return governanceTokens.contains(symbol.uppercased())
    }
    
    /// Validate token
    public func validate() throws {
        guard !name.isEmpty else {
            throw TokenError.invalidName
        }
        
        guard !symbol.isEmpty else {
            throw TokenError.invalidSymbol
        }
        
        guard decimals >= 0 && decimals <= 18 else {
            throw TokenError.invalidDecimals
        }
        
        if !isNative {
            guard !address.isEmpty else {
                throw TokenError.invalidAddress
            }
            
            guard blockchain.validateEthereumAddress(address) else {
                throw TokenError.invalidAddress
            }
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
    
    /// Get display name
    public var displayName: String {
        return "\(name) (\(symbol))"
    }
    
    /// Get full name with network
    public var fullDisplayName: String {
        return "\(name) (\(symbol)) on \(blockchain.name)"
    }
}

/// Token type
public enum TokenType: String, Codable, CaseIterable {
    case fungible = "fungible"
    case nonFungible = "non_fungible"
    case semiFungible = "semi_fungible"
    case wrapped = "wrapped"
    case governance = "governance"
    case staking = "staking"
    case reward = "reward"
    
    /// Display name for the token type
    public var displayName: String {
        switch self {
        case .fungible:
            return "Fungible Token"
        case .nonFungible:
            return "Non-Fungible Token"
        case .semiFungible:
            return "Semi-Fungible Token"
        case .wrapped:
            return "Wrapped Token"
        case .governance:
            return "Governance Token"
        case .staking:
            return "Staking Token"
        case .reward:
            return "Reward Token"
        }
    }
    
    /// Description of the token type
    public var description: String {
        switch self {
        case .fungible:
            return "Standard fungible token with identical units"
        case .nonFungible:
            return "Unique token with individual characteristics"
        case .semiFungible:
            return "Token with both fungible and non-fungible properties"
        case .wrapped:
            return "Token representing another asset on different blockchain"
        case .governance:
            return "Token used for protocol governance"
        case .staking:
            return "Token used for staking rewards"
        case .reward:
            return "Token distributed as rewards"
        }
    }
}

/// Token standard
public enum TokenStandard: String, Codable, CaseIterable {
    case erc20 = "ERC-20"
    case erc721 = "ERC-721"
    case erc1155 = "ERC-1155"
    case erc777 = "ERC-777"
    case bep20 = "BEP-20"
    case native = "Native"
    case custom = "Custom"
    
    /// Display name for the token standard
    public var displayName: String {
        return rawValue
    }
    
    /// Description of the token standard
    public var description: String {
        switch self {
        case .erc20:
            return "Ethereum fungible token standard"
        case .erc721:
            return "Ethereum non-fungible token standard"
        case .erc1155:
            return "Ethereum multi-token standard"
        case .erc777:
            return "Ethereum advanced token standard"
        case .bep20:
            return "Binance Smart Chain token standard"
        case .native:
            return "Native blockchain token"
        case .custom:
            return "Custom token implementation"
        }
    }
    
    /// Whether this standard supports fungible tokens
    public var supportsFungible: Bool {
        switch self {
        case .erc20, .erc777, .bep20, .native:
            return true
        case .erc721, .erc1155, .custom:
            return false
        }
    }
    
    /// Whether this standard supports non-fungible tokens
    public var supportsNonFungible: Bool {
        switch self {
        case .erc721, .erc1155:
            return true
        case .erc20, .erc777, .bep20, .native, .custom:
            return false
        }
    }
}

/// Token errors
public enum TokenError: Error, LocalizedError {
    case invalidAddress
    case invalidName
    case invalidSymbol
    case invalidDecimals
    case tokenNotFound
    case unsupportedStandard
    case networkMismatch
    case verificationFailed
    
    public var errorDescription: String? {
        switch self {
        case .invalidAddress:
            return "Invalid token address"
        case .invalidName:
            return "Invalid token name"
        case .invalidSymbol:
            return "Invalid token symbol"
        case .invalidDecimals:
            return "Invalid token decimals"
        case .tokenNotFound:
            return "Token not found"
        case .unsupportedStandard:
            return "Unsupported token standard"
        case .networkMismatch:
            return "Token network mismatch"
        case .verificationFailed:
            return "Token verification failed"
        }
    }
}

/// Token utilities
public extension Token {
    
    /// Common tokens by symbol
    static func findBySymbol(_ symbol: String, on blockchain: Blockchain) -> Token? {
        return commonTokens.first { $0.symbol.uppercased() == symbol.uppercased() && $0.blockchain.id == blockchain.id }
    }
    
    /// Common tokens by address
    static func findByAddress(_ address: String, on blockchain: Blockchain) -> Token? {
        return commonTokens.first { $0.address.lowercased() == address.lowercased() && $0.blockchain.id == blockchain.id }
    }
    
    /// Get native token for blockchain
    static func nativeToken(for blockchain: Blockchain) -> Token {
        return Token(
            address: "",
            name: blockchain.nativeCurrency.name,
            symbol: blockchain.nativeCurrency.symbol,
            decimals: blockchain.nativeCurrency.decimals,
            logoUrl: blockchain.nativeCurrency.logoUrl,
            blockchain: blockchain,
            type: .fungible,
            standard: .native,
            isVerified: true
        )
    }
    
    /// Common tokens list
    static let commonTokens: [Token] = [
        // Ethereum tokens
        Token(
            address: "0xA0b86a33E6441b8c4C8C1C1B0Bc42E2c2c2c2c2c",
            name: "USD Coin",
            symbol: "USDC",
            decimals: 6,
            logoUrl: "https://assets.coingecko.com/coins/images/6319/small/USD_Coin_icon.png",
            websiteUrl: "https://www.circle.com/en/usdc",
            description: "USD Coin (USDC) is a stablecoin pegged to the US Dollar",
            blockchain: .ethereum,
            type: .fungible,
            standard: .erc20,
            isVerified: true
        ),
        Token(
            address: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
            name: "Tether USD",
            symbol: "USDT",
            decimals: 6,
            logoUrl: "https://assets.coingecko.com/coins/images/325/small/Tether.png",
            websiteUrl: "https://tether.to",
            description: "Tether (USDT) is a stablecoin pegged to the US Dollar",
            blockchain: .ethereum,
            type: .fungible,
            standard: .erc20,
            isVerified: true
        ),
        Token(
            address: "0x6B175474E89094C44Da98b954EedeAC495271d0F",
            name: "Dai",
            symbol: "DAI",
            decimals: 18,
            logoUrl: "https://assets.coingecko.com/coins/images/9956/small/4943.png",
            websiteUrl: "https://makerdao.com",
            description: "Dai is a decentralized stablecoin",
            blockchain: .ethereum,
            type: .fungible,
            standard: .erc20,
            isVerified: true
        ),
        Token(
            address: "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984",
            name: "Uniswap",
            symbol: "UNI",
            decimals: 18,
            logoUrl: "https://assets.coingecko.com/coins/images/12504/small/uniswap-uni.png",
            websiteUrl: "https://uniswap.org",
            description: "Uniswap governance token",
            blockchain: .ethereum,
            type: .governance,
            standard: .erc20,
            isVerified: true
        ),
        Token(
            address: "0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9",
            name: "Aave",
            symbol: "AAVE",
            decimals: 18,
            logoUrl: "https://assets.coingecko.com/coins/images/12645/small/AAVE.png",
            websiteUrl: "https://aave.com",
            description: "Aave governance token",
            blockchain: .ethereum,
            type: .governance,
            standard: .erc20,
            isVerified: true
        ),
        
        // Polygon tokens
        Token(
            address: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
            name: "USD Coin",
            symbol: "USDC",
            decimals: 6,
            logoUrl: "https://assets.coingecko.com/coins/images/6319/small/USD_Coin_icon.png",
            websiteUrl: "https://www.circle.com/en/usdc",
            description: "USD Coin (USDC) is a stablecoin pegged to the US Dollar",
            blockchain: .polygon,
            type: .fungible,
            standard: .erc20,
            isVerified: true
        ),
        Token(
            address: "0xc2132D05D31c914a87C6611C10748AEb04B58e8F",
            name: "Tether USD",
            symbol: "USDT",
            decimals: 6,
            logoUrl: "https://assets.coingecko.com/coins/images/325/small/Tether.png",
            websiteUrl: "https://tether.to",
            description: "Tether (USDT) is a stablecoin pegged to the US Dollar",
            blockchain: .polygon,
            type: .fungible,
            standard: .erc20,
            isVerified: true
        ),
        
        // BSC tokens
        Token(
            address: "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d",
            name: "USD Coin",
            symbol: "USDC",
            decimals: 18,
            logoUrl: "https://assets.coingecko.com/coins/images/6319/small/USD_Coin_icon.png",
            websiteUrl: "https://www.circle.com/en/usdc",
            description: "USD Coin (USDC) is a stablecoin pegged to the US Dollar",
            blockchain: .binanceSmartChain,
            type: .fungible,
            standard: .bep20,
            isVerified: true
        ),
        Token(
            address: "0x55d398326f99059fF775485246999027B3197955",
            name: "Tether USD",
            symbol: "USDT",
            decimals: 18,
            logoUrl: "https://assets.coingecko.com/coins/images/325/small/Tether.png",
            websiteUrl: "https://tether.to",
            description: "Tether (USDT) is a stablecoin pegged to the US Dollar",
            blockchain: .binanceSmartChain,
            type: .fungible,
            standard: .bep20,
            isVerified: true
        )
    ]
}

/// Token balance
public struct TokenBalance: Codable, Equatable {
    
    /// Token
    public let token: Token
    
    /// Balance amount
    public let balance: String
    
    /// Formatted balance
    public let formattedBalance: String
    
    /// USD value
    public let usdValue: Double?
    
    /// Last updated
    public let lastUpdated: Date
    
    public init(
        token: Token,
        balance: String,
        usdValue: Double? = nil
    ) {
        self.token = token
        self.balance = balance
        self.formattedBalance = token.formatAmount(balance)
        self.usdValue = usdValue
        self.lastUpdated = Date()
    }
    
    /// Whether balance is zero
    public var isZero: Bool {
        return balance == "0" || balance.isEmpty
    }
    
    /// Whether balance is significant (more than dust)
    public var isSignificant: Bool {
        guard let balanceValue = Double(balance) else { return false }
        let dustThreshold = pow(10.0, Double(token.decimals - 6)) // 0.000001
        return balanceValue > dustThreshold
    }
    
    /// Get display value
    public var displayValue: String {
        if let usdValue = usdValue, usdValue > 0 {
            return String(format: "$%.2f", usdValue)
        } else {
            return formattedBalance
        }
    }
} 