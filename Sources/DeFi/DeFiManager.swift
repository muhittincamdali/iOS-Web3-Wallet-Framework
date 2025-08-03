import Foundation
import Alamofire
import Logging

/// Manages DeFi protocol integrations and operations
@available(iOS 15.0, *)
public class DeFiManager {
    
    // MARK: - Properties
    
    /// Alamofire session for network requests
    private let session: Session
    
    /// Logger for DeFi operations
    private let logger = Logger(label: "DeFiManager")
    
    /// Supported DeFi protocols
    private let supportedProtocols: [DeFiProtocol] = [
        .uniswapV2,
        .uniswapV3,
        .sushiswap,
        .aave,
        .compound,
        .yearn,
        .curve
    ]
    
    /// Protocol configurations
    private var protocolConfigs: [DeFiProtocol: ProtocolConfig] = [:]
    
    // MARK: - Initialization
    
    /// Initialize DeFiManager
    public init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 30.0
        
        self.session = Session(configuration: configuration)
        setupProtocolConfigurations()
    }
    
    // MARK: - Protocol Management
    
    /// Gets available DeFi protocols
    /// - Returns: Array of available protocols
    public func getAvailableProtocols() async throws -> [DeFiProtocol] {
        logger.info("Getting available DeFi protocols")
        return supportedProtocols
    }
    
    /// Gets protocol configuration
    /// - Parameter protocol: DeFi protocol
    /// - Returns: Protocol configuration
    /// - Throws: `DeFiError.unsupportedProtocol` if protocol is not supported
    public func getProtocolConfig(_ protocol: DeFiProtocol) throws -> ProtocolConfig {
        guard let config = protocolConfigs[protocol] else {
            throw DeFiError.unsupportedProtocol
        }
        return config
    }
    
    // MARK: - Token Operations
    
    /// Gets token information
    /// - Parameter tokenAddress: Token contract address
    /// - Returns: Token information
    /// - Throws: `DeFiError.tokenInfoFailed` if token info retrieval fails
    public func getTokenInfo(_ tokenAddress: String) async throws -> TokenInfo {
        logger.info("Getting token info for: \(tokenAddress)")
        
        // This is a simplified implementation
        // In a real implementation, you would call the token contract
        
        let tokenInfo = TokenInfo(
            address: tokenAddress,
            name: "Unknown Token",
            symbol: "UNK",
            decimals: 18,
            totalSupply: "0",
            price: "0"
        )
        
        logger.info("Token info retrieved")
        return tokenInfo
    }
    
    /// Gets token price
    /// - Parameter tokenAddress: Token contract address
    /// - Returns: Token price in USD
    /// - Throws: `DeFiError.priceFetchFailed` if price fetch fails
    public func getTokenPrice(_ tokenAddress: String) async throws -> String {
        logger.info("Getting token price for: \(tokenAddress)")
        
        // This is a simplified implementation
        // In a real implementation, you would call a price oracle or DEX
        
        let price = "1.0" // Mock price
        
        logger.info("Token price retrieved: \(price)")
        return price
    }
    
    // MARK: - Swap Operations
    
    /// Creates a swap transaction using Uniswap V2
    /// - Parameters:
    ///   - swapRequest: Swap request details
    ///   - wallet: Wallet to create transaction for
    /// - Returns: Transaction for the swap
    /// - Throws: `DeFiError.swapCreationFailed` if swap creation fails
    public func createSwapTransaction(_ swapRequest: SwapRequest, for wallet: Wallet) async throws -> Transaction {
        logger.info("Creating swap transaction: \(swapRequest.fromToken) -> \(swapRequest.toToken)")
        
        // Validate swap request
        try validateSwapRequest(swapRequest)
        
        // Get protocol configuration
        let protocol: DeFiProtocol
        switch swapRequest.protocol {
        case .uniswapV2:
            protocol = .uniswapV2
        case .uniswapV3:
            protocol = .uniswapV3
        case .sushiswap:
            protocol = .sushiswap
        default:
            throw DeFiError.unsupportedProtocol
        }
        
        let config = try getProtocolConfig(protocol)
        
        // Create swap transaction
        let transaction = Transaction(
            from: wallet.address,
            to: config.routerAddress,
            value: swapRequest.fromToken == "ETH" ? swapRequest.amount : "0",
            gasLimit: 200000,
            nonce: 0, // Would need to get from network
            data: createSwapData(swapRequest, config: config),
            chain: .ethereum, // Would need to get from request
            type: .legacy
        )
        
        logger.info("Swap transaction created successfully")
        return transaction
    }
    
    /// Gets swap quote
    /// - Parameter swapRequest: Swap request details
    /// - Returns: Swap quote
    /// - Throws: `DeFiError.quoteFailed` if quote retrieval fails
    public func getSwapQuote(_ swapRequest: SwapRequest) async throws -> SwapQuote {
        logger.info("Getting swap quote: \(swapRequest.fromToken) -> \(swapRequest.toToken)")
        
        // Validate swap request
        try validateSwapRequest(swapRequest)
        
        // This is a simplified implementation
        // In a real implementation, you would call the DEX API
        
        let quote = SwapQuote(
            fromToken: swapRequest.fromToken,
            toToken: swapRequest.toToken,
            fromAmount: swapRequest.amount,
            toAmount: swapRequest.amount, // Mock 1:1 ratio
            priceImpact: 0.1,
            gasEstimate: 150000,
            protocol: swapRequest.protocol,
            route: [swapRequest.fromToken, swapRequest.toToken]
        )
        
        logger.info("Swap quote retrieved")
        return quote
    }
    
    // MARK: - Liquidity Operations
    
    /// Creates add liquidity transaction
    /// - Parameters:
    ///   - liquidityRequest: Liquidity request details
    ///   - wallet: Wallet to create transaction for
    /// - Returns: Transaction for adding liquidity
    /// - Throws: `DeFiError.liquidityCreationFailed` if liquidity creation fails
    public func createAddLiquidityTransaction(_ liquidityRequest: LiquidityRequest, for wallet: Wallet) async throws -> Transaction {
        logger.info("Creating add liquidity transaction")
        
        // Validate liquidity request
        try validateLiquidityRequest(liquidityRequest)
        
        let config = try getProtocolConfig(liquidityRequest.protocol)
        
        // Create add liquidity transaction
        let transaction = Transaction(
            from: wallet.address,
            to: config.routerAddress,
            value: "0",
            gasLimit: 300000,
            nonce: 0,
            data: createAddLiquidityData(liquidityRequest, config: config),
            chain: .ethereum,
            type: .legacy
        )
        
        logger.info("Add liquidity transaction created successfully")
        return transaction
    }
    
    /// Creates remove liquidity transaction
    /// - Parameters:
    ///   - liquidityRequest: Liquidity request details
    ///   - wallet: Wallet to create transaction for
    /// - Returns: Transaction for removing liquidity
    /// - Throws: `DeFiError.liquidityRemovalFailed` if liquidity removal fails
    public func createRemoveLiquidityTransaction(_ liquidityRequest: LiquidityRequest, for wallet: Wallet) async throws -> Transaction {
        logger.info("Creating remove liquidity transaction")
        
        // Validate liquidity request
        try validateLiquidityRequest(liquidityRequest)
        
        let config = try getProtocolConfig(liquidityRequest.protocol)
        
        // Create remove liquidity transaction
        let transaction = Transaction(
            from: wallet.address,
            to: config.routerAddress,
            value: "0",
            gasLimit: 300000,
            nonce: 0,
            data: createRemoveLiquidityData(liquidityRequest, config: config),
            chain: .ethereum,
            type: .legacy
        )
        
        logger.info("Remove liquidity transaction created successfully")
        return transaction
    }
    
    // MARK: - Lending Operations
    
    /// Creates deposit transaction for lending protocols
    /// - Parameters:
    ///   - depositRequest: Deposit request details
    ///   - wallet: Wallet to create transaction for
    /// - Returns: Transaction for deposit
    /// - Throws: `DeFiError.depositFailed` if deposit creation fails
    public func createDepositTransaction(_ depositRequest: DepositRequest, for wallet: Wallet) async throws -> Transaction {
        logger.info("Creating deposit transaction for: \(depositRequest.protocol)")
        
        // Validate deposit request
        try validateDepositRequest(depositRequest)
        
        let config = try getProtocolConfig(depositRequest.protocol)
        
        // Create deposit transaction
        let transaction = Transaction(
            from: wallet.address,
            to: config.lendingPoolAddress,
            value: depositRequest.amount,
            gasLimit: 200000,
            nonce: 0,
            data: createDepositData(depositRequest, config: config),
            chain: .ethereum,
            type: .legacy
        )
        
        logger.info("Deposit transaction created successfully")
        return transaction
    }
    
    /// Creates withdraw transaction for lending protocols
    /// - Parameters:
    ///   - withdrawRequest: Withdraw request details
    ///   - wallet: Wallet to create transaction for
    /// - Returns: Transaction for withdraw
    /// - Throws: `DeFiError.withdrawFailed` if withdraw creation fails
    public func createWithdrawTransaction(_ withdrawRequest: WithdrawRequest, for wallet: Wallet) async throws -> Transaction {
        logger.info("Creating withdraw transaction for: \(withdrawRequest.protocol)")
        
        // Validate withdraw request
        try validateWithdrawRequest(withdrawRequest)
        
        let config = try getProtocolConfig(withdrawRequest.protocol)
        
        // Create withdraw transaction
        let transaction = Transaction(
            from: wallet.address,
            to: config.lendingPoolAddress,
            value: "0",
            gasLimit: 200000,
            nonce: 0,
            data: createWithdrawData(withdrawRequest, config: config),
            chain: .ethereum,
            type: .legacy
        )
        
        logger.info("Withdraw transaction created successfully")
        return transaction
    }
    
    // MARK: - Yield Farming
    
    /// Creates stake transaction for yield farming
    /// - Parameters:
    ///   - stakeRequest: Stake request details
    ///   - wallet: Wallet to create transaction for
    /// - Returns: Transaction for staking
    /// - Throws: `DeFiError.stakingFailed` if staking creation fails
    public func createStakeTransaction(_ stakeRequest: StakeRequest, for wallet: Wallet) async throws -> Transaction {
        logger.info("Creating stake transaction for: \(stakeRequest.protocol)")
        
        // Validate stake request
        try validateStakeRequest(stakeRequest)
        
        let config = try getProtocolConfig(stakeRequest.protocol)
        
        // Create stake transaction
        let transaction = Transaction(
            from: wallet.address,
            to: config.stakingAddress,
            value: "0",
            gasLimit: 200000,
            nonce: 0,
            data: createStakeData(stakeRequest, config: config),
            chain: .ethereum,
            type: .legacy
        )
        
        logger.info("Stake transaction created successfully")
        return transaction
    }
    
    /// Creates unstake transaction for yield farming
    /// - Parameters:
    ///   - unstakeRequest: Unstake request details
    ///   - wallet: Wallet to create transaction for
    /// - Returns: Transaction for unstaking
    /// - Throws: `DeFiError.unstakingFailed` if unstaking creation fails
    public func createUnstakeTransaction(_ unstakeRequest: UnstakeRequest, for wallet: Wallet) async throws -> Transaction {
        logger.info("Creating unstake transaction for: \(unstakeRequest.protocol)")
        
        // Validate unstake request
        try validateUnstakeRequest(unstakeRequest)
        
        let config = try getProtocolConfig(unstakeRequest.protocol)
        
        // Create unstake transaction
        let transaction = Transaction(
            from: wallet.address,
            to: config.stakingAddress,
            value: "0",
            gasLimit: 200000,
            nonce: 0,
            data: createUnstakeData(unstakeRequest, config: config),
            chain: .ethereum,
            type: .legacy
        )
        
        logger.info("Unstake transaction created successfully")
        return transaction
    }
    
    // MARK: - Private Methods
    
    /// Sets up protocol configurations
    private func setupProtocolConfigurations() {
        protocolConfigs = [
            .uniswapV2: ProtocolConfig(
                name: "Uniswap V2",
                routerAddress: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
                factoryAddress: "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f",
                lendingPoolAddress: nil,
                stakingAddress: nil
            ),
            .uniswapV3: ProtocolConfig(
                name: "Uniswap V3",
                routerAddress: "0xE592427A0AEce92De3Edee1F18E0157C05861564",
                factoryAddress: "0x1F98431c8aD98523631AE4a59f267346ea31F984",
                lendingPoolAddress: nil,
                stakingAddress: nil
            ),
            .sushiswap: ProtocolConfig(
                name: "SushiSwap",
                routerAddress: "0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F",
                factoryAddress: "0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac",
                lendingPoolAddress: nil,
                stakingAddress: nil
            ),
            .aave: ProtocolConfig(
                name: "Aave",
                routerAddress: nil,
                factoryAddress: nil,
                lendingPoolAddress: "0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9",
                stakingAddress: nil
            ),
            .compound: ProtocolConfig(
                name: "Compound",
                routerAddress: nil,
                factoryAddress: nil,
                lendingPoolAddress: "0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B",
                stakingAddress: nil
            ),
            .yearn: ProtocolConfig(
                name: "Yearn Finance",
                routerAddress: nil,
                factoryAddress: nil,
                lendingPoolAddress: nil,
                stakingAddress: "0x0000000000000000000000000000000000000000"
            ),
            .curve: ProtocolConfig(
                name: "Curve Finance",
                routerAddress: "0x99a58482BD75cbab83b27EC03CA68fF489b5788f",
                factoryAddress: nil,
                lendingPoolAddress: nil,
                stakingAddress: nil
            )
        ]
    }
    
    /// Validates swap request
    /// - Parameter swapRequest: Swap request to validate
    /// - Throws: `DeFiError.invalidSwapRequest` if request is invalid
    private func validateSwapRequest(_ swapRequest: SwapRequest) throws {
        guard !swapRequest.fromToken.isEmpty,
              !swapRequest.toToken.isEmpty,
              !swapRequest.amount.isEmpty,
              swapRequest.slippage > 0 && swapRequest.slippage <= 100 else {
            throw DeFiError.invalidSwapRequest
        }
    }
    
    /// Validates liquidity request
    /// - Parameter liquidityRequest: Liquidity request to validate
    /// - Throws: `DeFiError.invalidLiquidityRequest` if request is invalid
    private func validateLiquidityRequest(_ liquidityRequest: LiquidityRequest) throws {
        guard !liquidityRequest.tokenA.isEmpty,
              !liquidityRequest.tokenB.isEmpty,
              !liquidityRequest.amountA.isEmpty,
              !liquidityRequest.amountB.isEmpty else {
            throw DeFiError.invalidLiquidityRequest
        }
    }
    
    /// Validates deposit request
    /// - Parameter depositRequest: Deposit request to validate
    /// - Throws: `DeFiError.invalidDepositRequest` if request is invalid
    private func validateDepositRequest(_ depositRequest: DepositRequest) throws {
        guard !depositRequest.token.isEmpty,
              !depositRequest.amount.isEmpty else {
            throw DeFiError.invalidDepositRequest
        }
    }
    
    /// Validates withdraw request
    /// - Parameter withdrawRequest: Withdraw request to validate
    /// - Throws: `DeFiError.invalidWithdrawRequest` if request is invalid
    private func validateWithdrawRequest(_ withdrawRequest: WithdrawRequest) throws {
        guard !withdrawRequest.token.isEmpty,
              !withdrawRequest.amount.isEmpty else {
            throw DeFiError.invalidWithdrawRequest
        }
    }
    
    /// Validates stake request
    /// - Parameter stakeRequest: Stake request to validate
    /// - Throws: `DeFiError.invalidStakeRequest` if request is invalid
    private func validateStakeRequest(_ stakeRequest: StakeRequest) throws {
        guard !stakeRequest.token.isEmpty,
              !stakeRequest.amount.isEmpty else {
            throw DeFiError.invalidStakeRequest
        }
    }
    
    /// Validates unstake request
    /// - Parameter unstakeRequest: Unstake request to validate
    /// - Throws: `DeFiError.invalidUnstakeRequest` if request is invalid
    private func validateUnstakeRequest(_ unstakeRequest: UnstakeRequest) throws {
        guard !unstakeRequest.token.isEmpty,
              !unstakeRequest.amount.isEmpty else {
            throw DeFiError.invalidUnstakeRequest
        }
    }
    
    /// Creates swap data for transaction
    /// - Parameters:
    ///   - swapRequest: Swap request
    ///   - config: Protocol configuration
    /// - Returns: Transaction data
    private func createSwapData(_ swapRequest: SwapRequest, config: ProtocolConfig) -> String {
        // This is a simplified implementation
        // In a real implementation, you would create proper ABI encoded data
        return "0x" + "swap".data(using: .utf8)!.toHexString()
    }
    
    /// Creates add liquidity data for transaction
    /// - Parameters:
    ///   - liquidityRequest: Liquidity request
    ///   - config: Protocol configuration
    /// - Returns: Transaction data
    private func createAddLiquidityData(_ liquidityRequest: LiquidityRequest, config: ProtocolConfig) -> String {
        // This is a simplified implementation
        return "0x" + "addLiquidity".data(using: .utf8)!.toHexString()
    }
    
    /// Creates remove liquidity data for transaction
    /// - Parameters:
    ///   - liquidityRequest: Liquidity request
    ///   - config: Protocol configuration
    /// - Returns: Transaction data
    private func createRemoveLiquidityData(_ liquidityRequest: LiquidityRequest, config: ProtocolConfig) -> String {
        // This is a simplified implementation
        return "0x" + "removeLiquidity".data(using: .utf8)!.toHexString()
    }
    
    /// Creates deposit data for transaction
    /// - Parameters:
    ///   - depositRequest: Deposit request
    ///   - config: Protocol configuration
    /// - Returns: Transaction data
    private func createDepositData(_ depositRequest: DepositRequest, config: ProtocolConfig) -> String {
        // This is a simplified implementation
        return "0x" + "deposit".data(using: .utf8)!.toHexString()
    }
    
    /// Creates withdraw data for transaction
    /// - Parameters:
    ///   - withdrawRequest: Withdraw request
    ///   - config: Protocol configuration
    /// - Returns: Transaction data
    private func createWithdrawData(_ withdrawRequest: WithdrawRequest, config: ProtocolConfig) -> String {
        // This is a simplified implementation
        return "0x" + "withdraw".data(using: .utf8)!.toHexString()
    }
    
    /// Creates stake data for transaction
    /// - Parameters:
    ///   - stakeRequest: Stake request
    ///   - config: Protocol configuration
    /// - Returns: Transaction data
    private func createStakeData(_ stakeRequest: StakeRequest, config: ProtocolConfig) -> String {
        // This is a simplified implementation
        return "0x" + "stake".data(using: .utf8)!.toHexString()
    }
    
    /// Creates unstake data for transaction
    /// - Parameters:
    ///   - unstakeRequest: Unstake request
    ///   - config: Protocol configuration
    /// - Returns: Transaction data
    private func createUnstakeData(_ unstakeRequest: UnstakeRequest, config: ProtocolConfig) -> String {
        // This is a simplified implementation
        return "0x" + "unstake".data(using: .utf8)!.toHexString()
    }
}

