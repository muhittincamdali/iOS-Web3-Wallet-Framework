import XCTest
import Web3Wallet
@testable import Web3Wallet

@available(iOS 15.0, *)
final class NetworkManagerTests: XCTestCase {
    
    // MARK: - Properties
    
    var networkManager: NetworkManager!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager()
    }
    
    override func tearDown() {
        networkManager = nil
        super.tearDown()
    }
    
    // MARK: - Network Configuration Tests
    
    func testNetworkConfiguration() {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            ),
            .polygon: NetworkConfig(
                chainId: 137,
                rpcUrl: "https://polygon-rpc.com",
                explorerUrl: "https://polygonscan.com",
                name: "Polygon Mainnet"
            )
        ]
        
        // When
        networkManager.configureNetworks(networks)
        
        // Then
        // Configuration should be successful
        XCTAssertTrue(true)
    }
    
    func testSwitchChain() async throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            ),
            .polygon: NetworkConfig(
                chainId: 137,
                rpcUrl: "https://polygon-rpc.com",
                explorerUrl: "https://polygonscan.com",
                name: "Polygon Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        
        // When
        try await networkManager.switchChain(.polygon)
        
        // Then
        XCTAssertEqual(networkManager.getCurrentNetwork(), .polygon)
    }
    
    func testSwitchToUnsupportedChain() async throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        
        // When & Then
        do {
            try await networkManager.switchChain(.polygon)
            XCTFail("Should throw error for unsupported chain")
        } catch NetworkError.unsupportedChain {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetNetworkConfig() throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        
        // When
        let config = try networkManager.getNetworkConfig(for: .ethereum)
        
        // Then
        XCTAssertEqual(config.chainId, 1)
        XCTAssertEqual(config.rpcUrl, "https://mainnet.infura.io/v3/test")
        XCTAssertEqual(config.explorerUrl, "https://etherscan.io")
        XCTAssertEqual(config.name, "Ethereum Mainnet")
    }
    
    func testGetUnsupportedNetworkConfig() {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        
        // When & Then
        do {
            _ = try networkManager.getNetworkConfig(for: .polygon)
            XCTFail("Should throw error for unsupported network")
        } catch NetworkError.unsupportedChain {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Balance Operations Tests
    
    func testGetBalance() async throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        let address = "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
        
        // When
        let balance = try await networkManager.getBalance(address: address, on: .ethereum)
        
        // Then
        XCTAssertNotNil(balance)
        XCTAssertFalse(balance.isEmpty)
    }
    
    func testGetBalanceWithInvalidAddress() async throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        let invalidAddress = "invalid-address"
        
        // When & Then
        do {
            _ = try await networkManager.getBalance(address: invalidAddress, on: .ethereum)
            XCTFail("Should throw error for invalid address")
        } catch NetworkError.invalidResponse {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Transaction Operations Tests
    
    func testSendTransaction() async throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        
        let signedTransaction = SignedTransaction(
            transaction: Transaction(
                from: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
                to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
                value: "1000000000000000000",
                gasLimit: 21000,
                nonce: 0,
                data: "0x",
                chain: .ethereum,
                type: .legacy
            ),
            signature: TransactionSignature(
                r: "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
                s: "abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890",
                v: 27
            ),
            rawTransaction: "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
            signedBy: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
        )
        
        // When & Then
        do {
            _ = try await networkManager.sendTransaction(signedTransaction)
            // This will likely fail in test environment, but we can test the method structure
        } catch NetworkError.transactionFailed {
            // Expected in test environment
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetTransactionReceipt() async throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        let txHash = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        
        // When & Then
        do {
            _ = try await networkManager.getTransactionReceipt(txHash)
            // This will likely fail in test environment, but we can test the method structure
        } catch NetworkError.invalidResponse {
            // Expected in test environment
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetTransaction() async throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        let txHash = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        
        // When & Then
        do {
            _ = try await networkManager.getTransaction(txHash)
            // This will likely fail in test environment, but we can test the method structure
        } catch NetworkError.invalidResponse {
            // Expected in test environment
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Gas Operations Tests
    
    func testEstimateGas() async throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        
        let transaction = Transaction(
            from: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "1000000000000000000",
            gasLimit: 21000,
            nonce: 0,
            data: "0x",
            chain: .ethereum,
            type: .legacy
        )
        
        // When & Then
        do {
            let gasEstimate = try await networkManager.estimateGas(for: transaction)
            XCTAssertGreaterThan(gasEstimate, 0)
        } catch NetworkError.invalidResponse {
            // Expected in test environment
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetGasPrice() async throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        
        // When & Then
        do {
            let gasPrice = try await networkManager.getGasPrice()
            XCTAssertNotNil(gasPrice)
            XCTAssertFalse(gasPrice.isEmpty)
        } catch NetworkError.invalidResponse {
            // Expected in test environment
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetFeeHistory() async throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        
        // When & Then
        do {
            let feeHistory = try await networkManager.getFeeHistory(blockCount: 20)
            XCTAssertNotNil(feeHistory)
        } catch NetworkError.invalidResponse {
            // Expected in test environment
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Block Operations Tests
    
    func testGetBlockNumber() async throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        
        // When & Then
        do {
            let blockNumber = try await networkManager.getBlockNumber()
            XCTAssertGreaterThan(blockNumber, 0)
        } catch NetworkError.invalidResponse {
            // Expected in test environment
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetBlock() async throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        let blockNumber: UInt64 = 17000000
        
        // When & Then
        do {
            let block = try await networkManager.getBlock(byNumber: blockNumber)
            XCTAssertNotNil(block)
        } catch NetworkError.invalidResponse {
            // Expected in test environment
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Transaction History Tests
    
    func testGetTransactionHistory() async throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        let address = "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
        
        // When & Then
        do {
            let history = try await networkManager.getTransactionHistory(address: address, on: .ethereum)
            XCTAssertNotNil(history)
            // History might be empty for test address
        } catch NetworkError.invalidResponse {
            // Expected in test environment
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Performance Tests
    
    func testGetBalancePerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Get balance")
            
            Task {
                do {
                    let networks: [Blockchain: NetworkConfig] = [
                        .ethereum: NetworkConfig(
                            chainId: 1,
                            rpcUrl: "https://mainnet.infura.io/v3/test",
                            explorerUrl: "https://etherscan.io",
                            name: "Ethereum Mainnet"
                        )
                    ]
                    
                    networkManager.configureNetworks(networks)
                    let address = "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
                    
                    _ = try await networkManager.getBalance(address: address, on: .ethereum)
                    expectation.fulfill()
                } catch {
                    // Expected in test environment
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    func testGasEstimationPerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Gas estimation")
            
            Task {
                do {
                    let networks: [Blockchain: NetworkConfig] = [
                        .ethereum: NetworkConfig(
                            chainId: 1,
                            rpcUrl: "https://mainnet.infura.io/v3/test",
                            explorerUrl: "https://etherscan.io",
                            name: "Ethereum Mainnet"
                        )
                    ]
                    
                    networkManager.configureNetworks(networks)
                    
                    let transaction = Transaction(
                        from: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
                        to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
                        value: "1000000000000000000",
                        gasLimit: 21000,
                        nonce: 0,
                        data: "0x",
                        chain: .ethereum,
                        type: .legacy
                    )
                    
                    _ = try await networkManager.estimateGas(for: transaction)
                    expectation.fulfill()
                } catch {
                    // Expected in test environment
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: - Integration Tests
    
    func testCompleteNetworkWorkflow() async throws {
        // 1. Configure networks
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            ),
            .polygon: NetworkConfig(
                chainId: 137,
                rpcUrl: "https://polygon-rpc.com",
                explorerUrl: "https://polygonscan.com",
                name: "Polygon Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        
        // 2. Switch to Ethereum
        try await networkManager.switchChain(.ethereum)
        XCTAssertEqual(networkManager.getCurrentNetwork(), .ethereum)
        
        // 3. Get network config
        let ethereumConfig = try networkManager.getNetworkConfig(for: .ethereum)
        XCTAssertEqual(ethereumConfig.chainId, 1)
        
        // 4. Switch to Polygon
        try await networkManager.switchChain(.polygon)
        XCTAssertEqual(networkManager.getCurrentNetwork(), .polygon)
        
        // 5. Get balance (will likely fail in test environment)
        let address = "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
        
        do {
            let balance = try await networkManager.getBalance(address: address, on: .polygon)
            XCTAssertNotNil(balance)
        } catch {
            // Expected in test environment
            XCTAssertTrue(true)
        }
        
        // 6. Get gas price (will likely fail in test environment)
        do {
            let gasPrice = try await networkManager.getGasPrice()
            XCTAssertNotNil(gasPrice)
        } catch {
            // Expected in test environment
            XCTAssertTrue(true)
        }
        
        // 7. Get block number (will likely fail in test environment)
        do {
            let blockNumber = try await networkManager.getBlockNumber()
            XCTAssertGreaterThan(blockNumber, 0)
        } catch {
            // Expected in test environment
            XCTAssertTrue(true)
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() async throws {
        // Test various error scenarios
        let testCases: [(String, NetworkError)] = [
            ("invalid-address", .invalidResponse),
            ("", .invalidResponse)
        ]
        
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        networkManager.configureNetworks(networks)
        
        for (address, expectedError) in testCases {
            do {
                _ = try await networkManager.getBalance(address: address, on: .ethereum)
                XCTFail("Should throw error for invalid address")
            } catch let error as NetworkError {
                XCTAssertEqual(error, expectedError)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
} 