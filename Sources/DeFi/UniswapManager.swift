import Foundation
import BigInt

/// Comprehensive Uniswap integration for DeFi operations
public class UniswapManager: ObservableObject {
    
    // MARK: - Properties
    
    /// Current Uniswap version
    @Published public var currentVersion: UniswapVersion = .v4
    
    /// Supported tokens
    @Published public var supportedTokens: [Token] = []
    
    /// Liquidity pools
    @Published public var liquidityPools: [LiquidityPool] = []
    
    /// Swap history
    @Published public var swapHistory: [SwapTransaction] = []
    
    /// Network manager for blockchain interactions
    private let networkManager: NetworkManager
    
    /// Transaction manager for swap transactions
    private let transactionManager: TransactionManager
    
    /// Price oracle for token prices
    private let priceOracle: PriceOracle
    
    // MARK: - Initializers
    
    /// Creates a Uniswap manager with default configuration
    public init() {
        self.networkManager = NetworkManager()
        self.transactionManager = TransactionManager()
        self.priceOracle = PriceOracle()
        setupTokenSupport()
    }
    
    /// Creates a Uniswap manager with custom configuration
    /// - Parameters:
    ///   - version: Uniswap version to use
    ///   - network: Blockchain network
    ///   - customRPC: Custom RPC endpoint
    public init(version: UniswapVersion, network: BlockchainNetwork, customRPC: String? = nil) {
        self.currentVersion = version
        self.networkManager = NetworkManager(customRPC: customRPC)
        self.transactionManager = TransactionManager(network: network)
        self.priceOracle = PriceOracle()
        setupTokenSupport()
    }
    
    // MARK: - Public Methods
    
    /// Performs a token swap
    /// - Parameters:
    ///   - swap: Swap parameters
    ///   - completion: Completion handler with result
    public func swap(_ swap: UniswapSwap, completion: @escaping (Result<String, SwapError>) -> Void) {
        Task {
            do {
                // Validate swap parameters
                try validateSwap(swap)
                
                // Get optimal route
                let route = try await getOptimalRoute(for: swap)
                
                // Calculate swap amounts
                let swapAmounts = try await calculateSwapAmounts(swap, route: route)
                
                // Create swap transaction
                let transaction = try await createSwapTransaction(swap, route: route, amounts: swapAmounts)
                
                // Execute swap
                let txHash = try await executeSwap(transaction)
                
                // Update local state
                await MainActor.run {
                    self.swapHistory.append(SwapTransaction(
                        from: swap.tokenIn,
                        to: swap.tokenOut,
                        amountIn: swap.amountIn,
                        amountOut: swapAmounts.amountOut,
                        txHash: txHash
                    ))
                }
                
                completion(.success(txHash))
                
            } catch {
                completion(.failure(SwapError.failed(error)))
            }
        }
    }
    
    /// Adds liquidity to a pool
    /// - Parameters:
    ///   - liquidity: Liquidity parameters
    ///   - completion: Completion handler with result
    public func addLiquidity(_ liquidity: AddLiquidityParams, completion: @escaping (Result<String, LiquidityError>) -> Void) {
        Task {
            do {
                // Validate liquidity parameters
                try validateLiquidityParams(liquidity)
                
                // Calculate optimal amounts
                let amounts = try await calculateLiquidityAmounts(liquidity)
                
                // Create add liquidity transaction
                let transaction = try await createAddLiquidityTransaction(liquidity, amounts: amounts)
                
                // Execute add liquidity
                let txHash = try await executeAddLiquidity(transaction)
                
                completion(.success(txHash))
                
            } catch {
                completion(.failure(LiquidityError.failed(error)))
            }
        }
    }
    
    /// Removes liquidity from a pool
    /// - Parameters:
    ///   - liquidity: Liquidity removal parameters
    ///   - completion: Completion handler with result
    public func removeLiquidity(_ liquidity: RemoveLiquidityParams, completion: @escaping (Result<String, LiquidityError>) -> Void) {
        Task {
            do {
                // Validate liquidity removal parameters
                try validateLiquidityRemovalParams(liquidity)
                
                // Calculate removal amounts
                let amounts = try await calculateRemovalAmounts(liquidity)
                
                // Create remove liquidity transaction
                let transaction = try await createRemoveLiquidityTransaction(liquidity, amounts: amounts)
                
                // Execute remove liquidity
                let txHash = try await executeRemoveLiquidity(transaction)
                
                completion(.success(txHash))
                
            } catch {
                completion(.failure(LiquidityError.failed(error)))
            }
        }
    }
    