// MARK: - Supporting Types

/// Supported DeFi protocols
public enum DeFiProtocol: String, Codable, CaseIterable {
    case uniswapV2 = "UniswapV2"
    case uniswapV3 = "UniswapV3"
    case sushiswap = "SushiSwap"
    case aave = "Aave"
    case compound = "Compound"
    case yearn = "Yearn"
    case curve = "Curve"
    
    public var displayName: String {
        switch self {
        case .uniswapV2:
            return "Uniswap V2"
        case .uniswapV3:
            return "Uniswap V3"
        case .sushiswap:
            return "SushiSwap"
        case .aave:
            return "Aave"
        case .compound:
            return "Compound"
        case .yearn:
            return "Yearn Finance"
        case .curve:
            return "Curve Finance"
        }
    }
}

/// Protocol configuration
public struct ProtocolConfig: Codable, Equatable {
    public let name: String
    public let routerAddress: String?
    public let factoryAddress: String?
    public let lendingPoolAddress: String?
    public let stakingAddress: String?
    
    public init(name: String, routerAddress: String?, factoryAddress: String?, lendingPoolAddress: String?, stakingAddress: String?) {
        self.name = name
        self.routerAddress = routerAddress
        self.factoryAddress = factoryAddress
        self.lendingPoolAddress = lendingPoolAddress
        self.stakingAddress = stakingAddress
    }
}

