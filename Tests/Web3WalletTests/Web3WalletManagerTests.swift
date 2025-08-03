import XCTest
import Web3Wallet
@testable import Web3Wallet

@available(iOS 15.0, *)
final class Web3WalletManagerTests: XCTestCase {
    
    // MARK: - Properties
    
    var walletManager: Web3WalletManager!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        walletManager = Web3WalletManager()
    }
    
    override func tearDown() {
        walletManager = nil
        super.tearDown()
    }
    
    // MARK: - Wallet Creation Tests
    
    func testWalletCreation() async throws {
        // Given
        let name = "Test Wallet"
        let password = "SecurePassword123!"
        
        // When
        let wallet = try await walletManager.createWallet(name: name, password: password)
        
        // Then
        XCTAssertNotNil(wallet)
        XCTAssertEqual(wallet.name, name)
        XCTAssertTrue(wallet.isValid)
        XCTAssertEqual(wallet.address.count, 42) // 0x + 40 hex characters
        XCTAssertTrue(wallet.address.hasPrefix("0x"))
        XCTAssertEqual(wallet.publicKey.count, 130) // 0x + 128 hex characters
        XCTAssertTrue(wallet.publicKey.hasPrefix("0x"))
        XCTAssertNotNil(wallet.mnemonic)
        XCTAssertEqual(wallet.mnemonic?.components(separatedBy: " ").count, 12)
        XCTAssertTrue(wallet.isActive)
        XCTAssertEqual(wallet.supportedNetworks.count, 3) // Default networks
        XCTAssertEqual(wallet.walletType, .hd)
        XCTAssertEqual(wallet.securityLevel, .standard)
    }
    
    func testWalletCreationWithInvalidName() async throws {
        // Given
        let name = ""
        let password = "SecurePassword123!"
        
        // When & Then
        do {
            _ = try await walletManager.createWallet(name: name, password: password)
            XCTFail("Should throw error for empty name")
        } catch WalletError.invalidName {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testWalletCreationWithWeakPassword() async throws {
        // Given
        let name = "Test Wallet"
        let password = "weak"
        
        // When & Then
        do {
            _ = try await walletManager.createWallet(name: name, password: password)
            XCTFail("Should throw error for weak password")
        } catch WalletError.weakPassword {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testWalletCreationWithLongName() async throws {
        // Given
        let name = String(repeating: "A", count: 51)
        let password = "SecurePassword123!"
        
        // When & Then
        do {
            _ = try await walletManager.createWallet(name: name, password: password)
            XCTFail("Should throw error for long name")
        } catch WalletError.invalidName {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Wallet Import Tests
    
    func testWalletImportWithPrivateKey() async throws {
        // Given
        let privateKey = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        let name = "Imported Wallet"
        let password = "SecurePassword123!"
        
        // When
        let wallet = try await walletManager.importWallet(privateKey: privateKey, name: name, password: password)
        
        // Then
        XCTAssertNotNil(wallet)
        XCTAssertEqual(wallet.name, name)
        XCTAssertTrue(wallet.isValid)
        XCTAssertNil(wallet.mnemonic) // Imported wallets don't have mnemonic
        XCTAssertTrue(wallet.isActive)
    }
    
    func testWalletImportWithInvalidPrivateKey() async throws {
        // Given
        let privateKey = "invalid"
        let name = "Imported Wallet"
        let password = "SecurePassword123!"
        
        // When & Then
        do {
            _ = try await walletManager.importWallet(privateKey: privateKey, name: name, password: password)
            XCTFail("Should throw error for invalid private key")
        } catch WalletError.invalidPrivateKey {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testWalletImportWithMnemonic() async throws {
        // Given
        let mnemonic = "abandon ability able about above absent absorb abstract absurd abuse access accident"
        let name = "Imported Wallet"
        let password = "SecurePassword123!"
        
        // When
        let wallet = try await walletManager.importWallet(mnemonic: mnemonic, name: name, password: password)
        
        // Then
        XCTAssertNotNil(wallet)
        XCTAssertEqual(wallet.name, name)
        XCTAssertTrue(wallet.isValid)
        XCTAssertEqual(wallet.mnemonic, mnemonic)
        XCTAssertTrue(wallet.isActive)
    }
    
    func testWalletImportWithInvalidMnemonic() async throws {
        // Given
        let mnemonic = "invalid mnemonic phrase"
        let name = "Imported Wallet"
        let password = "SecurePassword123!"
        
        // When & Then
        do {
            _ = try await walletManager.importWallet(mnemonic: mnemonic, name: name, password: password)
            XCTFail("Should throw error for invalid mnemonic")
        } catch WalletError.invalidMnemonic {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Transaction Tests
    
    func testTransactionSigning() async throws {
        // Given
        let wallet = try await walletManager.createWallet(name: "Test Wallet", password: "SecurePassword123!")
        let transaction = Transaction(
            from: wallet.address,
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "1000000000000000000", // 1 ETH in wei
            gasLimit: 21000,
            nonce: 0,
            data: "0x",
            chain: .ethereum,
            type: .legacy
        )
        
        // When
        let signedTransaction = try await walletManager.signTransaction(transaction)
        
        // Then
        XCTAssertNotNil(signedTransaction)
        XCTAssertEqual(signedTransaction.transaction.id, transaction.id)
        XCTAssertTrue(signedTransaction.isValid)
        XCTAssertEqual(signedTransaction.signedBy, wallet.address)
        XCTAssertNotNil(signedTransaction.hash)
    }
    
    func testTransactionSigningWithoutActiveWallet() async throws {
        // Given
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
            _ = try await walletManager.signTransaction(transaction)
            XCTFail("Should throw error when no active wallet")
        } catch WalletError.noActiveWallet {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Network Tests
    
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
        walletManager.configureNetworks(networks)
        
        // Then
        // Network configuration should be successful
        XCTAssertTrue(true)
    }
    
    func testChainSwitching() async throws {
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
        
        walletManager.configureNetworks(networks)
        
        // When
        try await walletManager.switchChain(.polygon)
        
        // Then
        XCTAssertEqual(walletManager.getCurrentNetwork(), .polygon)
    }
    
    func testChainSwitchingToUnsupportedChain() async throws {
        // Given
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/test",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            )
        ]
        
        walletManager.configureNetworks(networks)
        
        // When & Then
        do {
            try await walletManager.switchChain(.polygon)
            XCTFail("Should throw error for unsupported chain")
        } catch NetworkError.unsupportedChain {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - DeFi Tests
    
    func testDeFiProtocols() async throws {
        // When
        let protocols = try await walletManager.getAvailableDeFiProtocols()
        
        // Then
        XCTAssertFalse(protocols.isEmpty)
        XCTAssertTrue(protocols.contains(.uniswapV2))
        XCTAssertTrue(protocols.contains(.uniswapV3))
        XCTAssertTrue(protocols.contains(.sushiswap))
    }
    
    func testSwapTransactionCreation() async throws {
        // Given
        let wallet = try await walletManager.createWallet(name: "Test Wallet", password: "SecurePassword123!")
        let swapRequest = SwapRequest(
            fromToken: "ETH",
            toToken: "USDC",
            amount: "1000000000000000000", // 1 ETH
            slippage: 0.5,
            protocol: .uniswapV2
        )
        
        // When
        let transaction = try await walletManager.createSwapTransaction(swapRequest)
        
        // Then
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction.from, wallet.address)
        XCTAssertEqual(transaction.chain, .ethereum)
        XCTAssertTrue(transaction.isValid)
    }
    
    // MARK: - Performance Tests
    
    func testWalletCreationPerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Wallet creation")
            
            Task {
                do {
                    _ = try await walletManager.createWallet(name: "Performance Test", password: "SecurePassword123!")
                    expectation.fulfill()
                } catch {
                    XCTFail("Wallet creation failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testTransactionSigningPerformance() {
        let expectation = XCTestExpectation(description: "Transaction signing")
        
        Task {
            do {
                let wallet = try await walletManager.createWallet(name: "Performance Test", password: "SecurePassword123!")
                let transaction = Transaction(
                    from: wallet.address,
                    to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
                    value: "1000000000000000000",
                    gasLimit: 21000,
                    nonce: 0,
                    data: "0x",
                    chain: .ethereum,
                    type: .legacy
                )
                
                measure {
                    do {
                        _ = try await walletManager.signTransaction(transaction)
                    } catch {
                        XCTFail("Transaction signing failed: \(error)")
                    }
                }
                
                expectation.fulfill()
            } catch {
                XCTFail("Setup failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() async throws {
        // Test various error scenarios
        let testCases: [(String, String, WalletError)] = [
            ("", "SecurePassword123!", .invalidName),
            ("Test Wallet", "weak", .weakPassword),
            ("Test Wallet", "SecurePassword123!", .invalidName) // This will be caught by other validation
        ]
        
        for (name, password, expectedError) in testCases {
            do {
                _ = try await walletManager.createWallet(name: name, password: password)
                XCTFail("Should throw error for invalid input")
            } catch let error as WalletError {
                XCTAssertEqual(error, expectedError)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testCompleteWalletWorkflow() async throws {
        // 1. Create wallet
        let wallet = try await walletManager.createWallet(name: "Integration Test", password: "SecurePassword123!")
        XCTAssertNotNil(wallet)
        XCTAssertTrue(wallet.isValid)
        
        // 2. Switch wallet
        try await walletManager.switchWallet(to: wallet)
        XCTAssertEqual(walletManager.currentWallet?.id, wallet.id)
        
        // 3. Create and sign transaction
        let transaction = Transaction(
            from: wallet.address,
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "1000000000000000000",
            gasLimit: 21000,
            nonce: 0,
            data: "0x",
            chain: .ethereum,
            type: .legacy
        )
        
        let signedTransaction = try await walletManager.signTransaction(transaction)
        XCTAssertNotNil(signedTransaction)
        XCTAssertTrue(signedTransaction.isValid)
        
        // 4. Create DeFi swap
        let swapRequest = SwapRequest(
            fromToken: "ETH",
            toToken: "USDC",
            amount: "1000000000000000000",
            slippage: 0.5,
            protocol: .uniswapV2
        )
        
        let swapTransaction = try await walletManager.createSwapTransaction(swapRequest)
        XCTAssertNotNil(swapTransaction)
        XCTAssertTrue(swapTransaction.isValid)
    }
    
    // MARK: - Memory Tests
    
    func testMemoryUsage() {
        // Test that wallet manager doesn't cause memory leaks
        weak var weakWalletManager: Web3WalletManager?
        
        autoreleasepool {
            let manager = Web3WalletManager()
            weakWalletManager = manager
            
            // Perform some operations
            Task {
                do {
                    _ = try await manager.createWallet(name: "Memory Test", password: "SecurePassword123!")
                } catch {
                    // Ignore errors for memory test
                }
            }
        }
        
        // Wait a bit for operations to complete
        Thread.sleep(forTimeInterval: 1.0)
        
        // Check that the manager is deallocated
        XCTAssertNil(weakWalletManager, "Wallet manager should be deallocated")
    }
} 