    /// Gets token price
    /// - Parameter token: Token to get price for
    /// - Returns: Token price in USD
    public func getTokenPrice(_ token: Token) async throws -> Decimal {
        return try await priceOracle.getTokenPrice(token)
    }
    
    /// Gets pool information
    /// - Parameter pool: Pool to get information for
    /// - Returns: Pool information
    public func getPoolInfo(_ pool: LiquidityPool) async throws -> PoolInfo {
        return try await networkManager.getPoolInfo(pool.address)
    }
    
    /// Gets swap quote
    /// - Parameter swap: Swap parameters for quote
    /// - Returns: Swap quote with amounts and fees
    public func getSwapQuote(_ swap: UniswapSwap) async throws -> SwapQuote {
        // Get optimal route
        let route = try await getOptimalRoute(for: swap)
        
        // Calculate amounts
        let amounts = try await calculateSwapAmounts(swap, route: route)
        
        // Calculate fees
        let fees = try await calculateSwapFees(swap, route: route)
        
        return SwapQuote(
            tokenIn: swap.tokenIn,
            tokenOut: swap.tokenOut,
            amountIn: swap.amountIn,
            amountOut: amounts.amountOut,
            priceImpact: amounts.priceImpact,
            fee: fees.totalFee,
            route: route
        )
    }
    
    // MARK: - Private Methods
    
    /// Validates swap parameters
    /// - Parameter swap: Swap to validate
    /// - Throws: SwapError if validation fails
    private func validateSwap(_ swap: UniswapSwap) throws {
        // Validate token addresses
        guard isValidTokenAddress(swap.tokenIn) else {
            throw SwapError.invalidTokenAddress(swap.tokenIn)
        }
        
        guard isValidTokenAddress(swap.tokenOut) else {
            throw SwapError.invalidTokenAddress(swap.tokenOut)
        }
        
        // Validate amount
        guard let amount = Decimal(swap.amountIn), amount > 0 else {
            throw SwapError.invalidAmount(swap.amountIn)
        }
        
        // Validate slippage tolerance
        guard swap.slippageTolerance > 0 && swap.slippageTolerance <= 100 else {
            throw SwapError.invalidSlippageTolerance(swap.slippageTolerance)
        }
        
        // Validate tokens are different
        guard swap.tokenIn != swap.tokenOut else {
            throw SwapError.sameTokenSwap
        }
    }
    
    /// Gets optimal route for swap
    /// - Parameter swap: Swap parameters
    /// - Returns: Optimal route
    private func getOptimalRoute(for swap: UniswapSwap) async throws -> SwapRoute {
        return try await networkManager.getOptimalRoute(
            tokenIn: swap.tokenIn,
            tokenOut: swap.tokenOut,
            amount: swap.amountIn,
            version: currentVersion
        )
    }
    
    /// Calculates swap amounts
    /// - Parameters:
    ///   - swap: Swap parameters
    ///   - route: Swap route
    /// - Returns: Calculated amounts
    private func calculateSwapAmounts(_ swap: UniswapSwap, route: SwapRoute) async throws -> SwapAmounts {
        return try await networkManager.calculateSwapAmounts(
            tokenIn: swap.tokenIn,
            tokenOut: swap.tokenOut,
            amountIn: swap.amountIn,
            route: route,
            slippageTolerance: swap.slippageTolerance
        )
    }
    
    /// Creates swap transaction
    /// - Parameters:
    ///   - swap: Swap parameters
    ///   - route: Swap route
    ///   - amounts: Calculated amounts
    /// - Returns: Transaction for swap
    private func createSwapTransaction(_ swap: UniswapSwap, route: SwapRoute, amounts: SwapAmounts) async throws -> Transaction {
        let swapData = try createSwapData(swap, route: route, amounts: amounts)
        
        return Transaction(
            to: getUniswapRouterAddress(),
            value: "0",
            network: .ethereum,
            data: swapData
        )
    }
    