/// Token information
public struct TokenInfo: Codable, Equatable {
    public let address: String
    public let name: String
    public let symbol: String
    public let decimals: Int
    public let totalSupply: String
    public let price: String
    
    public init(address: String, name: String, symbol: String, decimals: Int, totalSupply: String, price: String) {
        self.address = address
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.totalSupply = totalSupply
        self.price = price
    }
}

/// Swap request
public struct SwapRequest: Codable, Equatable {
    public let fromToken: String
    public let toToken: String
    public let amount: String
    public let slippage: Double
    public let protocol: DeFiProtocol
    
    public init(fromToken: String, toToken: String, amount: String, slippage: Double, protocol: DeFiProtocol = .uniswapV2) {
        self.fromToken = fromToken
        self.toToken = toToken
        self.amount = amount
        self.slippage = slippage
        self.protocol = protocol
    }
}

/// Swap quote
public struct SwapQuote: Codable, Equatable {
    public let fromToken: String
    public let toToken: String
    public let fromAmount: String
    public let toAmount: String
    public let priceImpact: Double
    public let gasEstimate: UInt64
    public let protocol: DeFiProtocol
    public let route: [String]
    
    public init(fromToken: String, toToken: String, fromAmount: String, toAmount: String, priceImpact: Double, gasEstimate: UInt64, protocol: DeFiProtocol, route: [String]) {
        self.fromToken = fromToken
        self.toToken = toToken
        self.fromAmount = fromAmount
        self.toAmount = toAmount
        self.priceImpact = priceImpact
        self.gasEstimate = gasEstimate
        self.protocol = protocol
        self.route = route
    }
}

