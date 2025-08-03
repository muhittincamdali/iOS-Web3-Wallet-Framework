import XCTest
import Web3Wallet
@testable import Web3Wallet

@available(iOS 15.0, *)
final class DeFiManagerTests: XCTestCase {
    
    // MARK: - Properties
    
    var defiManager: DeFiManager!
    var testWallet: Wallet!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        defiManager = DeFiManager()
        testWallet = Wallet(
            id: "test-wallet-id",
            name: "Test Wallet",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: "abandon ability able about above absent absorb abstract absurd abuse access accident",
            createdAt: Date(),
            isActive: true
        )
    }
    
    override func tearDown() {
        defiManager = nil
        testWallet = nil
        super.tearDown()
    }
    
    // MARK: - Protocol Management Tests
    
    func testGetAvailableProtocols() async throws {
        // When
        let protocols = try await defiManager.getAvailableProtocols()
        
        // Then
        XCTAssertFalse(protocols.isEmpty)
        XCTAssertTrue(protocols.contains(.uniswapV2))
        XCTAssertTrue(protocols.contains(.uniswapV3))
        XCTAssertTrue(protocols.contains(.sushiswap))
        XCTAssertTrue(protocols.contains(.aave))
        XCTAssertTrue(protocols.contains(.compound))
        XCTAssertTrue(protocols.contains(.yearn))
        XCTAssertTrue(protocols.contains(.curve))
    }
    
    func testGetProtocolConfig() throws {
        // Given
        let protocol: DeFiProtocol = .uniswapV2
        
        // When
        let config = try defiManager.getProtocolConfig(protocol)
        
        // Then
        XCTAssertEqual(config.name, "Uniswap V2")
        XCTAssertNotNil(config.routerAddress)
        XCTAssertNotNil(config.factoryAddress)
        XCTAssertNil(config.lendingPoolAddress)
        XCTAssertNil(config.stakingAddress)
    }
    
    func testGetUnsupportedProtocolConfig() {
        // Given
        let unsupportedProtocol = DeFiProtocol.uniswapV2 // This should be supported, but we'll test error handling
        
        // When & Then
        do {
            _ = try defiManager.getProtocolConfig(unsupportedProtocol)
            // Should not throw for supported protocol
        } catch DeFiError.unsupportedProtocol {
            XCTFail("UniswapV2 should be supported")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Token Operations Tests
    
    func testGetTokenInfo() async throws {
        // Given
        let tokenAddress = "0xA0b86a33E6441b8c4C8C1C1B8C4C8C1C1B8C4C8C"
        
        // When
        let tokenInfo = try await defiManager.getTokenInfo(tokenAddress)
        
        // Then
        XCTAssertEqual(tokenInfo.address, tokenAddress)
        XCTAssertFalse(tokenInfo.name.isEmpty)
        XCTAssertFalse(tokenInfo.symbol.isEmpty)
        XCTAssertGreaterThan(tokenInfo.decimals, 0)
        XCTAssertLessThanOrEqual(tokenInfo.decimals, 18)
    }
    
    func testGetTokenPrice() async throws {
        // Given
        let tokenAddress = "0xA0b86a33E6441b8c4C8C1C1B8C4C8C1C1B8C4C8C"
        
        // When
        let price = try await defiManager.getTokenPrice(tokenAddress)
        
        // Then
        XCTAssertFalse(price.isEmpty)
        XCTAssertNotEqual(price, "0")
    }
    
    // MARK: - Swap Operations Tests
    
    func testCreateSwapTransaction() async throws {
        // Given
        let swapRequest = SwapRequest(
            fromToken: "ETH",
            toToken: "USDC",
            amount: "1000000000000000000", // 1 ETH
            slippage: 0.5,
            protocol: .uniswapV2
        )
        
        // When
        let transaction = try await defiManager.createSwapTransaction(swapRequest, for: testWallet)
        
        // Then
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction.from, testWallet.address)
        XCTAssertEqual(transaction.chain, .ethereum)
        XCTAssertTrue(transaction.isValid)
        XCTAssertNotEqual(transaction.to, "0x0000000000000000000000000000000000000000")
    }
    
    func testCreateSwapTransactionWithInvalidRequest() async throws {
        // Given
        let invalidSwapRequest = SwapRequest(
            fromToken: "",
            toToken: "",
            amount: "",
            slippage: 0,
            protocol: .uniswapV2
        )
        
        // When & Then
        do {
            _ = try await defiManager.createSwapTransaction(invalidSwapRequest, for: testWallet)
            XCTFail("Should throw error for invalid swap request")
        } catch DeFiError.invalidSwapRequest {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetSwapQuote() async throws {
        // Given
        let swapRequest = SwapRequest(
            fromToken: "ETH",
            toToken: "USDC",
            amount: "1000000000000000000", // 1 ETH
            slippage: 0.5,
            protocol: .uniswapV2
        )
        
        // When
        let quote = try await defiManager.getSwapQuote(swapRequest)
        
        // Then
        XCTAssertEqual(quote.fromToken, swapRequest.fromToken)
        XCTAssertEqual(quote.toToken, swapRequest.toToken)
        XCTAssertEqual(quote.fromAmount, swapRequest.amount)
        XCTAssertFalse(quote.toAmount.isEmpty)
        XCTAssertGreaterThanOrEqual(quote.priceImpact, 0)
        XCTAssertGreaterThan(quote.gasEstimate, 0)
        XCTAssertEqual(quote.protocol, swapRequest.protocol)
        XCTAssertFalse(quote.route.isEmpty)
    }
    
    func testGetSwapQuoteWithInvalidRequest() async throws {
        // Given
        let invalidSwapRequest = SwapRequest(
            fromToken: "",
            toToken: "",
            amount: "",
            slippage: 0,
            protocol: .uniswapV2
        )
        
        // When & Then
        do {
            _ = try await defiManager.getSwapQuote(invalidSwapRequest)
            XCTFail("Should throw error for invalid swap request")
        } catch DeFiError.invalidSwapRequest {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Liquidity Operations Tests
    
    func testCreateAddLiquidityTransaction() async throws {
        // Given
        let liquidityRequest = LiquidityRequest(
            tokenA: "ETH",
            tokenB: "USDC",
            amountA: "1000000000000000000", // 1 ETH
            amountB: "2000000000", // 2000 USDC
            protocol: .uniswapV2
        )
        
        // When
        let transaction = try await defiManager.createAddLiquidityTransaction(liquidityRequest, for: testWallet)
        
        // Then
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction.from, testWallet.address)
        XCTAssertEqual(transaction.chain, .ethereum)
        XCTAssertTrue(transaction.isValid)
        XCTAssertNotEqual(transaction.to, "0x0000000000000000000000000000000000000000")
    }
    
    func testCreateAddLiquidityTransactionWithInvalidRequest() async throws {
        // Given
        let invalidLiquidityRequest = LiquidityRequest(
            tokenA: "",
            tokenB: "",
            amountA: "",
            amountB: "",
            protocol: .uniswapV2
        )
        
        // When & Then
        do {
            _ = try await defiManager.createAddLiquidityTransaction(invalidLiquidityRequest, for: testWallet)
            XCTFail("Should throw error for invalid liquidity request")
        } catch DeFiError.invalidLiquidityRequest {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCreateRemoveLiquidityTransaction() async throws {
        // Given
        let liquidityRequest = LiquidityRequest(
            tokenA: "ETH",
            tokenB: "USDC",
            amountA: "1000000000000000000", // 1 ETH
            amountB: "2000000000", // 2000 USDC
            protocol: .uniswapV2
        )
        
        // When
        let transaction = try await defiManager.createRemoveLiquidityTransaction(liquidityRequest, for: testWallet)
        
        // Then
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction.from, testWallet.address)
        XCTAssertEqual(transaction.chain, .ethereum)
        XCTAssertTrue(transaction.isValid)
        XCTAssertNotEqual(transaction.to, "0x0000000000000000000000000000000000000000")
    }
    
    func testCreateRemoveLiquidityTransactionWithInvalidRequest() async throws {
        // Given
        let invalidLiquidityRequest = LiquidityRequest(
            tokenA: "",
            tokenB: "",
            amountA: "",
            amountB: "",
            protocol: .uniswapV2
        )
        
        // When & Then
        do {
            _ = try await defiManager.createRemoveLiquidityTransaction(invalidLiquidityRequest, for: testWallet)
            XCTFail("Should throw error for invalid liquidity request")
        } catch DeFiError.invalidLiquidityRequest {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Lending Operations Tests
    
    func testCreateDepositTransaction() async throws {
        // Given
        let depositRequest = DepositRequest(
            token: "USDC",
            amount: "1000000000", // 1000 USDC
            protocol: .aave
        )
        
        // When
        let transaction = try await defiManager.createDepositTransaction(depositRequest, for: testWallet)
        
        // Then
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction.from, testWallet.address)
        XCTAssertEqual(transaction.chain, .ethereum)
        XCTAssertTrue(transaction.isValid)
        XCTAssertNotEqual(transaction.to, "0x0000000000000000000000000000000000000000")
    }
    
    func testCreateDepositTransactionWithInvalidRequest() async throws {
        // Given
        let invalidDepositRequest = DepositRequest(
            token: "",
            amount: "",
            protocol: .aave
        )
        
        // When & Then
        do {
            _ = try await defiManager.createDepositTransaction(invalidDepositRequest, for: testWallet)
            XCTFail("Should throw error for invalid deposit request")
        } catch DeFiError.invalidDepositRequest {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCreateWithdrawTransaction() async throws {
        // Given
        let withdrawRequest = WithdrawRequest(
            token: "USDC",
            amount: "1000000000", // 1000 USDC
            protocol: .aave
        )
        
        // When
        let transaction = try await defiManager.createWithdrawTransaction(withdrawRequest, for: testWallet)
        
        // Then
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction.from, testWallet.address)
        XCTAssertEqual(transaction.chain, .ethereum)
        XCTAssertTrue(transaction.isValid)
        XCTAssertNotEqual(transaction.to, "0x0000000000000000000000000000000000000000")
    }
    
    func testCreateWithdrawTransactionWithInvalidRequest() async throws {
        // Given
        let invalidWithdrawRequest = WithdrawRequest(
            token: "",
            amount: "",
            protocol: .aave
        )
        
        // When & Then
        do {
            _ = try await defiManager.createWithdrawTransaction(invalidWithdrawRequest, for: testWallet)
            XCTFail("Should throw error for invalid withdraw request")
        } catch DeFiError.invalidWithdrawRequest {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Yield Farming Tests
    
    func testCreateStakeTransaction() async throws {
        // Given
        let stakeRequest = StakeRequest(
            token: "USDC",
            amount: "1000000000", // 1000 USDC
            protocol: .yearn
        )
        
        // When
        let transaction = try await defiManager.createStakeTransaction(stakeRequest, for: testWallet)
        
        // Then
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction.from, testWallet.address)
        XCTAssertEqual(transaction.chain, .ethereum)
        XCTAssertTrue(transaction.isValid)
        XCTAssertNotEqual(transaction.to, "0x0000000000000000000000000000000000000000")
    }
    
    func testCreateStakeTransactionWithInvalidRequest() async throws {
        // Given
        let invalidStakeRequest = StakeRequest(
            token: "",
            amount: "",
            protocol: .yearn
        )
        
        // When & Then
        do {
            _ = try await defiManager.createStakeTransaction(invalidStakeRequest, for: testWallet)
            XCTFail("Should throw error for invalid stake request")
        } catch DeFiError.invalidStakeRequest {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCreateUnstakeTransaction() async throws {
        // Given
        let unstakeRequest = UnstakeRequest(
            token: "USDC",
            amount: "1000000000", // 1000 USDC
            protocol: .yearn
        )
        
        // When
        let transaction = try await defiManager.createUnstakeTransaction(unstakeRequest, for: testWallet)
        
        // Then
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction.from, testWallet.address)
        XCTAssertEqual(transaction.chain, .ethereum)
        XCTAssertTrue(transaction.isValid)
        XCTAssertNotEqual(transaction.to, "0x0000000000000000000000000000000000000000")
    }
    
    func testCreateUnstakeTransactionWithInvalidRequest() async throws {
        // Given
        let invalidUnstakeRequest = UnstakeRequest(
            token: "",
            amount: "",
            protocol: .yearn
        )
        
        // When & Then
        do {
            _ = try await defiManager.createUnstakeTransaction(invalidUnstakeRequest, for: testWallet)
            XCTFail("Should throw error for invalid unstake request")
        } catch DeFiError.invalidUnstakeRequest {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Performance Tests
    
    func testSwapTransactionCreationPerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Swap transaction creation")
            
            Task {
                do {
                    let swapRequest = SwapRequest(
                        fromToken: "ETH",
                        toToken: "USDC",
                        amount: "1000000000000000000",
                        slippage: 0.5,
                        protocol: .uniswapV2
                    )
                    
                    _ = try await defiManager.createSwapTransaction(swapRequest, for: testWallet)
                    expectation.fulfill()
                } catch {
                    XCTFail("Swap transaction creation failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testGetSwapQuotePerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Get swap quote")
            
            Task {
                do {
                    let swapRequest = SwapRequest(
                        fromToken: "ETH",
                        toToken: "USDC",
                        amount: "1000000000000000000",
                        slippage: 0.5,
                        protocol: .uniswapV2
                    )
                    
                    _ = try await defiManager.getSwapQuote(swapRequest)
                    expectation.fulfill()
                } catch {
                    XCTFail("Get swap quote failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Integration Tests
    
    func testCompleteDeFiWorkflow() async throws {
        // 1. Get available protocols
        let protocols = try await defiManager.getAvailableProtocols()
        XCTAssertFalse(protocols.isEmpty)
        
        // 2. Get protocol configuration
        let config = try defiManager.getProtocolConfig(.uniswapV2)
        XCTAssertNotNil(config.routerAddress)
        
        // 3. Get token info
        let tokenInfo = try await defiManager.getTokenInfo("0xA0b86a33E6441b8c4C8C1C1B8C4C8C1C1B8C4C8C")
        XCTAssertNotNil(tokenInfo)
        
        // 4. Get token price
        let price = try await defiManager.getTokenPrice("0xA0b86a33E6441b8c4C8C1C1B8C4C8C1C1B8C4C8C")
        XCTAssertFalse(price.isEmpty)
        
        // 5. Create swap transaction
        let swapRequest = SwapRequest(
            fromToken: "ETH",
            toToken: "USDC",
            amount: "1000000000000000000",
            slippage: 0.5,
            protocol: .uniswapV2
        )
        
        let swapTransaction = try await defiManager.createSwapTransaction(swapRequest, for: testWallet)
        XCTAssertNotNil(swapTransaction)
        
        // 6. Get swap quote
        let quote = try await defiManager.getSwapQuote(swapRequest)
        XCTAssertNotNil(quote)
        
        // 7. Create liquidity transaction
        let liquidityRequest = LiquidityRequest(
            tokenA: "ETH",
            tokenB: "USDC",
            amountA: "1000000000000000000",
            amountB: "2000000000",
            protocol: .uniswapV2
        )
        
        let liquidityTransaction = try await defiManager.createAddLiquidityTransaction(liquidityRequest, for: testWallet)
        XCTAssertNotNil(liquidityTransaction)
        
        // 8. Create deposit transaction
        let depositRequest = DepositRequest(
            token: "USDC",
            amount: "1000000000",
            protocol: .aave
        )
        
        let depositTransaction = try await defiManager.createDepositTransaction(depositRequest, for: testWallet)
        XCTAssertNotNil(depositTransaction)
        
        // 9. Create stake transaction
        let stakeRequest = StakeRequest(
            token: "USDC",
            amount: "1000000000",
            protocol: .yearn
        )
        
        let stakeTransaction = try await defiManager.createStakeTransaction(stakeRequest, for: testWallet)
        XCTAssertNotNil(stakeTransaction)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() async throws {
        // Test various error scenarios
        let testCases: [(String, String, String, DeFiProtocol, DeFiError)] = [
            ("", "USDC", "1000000000", .uniswapV2, .invalidSwapRequest),
            ("ETH", "", "1000000000000000000", .uniswapV2, .invalidSwapRequest),
            ("ETH", "USDC", "", .uniswapV2, .invalidSwapRequest)
        ]
        
        for (fromToken, toToken, amount, protocol, expectedError) in testCases {
            do {
                let swapRequest = SwapRequest(
                    fromToken: fromToken,
                    toToken: toToken,
                    amount: amount,
                    slippage: 0.5,
                    protocol: protocol
                )
                
                _ = try await defiManager.createSwapTransaction(swapRequest, for: testWallet)
                XCTFail("Should throw error for invalid input")
            } catch let error as DeFiError {
                XCTAssertEqual(error, expectedError)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
} 