    /// Creates swap data for transaction
    /// - Parameters:
    ///   - swap: Swap parameters
    ///   - route: Swap route
    ///   - amounts: Calculated amounts
    /// - Returns: Swap transaction data
    private func createSwapData(_ swap: UniswapSwap, route: SwapRoute, amounts: SwapAmounts) throws -> Data {
        var data = Data()
        
        // Add function selector for swap
        data.append(Data(hex: "0x38ed1739")) // swap function selector
        
        // Add parameters
        data.append(Data(hex: swap.tokenIn))
        data.append(Data(hex: swap.tokenOut))
        data.append(amounts.amountIn.serialize())
        data.append(amounts.amountOutMin.serialize())
        data.append(route.path.serialize())
        data.append(Data(hex: swap.recipient))
        data.append(amounts.deadline.serialize())
        
        return data
    }
    
    /// Executes swap transaction
    /// - Parameter transaction: Swap transaction
    /// - Returns: Transaction hash
    private func executeSwap(_ transaction: Transaction) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            transactionManager.sendTransaction(transaction) { result in
                switch result {
                case .success(let txHash):
                    continuation.resume(returning: txHash)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Validates liquidity parameters
    /// - Parameter liquidity: Liquidity parameters to validate
    /// - Throws: LiquidityError if validation fails
    private func validateLiquidityParams(_ liquidity: AddLiquidityParams) throws {
        // Validate token addresses
        guard isValidTokenAddress(liquidity.tokenA) else {
            throw LiquidityError.invalidTokenAddress(liquidity.tokenA)
        }
        
        guard isValidTokenAddress(liquidity.tokenB) else {
            throw LiquidityError.invalidTokenAddress(liquidity.tokenB)
        }
        
        // Validate amounts
        guard let amountA = Decimal(liquidity.amountA), amountA > 0 else {
            throw LiquidityError.invalidAmount(liquidity.amountA)
        }
        
        guard let amountB = Decimal(liquidity.amountB), amountB > 0 else {
            throw LiquidityError.invalidAmount(liquidity.amountB)
        }
        
        // Validate tokens are different
        guard liquidity.tokenA != liquidity.tokenB else {
            throw LiquidityError.sameTokenLiquidity
        }
    }
    
    /// Calculates liquidity amounts
    /// - Parameter liquidity: Liquidity parameters
    /// - Returns: Calculated amounts
    private func calculateLiquidityAmounts(_ liquidity: AddLiquidityParams) async throws -> LiquidityAmounts {
        return try await networkManager.calculateLiquidityAmounts(
            tokenA: liquidity.tokenA,
            tokenB: liquidity.tokenB,
            amountA: liquidity.amountA,
            amountB: liquidity.amountB,
            fee: liquidity.fee
        )
    }
    
    /// Creates add liquidity transaction
    /// - Parameters:
    ///   - liquidity: Liquidity parameters
    ///   - amounts: Calculated amounts
    /// - Returns: Add liquidity transaction
    private func createAddLiquidityTransaction(_ liquidity: AddLiquidityParams, amounts: LiquidityAmounts) async throws -> Transaction {
        let liquidityData = try createAddLiquidityData(liquidity, amounts: amounts)
        
        return Transaction(
            to: getUniswapRouterAddress(),
            value: "0",
            network: .ethereum,
            data: liquidityData
        )
    }
    
    /// Creates add liquidity data
    /// - Parameters:
    ///   - liquidity: Liquidity parameters
    ///   - amounts: Calculated amounts
    /// - Returns: Add liquidity transaction data
    private func createAddLiquidityData(_ liquidity: AddLiquidityParams, amounts: LiquidityAmounts) throws -> Data {
        var data = Data()
        
        // Add function selector for addLiquidity
        data.append(Data(hex: "0xe8e33700")) // addLiquidity function selector
        
        // Add parameters
        data.append(Data(hex: liquidity.tokenA))
        data.append(Data(hex: liquidity.tokenB))
        data.append(amounts.amountA.serialize())
        data.append(amounts.amountB.serialize())
        data.append(amounts.amountAMin.serialize())
        data.append(amounts.amountBMin.serialize())
        data.append(Data(hex: liquidity.recipient))
        data.append(amounts.deadline.serialize())
        
        return data
    }
    
    /// Executes add liquidity transaction
    /// - Parameter transaction: Add liquidity transaction
    /// - Returns: Transaction hash
    private func executeAddLiquidity(_ transaction: Transaction) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            transactionManager.sendTransaction(transaction) { result in
                switch result {
                case .success(let txHash):
                    continuation.resume(returning: txHash)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Validates liquidity removal parameters
    /// - Parameter liquidity: Liquidity removal parameters to validate
    /// - Throws: LiquidityError if validation fails
    private func validateLiquidityRemovalParams(_ liquidity: RemoveLiquidityParams) throws {
        // Validate token addresses
        guard isValidTokenAddress(liquidity.tokenA) else {
            throw LiquidityError.invalidTokenAddress(liquidity.tokenA)
        }
        
        guard isValidTokenAddress(liquidity.tokenB) else {
            throw LiquidityError.invalidTokenAddress(liquidity.tokenB)
        }
        
        // Validate liquidity amount
        guard let liquidityAmount = Decimal(liquidity.liquidity), liquidityAmount > 0 else {
            throw LiquidityError.invalidLiquidityAmount(liquidity.liquidity)
        }
    }
    
    /// Calculates removal amounts
    /// - Parameter liquidity: Liquidity removal parameters
    /// - Returns: Calculated removal amounts
    private func calculateRemovalAmounts(_ liquidity: RemoveLiquidityParams) async throws -> RemovalAmounts {
        return try await networkManager.calculateRemovalAmounts(
            tokenA: liquidity.tokenA,
            tokenB: liquidity.tokenB,
            liquidity: liquidity.liquidity,
            fee: liquidity.fee
        )
    }
    
    /// Creates remove liquidity transaction
    /// - Parameters:
    ///   - liquidity: Liquidity removal parameters
    ///   - amounts: Calculated amounts
    /// - Returns: Remove liquidity transaction
    private func createRemoveLiquidityTransaction(_ liquidity: RemoveLiquidityParams, amounts: RemovalAmounts) async throws -> Transaction {
        let liquidityData = try createRemoveLiquidityData(liquidity, amounts: amounts)
        
        return Transaction(
            to: getUniswapRouterAddress(),
            value: "0",
            network: .ethereum,
            data: liquidityData
        )
    }
    
    /// Creates remove liquidity data
    /// - Parameters:
    ///   - liquidity: Liquidity removal parameters
    ///   - amounts: Calculated amounts
    /// - Returns: Remove liquidity transaction data
    private func createRemoveLiquidityData(_ liquidity: RemoveLiquidityParams, amounts: RemovalAmounts) throws -> Data {
        var data = Data()
        
        // Add function selector for removeLiquidity
        data.append(Data(hex: "0xbaa2abde")) // removeLiquidity function selector
        
        // Add parameters
        data.append(Data(hex: liquidity.tokenA))
        data.append(Data(hex: liquidity.tokenB))
        data.append(amounts.liquidity.serialize())
        data.append(amounts.amountAMin.serialize())
        data.append(amounts.amountBMin.serialize())
        data.append(Data(hex: liquidity.recipient))
        data.append(amounts.deadline.serialize())
        
        return data
    }
    
    /// Executes remove liquidity transaction
    /// - Parameter transaction: Remove liquidity transaction
    /// - Returns: Transaction hash
    private func executeRemoveLiquidity(_ transaction: Transaction) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            transactionManager.sendTransaction(transaction) { result in
                switch result {
                case .success(let txHash):
                    continuation.resume(returning: txHash)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Calculates swap fees
    /// - Parameters:
    ///   - swap: Swap parameters
    ///   - route: Swap route
    /// - Returns: Calculated fees
    private func calculateSwapFees(_ swap: UniswapSwap, route: SwapRoute) async throws -> SwapFees {
        return try await networkManager.calculateSwapFees(
            tokenIn: swap.tokenIn,
            tokenOut: swap.tokenOut,
            amountIn: swap.amountIn,
            route: route
        )
    }
    
    /// Gets Uniswap router address
    /// - Returns: Router address for current version
    private func getUniswapRouterAddress() -> String {
        switch currentVersion {
        case .v3:
            return "0xE592427A0AEce92De3Edee1F18E0157C05861564"
        case .v4:
            return "0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E"
        }
    }
    
    /// Validates token address format
    /// - Parameter address: Address to validate
    /// - Returns: True if valid address
    private func isValidTokenAddress(_ address: String) -> Bool {
        let pattern = "^0x[a-fA-F0-9]{40}$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: address.utf16.count)
        return regex.firstMatch(in: address, range: range) != nil
    }
    
    /// Sets up token support
    private func setupTokenSupport() {
        // Load supported tokens
        supportedTokens = [
            Token(symbol: "ETH", name: "Ethereum", address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"),
            Token(symbol: "USDC", name: "USD Coin", address: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8"),
            Token(symbol: "USDT", name: "Tether USD", address: "0xdAC17F958D2ee523a2206206994597C13D831ec7"),
            Token(symbol: "DAI", name: "Dai Stablecoin", address: "0x6B175474E89094C44Da98b954EedeAC495271d0F")
        ]
    }
}

// MARK: - Supporting Types

/// Uniswap version
public enum UniswapVersion: String, CaseIterable {
    case v3 = "v3"
    case v4 = "v4"
}

/// Token model
public struct Token: Identifiable, Codable {
    public let id = UUID()
    public let symbol: String
    public let name: String
    public let address: String
    public let decimals: Int
    public let logoURI: String?
    
    public init(symbol: String, name: String, address: String, decimals: Int = 18, logoURI: String? = nil) {
        self.symbol = symbol
        self.name = name
        self.address = address
        self.decimals = decimals
        self.logoURI = logoURI
    }
}

/// Uniswap swap parameters
public struct UniswapSwap {
    public let tokenIn: String
    public let tokenOut: String
    public let amountIn: String
    public let slippageTolerance: Double
    public let recipient: String
    public let deadline: BigUInt
    
    public init(tokenIn: String, tokenOut: String, amountIn: String, slippageTolerance: Double = 0.5, recipient: String, deadline: BigUInt) {
        self.tokenIn = tokenIn
        self.tokenOut = tokenOut
        self.amountIn = amountIn
        self.slippageTolerance = slippageTolerance
        self.recipient = recipient
        self.deadline = deadline
    }
}

/// Add liquidity parameters
public struct AddLiquidityParams {
    public let tokenA: String
    public let tokenB: String
    public let amountA: String
    public let amountB: String
    public let fee: Int
    public let recipient: String
    public let deadline: BigUInt
    
    public init(tokenA: String, tokenB: String, amountA: String, amountB: String, fee: Int, recipient: String, deadline: BigUInt) {
        self.tokenA = tokenA
        self.tokenB = tokenB
        self.amountA = amountA
        self.amountB = amountB
        self.fee = fee
        self.recipient = recipient
        self.deadline = deadline
    }
}

/// Remove liquidity parameters
public struct RemoveLiquidityParams {
    public let tokenA: String
    public let tokenB: String
    public let liquidity: String
    public let fee: Int
    public let recipient: String
    public let deadline: BigUInt
    
    public init(tokenA: String, tokenB: String, liquidity: String, fee: Int, recipient: String, deadline: BigUInt) {
        self.tokenA = tokenA
        self.tokenB = tokenB
        self.liquidity = liquidity
        self.fee = fee
        self.recipient = recipient
        self.deadline = deadline
    }
}

/// Liquidity pool model
public struct LiquidityPool: Identifiable, Codable {
    public let id = UUID()
    public let address: String
    public let tokenA: Token
    public let tokenB: Token
    public let fee: Int
    public let liquidity: String
    public let volume24h: String
    
    public init(address: String, tokenA: Token, tokenB: Token, fee: Int, liquidity: String, volume24h: String) {
        self.address = address
        self.tokenA = tokenA
        self.tokenB = tokenB
        self.fee = fee
        self.liquidity = liquidity
        self.volume24h = volume24h
    }
}

/// Swap transaction model
public struct SwapTransaction: Identifiable, Codable {
    public let id = UUID()
    public let from: String
    public let to: String
    public let amountIn: String
    public let amountOut: String
    public let txHash: String
    public let timestamp: Date
    
    public init(from: String, to: String, amountIn: String, amountOut: String, txHash: String) {
        self.from = from
        self.to = to
        self.amountIn = amountIn
        self.amountOut = amountOut
        self.txHash = txHash
        self.timestamp = Date()
    }
}

/// Swap route model
public struct SwapRoute {
    public let path: [String]
    public let pools: [String]
    public let fees: [Int]
    
    public init(path: [String], pools: [String], fees: [Int]) {
        self.path = path
        self.pools = pools
        self.fees = fees
    }
}

/// Swap amounts model
public struct SwapAmounts {
    public let amountIn: BigUInt
    public let amountOut: BigUInt
    public let amountOutMin: BigUInt
    public let priceImpact: Decimal
    public let deadline: BigUInt
    
    public init(amountIn: BigUInt, amountOut: BigUInt, amountOutMin: BigUInt, priceImpact: Decimal, deadline: BigUInt) {
        self.amountIn = amountIn
        self.amountOut = amountOut
        self.amountOutMin = amountOutMin
        self.priceImpact = priceImpact
        self.deadline = deadline
    }
}

/// Swap quote model
public struct SwapQuote {
    public let tokenIn: String
    public let tokenOut: String
    public let amountIn: String
    public let amountOut: String
    public let priceImpact: Decimal
    public let fee: String
    public let route: SwapRoute
    
    public init(tokenIn: String, tokenOut: String, amountIn: String, amountOut: String, priceImpact: Decimal, fee: String, route: SwapRoute) {
        self.tokenIn = tokenIn
        self.tokenOut = tokenOut
        self.amountIn = amountIn
        self.amountOut = amountOut
        self.priceImpact = priceImpact
        self.fee = fee
        self.route = route
    }
}

/// Liquidity amounts model
public struct LiquidityAmounts {
    public let amountA: BigUInt
    public let amountB: BigUInt
    public let amountAMin: BigUInt
    public let amountBMin: BigUInt
    public let deadline: BigUInt
    
    public init(amountA: BigUInt, amountB: BigUInt, amountAMin: BigUInt, amountBMin: BigUInt, deadline: BigUInt) {
        self.amountA = amountA
        self.amountB = amountB
        self.amountAMin = amountAMin
        self.amountBMin = amountBMin
        self.deadline = deadline
    }
}

/// Removal amounts model
public struct RemovalAmounts {
    public let liquidity: BigUInt
    public let amountA: BigUInt
    public let amountB: BigUInt
    public let amountAMin: BigUInt
    public let amountBMin: BigUInt
    public let deadline: BigUInt
    
    public init(liquidity: BigUInt, amountA: BigUInt, amountB: BigUInt, amountAMin: BigUInt, amountBMin: BigUInt, deadline: BigUInt) {
        self.liquidity = liquidity
        self.amountA = amountA
        self.amountB = amountB
        self.amountAMin = amountAMin
        self.amountBMin = amountBMin
        self.deadline = deadline
    }
}

/// Swap fees model
public struct SwapFees {
    public let protocolFee: String
    public let poolFee: String
    public let totalFee: String
    
    public init(protocolFee: String, poolFee: String, totalFee: String) {
        self.protocolFee = protocolFee
        self.poolFee = poolFee
        self.totalFee = totalFee
    }
}

/// Pool information model
public struct PoolInfo {
    public let address: String
    public let tokenA: Token
    public let tokenB: Token
    public let fee: Int
    public let liquidity: String
    public let volume24h: String
    public let tvl: String
    
    public init(address: String, tokenA: Token, tokenB: Token, fee: Int, liquidity: String, volume24h: String, tvl: String) {
        self.address = address
        self.tokenA = tokenA
        self.tokenB = tokenB
        self.fee = fee
        self.liquidity = liquidity
        self.volume24h = volume24h
        self.tvl = tvl
    }
}

/// Swap errors
public enum SwapError: Error, LocalizedError {
    case invalidTokenAddress(String)
    case invalidAmount(String)
    case invalidSlippageTolerance(Double)
    case sameTokenSwap
    case failed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidTokenAddress(let address):
            return "Invalid token address: \(address)"
        case .invalidAmount(let amount):
            return "Invalid amount: \(amount)"
        case .invalidSlippageTolerance(let tolerance):
            return "Invalid slippage tolerance: \(tolerance)%"
        case .sameTokenSwap:
            return "Cannot swap same token"
        case .failed(let error):
            return "Swap failed: \(error.localizedDescription)"
        }
    }
}

/// Liquidity errors
public enum LiquidityError: Error, LocalizedError {
    case invalidTokenAddress(String)
    case invalidAmount(String)
    case invalidLiquidityAmount(String)
    case sameTokenLiquidity
    case failed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidTokenAddress(let address):
            return "Invalid token address: \(address)"
        case .invalidAmount(let amount):
            return "Invalid amount: \(amount)"
        case .invalidLiquidityAmount(let amount):
            return "Invalid liquidity amount: \(amount)"
        case .sameTokenLiquidity:
            return "Cannot add liquidity for same token"
        case .failed(let error):
            return "Liquidity operation failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Extensions

extension Array {
    /// Serializes array to Data
    /// - Returns: Serialized data
    func serialize() -> Data {
        var data = Data()
        for element in self {
            if let string = element as? String {
                data.append(Data(hex: string))
            }
        }
        return data
    }
} 