/// Liquidity request
public struct LiquidityRequest: Codable, Equatable {
    public let tokenA: String
    public let tokenB: String
    public let amountA: String
    public let amountB: String
    public let protocol: DeFiProtocol
    
    public init(tokenA: String, tokenB: String, amountA: String, amountB: String, protocol: DeFiProtocol = .uniswapV2) {
        self.tokenA = tokenA
        self.tokenB = tokenB
        self.amountA = amountA
        self.amountB = amountB
        self.protocol = protocol
    }
}

/// Deposit request
public struct DepositRequest: Codable, Equatable {
    public let token: String
    public let amount: String
    public let protocol: DeFiProtocol
    
    public init(token: String, amount: String, protocol: DeFiProtocol) {
        self.token = token
        self.amount = amount
        self.protocol = protocol
    }
}

/// Withdraw request
public struct WithdrawRequest: Codable, Equatable {
    public let token: String
    public let amount: String
    public let protocol: DeFiProtocol
    
    public init(token: String, amount: String, protocol: DeFiProtocol) {
        self.token = token
        self.amount = amount
        self.protocol = protocol
    }
}

/// Stake request
public struct StakeRequest: Codable, Equatable {
    public let token: String
    public let amount: String
    public let protocol: DeFiProtocol
    
    public init(token: String, amount: String, protocol: DeFiProtocol) {
        self.token = token
        self.amount = amount
        self.protocol = protocol
    }
}

