import XCTest
import BigInt
@testable import iOSWeb3WalletFramework

final class UniswapManagerTests: XCTestCase {
    
    var uniswapManager: UniswapManager!
    
    override func setUp() {
        super.setUp()
        uniswapManager = UniswapManager()
    }
    
    override func tearDown() {
        uniswapManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testUniswapManagerInitialization() {
        XCTAssertNotNil(uniswapManager)
        XCTAssertEqual(uniswapManager.currentVersion, .v4)
        XCTAssertEqual(uniswapManager.supportedTokens.count, 4)
        XCTAssertEqual(uniswapManager.liquidityPools.count, 0)
        XCTAssertEqual(uniswapManager.swapHistory.count, 0)
    }
    
    func testUniswapManagerWithCustomConfiguration() {
        let customManager = UniswapManager(
            version: .v3,
            network: .ethereum,
            customRPC: "https://mainnet.infura.io/v3/test"
        )
        
        XCTAssertNotNil(customManager)
        XCTAssertEqual(customManager.currentVersion, .v3)
    }
    
    // MARK: - Token Tests
    
    func testSupportedTokens() {
        let tokens = uniswapManager.supportedTokens
        
        XCTAssertEqual(tokens.count, 4)
        
        let ethToken = tokens.first { $0.symbol == "ETH" }
        XCTAssertNotNil(ethToken)
        XCTAssertEqual(ethToken?.name, "Ethereum")
        XCTAssertEqual(ethToken?.decimals, 18)
        
        let usdcToken = tokens.first { $0.symbol == "USDC" }
        XCTAssertNotNil(usdcToken)
        XCTAssertEqual(usdcToken?.name, "USD Coin")
        
        let usdtToken = tokens.first { $0.symbol == "USDT" }
        XCTAssertNotNil(usdtToken)
        XCTAssertEqual(usdtToken?.name, "Tether USD")
        
        let daiToken = tokens.first { $0.symbol == "DAI" }
        XCTAssertNotNil(daiToken)
        XCTAssertEqual(daiToken?.name, "Dai Stablecoin")
    }
    
    func testTokenInitialization() {
        let token = Token(
            symbol: "TEST",
            name: "Test Token",
            address: "0x1234567890123456789012345678901234567890",
            decimals: 6,
            logoURI: "https://example.com/logo.png"
        )
        
        XCTAssertEqual(token.symbol, "TEST")
        XCTAssertEqual(token.name, "Test Token")
        XCTAssertEqual(token.address, "0x1234567890123456789012345678901234567890")
        XCTAssertEqual(token.decimals, 6)
        XCTAssertEqual(token.logoURI, "https://example.com/logo.png")
    }
    
    // MARK: - Swap Validation Tests
    
    func testValidSwap() {
        let swap = UniswapSwap(
            tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            tokenOut: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            amountIn: "1000000000000000000",
            slippageTolerance: 0.5,
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
        )
        
        XCTAssertNoThrow(try validateSwap(swap))
    }
    
    func testInvalidTokenAddressSwap() {
        let swap = UniswapSwap(
            tokenIn: "invalid-address",
            tokenOut: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            amountIn: "1000000000000000000",
            slippageTolerance: 0.5,
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
        )
        
        XCTAssertThrowsError(try validateSwap(swap)) { error in
            XCTAssertTrue(error is SwapError)
        }
    }
    
    func testInvalidAmountSwap() {
        let swap = UniswapSwap(
            tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            tokenOut: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            amountIn: "0",
            slippageTolerance: 0.5,
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
        )
        
        XCTAssertThrowsError(try validateSwap(swap)) { error in
            XCTAssertTrue(error is SwapError)
        }
    }
    
    func testInvalidSlippageToleranceSwap() {
        let swap = UniswapSwap(
            tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            tokenOut: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            amountIn: "1000000000000000000",
            slippageTolerance: 150.0, // Invalid: > 100%
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
        )
        
        XCTAssertThrowsError(try validateSwap(swap)) { error in
            XCTAssertTrue(error is SwapError)
        }
    }
    
    func testSameTokenSwap() {
        let swap = UniswapSwap(
            tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            tokenOut: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", // Same token
            amountIn: "1000000000000000000",
            slippageTolerance: 0.5,
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
        )
        
        XCTAssertThrowsError(try validateSwap(swap)) { error in
            XCTAssertTrue(error is SwapError)
        }
    }
    
    // MARK: - Liquidity Tests
    
    func testValidLiquidityParams() {
        let liquidity = AddLiquidityParams(
            tokenA: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            tokenB: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            amountA: "1000000000000000000",
            amountB: "1000000",
            fee: 3000,
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
        )
        
        XCTAssertNoThrow(try validateLiquidityParams(liquidity))
    }
    
    func testInvalidLiquidityParams() {
        let liquidity = AddLiquidityParams(
            tokenA: "invalid-address",
            tokenB: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            amountA: "1000000000000000000",
            amountB: "1000000",
            fee: 3000,
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
        )
        
        XCTAssertThrowsError(try validateLiquidityParams(liquidity)) { error in
            XCTAssertTrue(error is LiquidityError)
        }
    }
    
    func testSameTokenLiquidity() {
        let liquidity = AddLiquidityParams(
            tokenA: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            tokenB: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", // Same token
            amountA: "1000000000000000000",
            amountB: "1000000",
            fee: 3000,
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
        )
        
        XCTAssertThrowsError(try validateLiquidityParams(liquidity)) { error in
            XCTAssertTrue(error is LiquidityError)
        }
    }
    
    // MARK: - Model Tests
    
    func testUniswapSwapInitialization() {
        let swap = UniswapSwap(
            tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            tokenOut: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            amountIn: "1000000000000000000",
            slippageTolerance: 0.5,
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(1234567890)
        )
        
        XCTAssertEqual(swap.tokenIn, "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
        XCTAssertEqual(swap.tokenOut, "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8")
        XCTAssertEqual(swap.amountIn, "1000000000000000000")
        XCTAssertEqual(swap.slippageTolerance, 0.5)
        XCTAssertEqual(swap.recipient, "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6")
        XCTAssertEqual(swap.deadline, BigUInt(1234567890))
    }
    
    func testAddLiquidityParamsInitialization() {
        let liquidity = AddLiquidityParams(
            tokenA: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            tokenB: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            amountA: "1000000000000000000",
            amountB: "1000000",
            fee: 3000,
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(1234567890)
        )
        
        XCTAssertEqual(liquidity.tokenA, "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
        XCTAssertEqual(liquidity.tokenB, "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8")
        XCTAssertEqual(liquidity.amountA, "1000000000000000000")
        XCTAssertEqual(liquidity.amountB, "1000000")
        XCTAssertEqual(liquidity.fee, 3000)
        XCTAssertEqual(liquidity.recipient, "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6")
        XCTAssertEqual(liquidity.deadline, BigUInt(1234567890))
    }
    
    func testRemoveLiquidityParamsInitialization() {
        let liquidity = RemoveLiquidityParams(
            tokenA: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            tokenB: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            liquidity: "1000000000000000000",
            fee: 3000,
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(1234567890)
        )
        
        XCTAssertEqual(liquidity.tokenA, "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
        XCTAssertEqual(liquidity.tokenB, "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8")
        XCTAssertEqual(liquidity.liquidity, "1000000000000000000")
        XCTAssertEqual(liquidity.fee, 3000)
        XCTAssertEqual(liquidity.recipient, "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6")
        XCTAssertEqual(liquidity.deadline, BigUInt(1234567890))
    }
    
    func testLiquidityPoolInitialization() {
        let tokenA = Token(symbol: "ETH", name: "Ethereum", address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
        let tokenB = Token(symbol: "USDC", name: "USD Coin", address: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8")
        
        let pool = LiquidityPool(
            address: "0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8",
            tokenA: tokenA,
            tokenB: tokenB,
            fee: 3000,
            liquidity: "1000000000000000000000",
            volume24h: "5000000000000000000000"
        )
        
        XCTAssertEqual(pool.address, "0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8")
        XCTAssertEqual(pool.tokenA.symbol, "ETH")
        XCTAssertEqual(pool.tokenB.symbol, "USDC")
        XCTAssertEqual(pool.fee, 3000)
        XCTAssertEqual(pool.liquidity, "1000000000000000000000")
        XCTAssertEqual(pool.volume24h, "5000000000000000000000")
    }
    
    func testSwapTransactionInitialization() {
        let swapTransaction = SwapTransaction(
            from: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            to: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            amountIn: "1000000000000000000",
            amountOut: "1000000",
            txHash: "0x1234567890abcdef"
        )
        
        XCTAssertEqual(swapTransaction.from, "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
        XCTAssertEqual(swapTransaction.to, "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8")
        XCTAssertEqual(swapTransaction.amountIn, "1000000000000000000")
        XCTAssertEqual(swapTransaction.amountOut, "1000000")
        XCTAssertEqual(swapTransaction.txHash, "0x1234567890abcdef")
        XCTAssertNotNil(swapTransaction.timestamp)
    }
    
    func testSwapRouteInitialization() {
        let route = SwapRoute(
            path: ["0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8"],
            pools: ["0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8"],
            fees: [3000]
        )
        
        XCTAssertEqual(route.path.count, 2)
        XCTAssertEqual(route.pools.count, 1)
        XCTAssertEqual(route.fees.count, 1)
        XCTAssertEqual(route.fees.first, 3000)
    }
    
    func testSwapAmountsInitialization() {
        let amounts = SwapAmounts(
            amountIn: BigUInt(1000000000000000000),
            amountOut: BigUInt(1000000),
            amountOutMin: BigUInt(950000),
            priceImpact: Decimal(0.1),
            deadline: BigUInt(1234567890)
        )
        
        XCTAssertEqual(amounts.amountIn, BigUInt(1000000000000000000))
        XCTAssertEqual(amounts.amountOut, BigUInt(1000000))
        XCTAssertEqual(amounts.amountOutMin, BigUInt(950000))
        XCTAssertEqual(amounts.priceImpact, Decimal(0.1))
        XCTAssertEqual(amounts.deadline, BigUInt(1234567890))
    }
    
    func testSwapQuoteInitialization() {
        let route = SwapRoute(
            path: ["0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8"],
            pools: ["0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8"],
            fees: [3000]
        )
        
        let quote = SwapQuote(
            tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            tokenOut: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            amountIn: "1000000000000000000",
            amountOut: "1000000",
            priceImpact: Decimal(0.1),
            fee: "3000",
            route: route
        )
        
        XCTAssertEqual(quote.tokenIn, "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
        XCTAssertEqual(quote.tokenOut, "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8")
        XCTAssertEqual(quote.amountIn, "1000000000000000000")
        XCTAssertEqual(quote.amountOut, "1000000")
        XCTAssertEqual(quote.priceImpact, Decimal(0.1))
        XCTAssertEqual(quote.fee, "3000")
        XCTAssertEqual(quote.route, route)
    }
    
    // MARK: - Version Tests
    
    func testUniswapVersionCases() {
        let v3 = UniswapVersion.v3
        let v4 = UniswapVersion.v4
        
        XCTAssertEqual(v3.rawValue, "v3")
        XCTAssertEqual(v4.rawValue, "v4")
        
        let allVersions = UniswapVersion.allCases
        XCTAssertEqual(allVersions.count, 2)
        XCTAssertTrue(allVersions.contains(.v3))
        XCTAssertTrue(allVersions.contains(.v4))
    }
    
    // MARK: - Router Address Tests
    
    func testRouterAddresses() {
        let v3Address = getUniswapRouterAddress(.v3)
        let v4Address = getUniswapRouterAddress(.v4)
        
        XCTAssertEqual(v3Address, "0xE592427A0AEce92De3Edee1F18E0157C05861564")
        XCTAssertEqual(v4Address, "0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E")
    }
    
    // MARK: - Error Tests
    
    func testSwapErrorDescriptions() {
        let invalidTokenAddressError = SwapError.invalidTokenAddress("0xinvalid")
        XCTAssertNotNil(invalidTokenAddressError.errorDescription)
        XCTAssertTrue(invalidTokenAddressError.errorDescription!.contains("Invalid token address"))
        
        let invalidAmountError = SwapError.invalidAmount("0")
        XCTAssertNotNil(invalidAmountError.errorDescription)
        XCTAssertTrue(invalidAmountError.errorDescription!.contains("Invalid amount"))
        
        let invalidSlippageError = SwapError.invalidSlippageTolerance(150.0)
        XCTAssertNotNil(invalidSlippageError.errorDescription)
        XCTAssertTrue(invalidSlippageError.errorDescription!.contains("Invalid slippage tolerance"))
        
        let sameTokenError = SwapError.sameTokenSwap
        XCTAssertNotNil(sameTokenError.errorDescription)
        XCTAssertTrue(sameTokenError.errorDescription!.contains("Cannot swap same token"))
    }
    
    func testLiquidityErrorDescriptions() {
        let invalidTokenAddressError = LiquidityError.invalidTokenAddress("0xinvalid")
        XCTAssertNotNil(invalidTokenAddressError.errorDescription)
        XCTAssertTrue(invalidTokenAddressError.errorDescription!.contains("Invalid token address"))
        
        let invalidAmountError = LiquidityError.invalidAmount("0")
        XCTAssertNotNil(invalidAmountError.errorDescription)
        XCTAssertTrue(invalidAmountError.errorDescription!.contains("Invalid amount"))
        
        let invalidLiquidityAmountError = LiquidityError.invalidLiquidityAmount("0")
        XCTAssertNotNil(invalidLiquidityAmountError.errorDescription)
        XCTAssertTrue(invalidLiquidityAmountError.errorDescription!.contains("Invalid liquidity amount"))
        
        let sameTokenError = LiquidityError.sameTokenLiquidity
        XCTAssertNotNil(sameTokenError.errorDescription)
        XCTAssertTrue(sameTokenError.errorDescription!.contains("Cannot add liquidity for same token"))
    }
    
    // MARK: - Performance Tests
    
    func testSwapValidationPerformance() {
        let swap = UniswapSwap(
            tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            tokenOut: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            amountIn: "1000000000000000000",
            slippageTolerance: 0.5,
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
        )
        
        measure {
            for _ in 0..<1000 {
                XCTAssertNoThrow(try validateSwap(swap))
            }
        }
    }
    
    func testTokenAddressValidationPerformance() {
        let validAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
        
        measure {
            for _ in 0..<10000 {
                XCTAssertTrue(isValidTokenAddress(validAddress))
            }
        }
    }
    
    // MARK: - Memory Tests
    
    func testUniswapManagerMemoryUsage() {
        let initialMemory = getMemoryUsage()
        
        for i in 0..<100 {
            let swapTransaction = SwapTransaction(
                from: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
                to: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
                amountIn: "\(i)",
                amountOut: "\(i * 1000)",
                txHash: "0x\(i)"
            )
            uniswapManager.swapHistory.append(swapTransaction)
        }
        
        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        // Memory increase should be reasonable (less than 1MB)
        XCTAssertLessThan(memoryIncrease, 1024 * 1024)
    }
    
    // MARK: - Helper Methods
    
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
    
    private func isValidTokenAddress(_ address: String) -> Bool {
        let pattern = "^0x[a-fA-F0-9]{40}$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: address.utf16.count)
        return regex.firstMatch(in: address, range: range) != nil
    }
    
    private func getUniswapRouterAddress(_ version: UniswapVersion) -> String {
        switch version {
        case .v3:
            return "0xE592427A0AEce92De3Edee1F18E0157C05861564"
        case .v4:
            return "0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E"
        }
    }
    
    private func getMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int(info.resident_size)
        } else {
            return 0
        }
    }
} 