/// Unstake request
public struct UnstakeRequest: Codable, Equatable {
    public let token: String
    public let amount: String
    public let protocol: DeFiProtocol
    
    public init(token: String, amount: String, protocol: DeFiProtocol) {
        self.token = token
        self.amount = amount
        self.protocol = protocol
    }
}

// MARK: - Error Types

/// DeFi-related errors
public enum DeFiError: LocalizedError {
    case unsupportedProtocol
    case invalidSwapRequest
    case invalidLiquidityRequest
    case invalidDepositRequest
    case invalidWithdrawRequest
    case invalidStakeRequest
    case invalidUnstakeRequest
    case swapCreationFailed
    case liquidityCreationFailed
    case liquidityRemovalFailed
    case depositFailed
    case withdrawFailed
    case stakingFailed
    case unstakingFailed
    case quoteFailed
    case tokenInfoFailed
    case priceFetchFailed
    
    public var errorDescription: String? {
        switch self {
        case .unsupportedProtocol:
            return "Unsupported DeFi protocol"
        case .invalidSwapRequest:
            return "Invalid swap request parameters"
        case .invalidLiquidityRequest:
            return "Invalid liquidity request parameters"
        case .invalidDepositRequest:
            return "Invalid deposit request parameters"
        case .invalidWithdrawRequest:
            return "Invalid withdraw request parameters"
        case .invalidStakeRequest:
            return "Invalid stake request parameters"
        case .invalidUnstakeRequest:
            return "Invalid unstake request parameters"
        case .swapCreationFailed:
            return "Failed to create swap transaction"
        case .liquidityCreationFailed:
            return "Failed to create liquidity transaction"
        case .liquidityRemovalFailed:
            return "Failed to create liquidity removal transaction"
        case .depositFailed:
            return "Failed to create deposit transaction"
        case .withdrawFailed:
            return "Failed to create withdraw transaction"
        case .stakingFailed:
            return "Failed to create stake transaction"
        case .unstakingFailed:
            return "Failed to create unstake transaction"
        case .quoteFailed:
            return "Failed to get swap quote"
        case .tokenInfoFailed:
            return "Failed to get token information"
        case .priceFetchFailed:
            return "Failed to fetch token price"
        }
    }
} 