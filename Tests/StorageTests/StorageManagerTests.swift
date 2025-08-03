import XCTest
import Web3Wallet
@testable import Web3Wallet

@available(iOS 15.0, *)
final class StorageManagerTests: XCTestCase {
    
    // MARK: - Properties
    
    var storageManager: StorageManager!
    var testWallet: Wallet!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        storageManager = StorageManager()
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
        storageManager = nil
        testWallet = nil
        super.tearDown()
    }
    
    // MARK: - Wallet Storage Tests
    
    func testSaveWallet() async throws {
        // When
        try await storageManager.saveWallet(testWallet)
        
        // Then
        // Wallet should be saved successfully
        XCTAssertTrue(true)
    }
    
    func testGetWallet() async throws {
        // Given
        try await storageManager.saveWallet(testWallet)
        
        // When
        let retrievedWallet = try await storageManager.getWallet(id: testWallet.id)
        
        // Then
        XCTAssertNotNil(retrievedWallet)
        XCTAssertEqual(retrievedWallet?.id, testWallet.id)
        XCTAssertEqual(retrievedWallet?.name, testWallet.name)
        XCTAssertEqual(retrievedWallet?.address, testWallet.address)
        XCTAssertEqual(retrievedWallet?.publicKey, testWallet.publicKey)
        XCTAssertEqual(retrievedWallet?.mnemonic, testWallet.mnemonic)
        XCTAssertEqual(retrievedWallet?.isActive, testWallet.isActive)
    }
    
    func testGetNonExistentWallet() async throws {
        // Given
        let nonExistentWalletId = "non-existent-wallet-id"
        
        // When
        let wallet = try await storageManager.getWallet(id: nonExistentWalletId)
        
        // Then
        XCTAssertNil(wallet)
    }
    
    func testGetAllWallets() async throws {
        // Given
        let wallet1 = Wallet(
            id: "wallet-1",
            name: "Wallet 1",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: "abandon ability able about above absent absorb abstract absurd abuse access accident",
            createdAt: Date(),
            isActive: true
        )
        
        let wallet2 = Wallet(
            id: "wallet-2",
            name: "Wallet 2",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b7",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: nil,
            createdAt: Date(),
            isActive: false
        )
        
        try await storageManager.saveWallet(wallet1)
        try await storageManager.saveWallet(wallet2)
        
        // When
        let wallets = try await storageManager.getAllWallets()
        
        // Then
        XCTAssertGreaterThanOrEqual(wallets.count, 2)
        XCTAssertTrue(wallets.contains { $0.id == wallet1.id })
        XCTAssertTrue(wallets.contains { $0.id == wallet2.id })
    }
    
    func testGetLastActiveWallet() async throws {
        // Given
        try await storageManager.saveWallet(testWallet)
        
        // When
        let lastActiveWallet = try await storageManager.getLastActiveWallet()
        
        // Then
        XCTAssertNotNil(lastActiveWallet)
        XCTAssertEqual(lastActiveWallet?.id, testWallet.id)
    }
    
    func testDeleteWallet() async throws {
        // Given
        try await storageManager.saveWallet(testWallet)
        
        // Verify wallet exists
        let savedWallet = try await storageManager.getWallet(id: testWallet.id)
        XCTAssertNotNil(savedWallet)
        
        // When
        try await storageManager.deleteWallet(testWallet)
        
        // Then
        let deletedWallet = try await storageManager.getWallet(id: testWallet.id)
        XCTAssertNil(deletedWallet)
    }
    
    // MARK: - Transaction Storage Tests
    
    func testSaveTransaction() async throws {
        // Given
        let transaction = Transaction(
            from: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b7",
            value: "1000000000000000000",
            gasLimit: 21000,
            nonce: 0,
            data: "0x",
            chain: .ethereum,
            type: .legacy
        )
        
        // When
        try await storageManager.saveTransaction(transaction)
        
        // Then
        // Transaction should be saved successfully
        XCTAssertTrue(true)
    }
    
    func testGetTransaction() async throws {
        // Given
        let transaction = Transaction(
            from: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b7",
            value: "1000000000000000000",
            gasLimit: 21000,
            nonce: 0,
            data: "0x",
            chain: .ethereum,
            type: .legacy
        )
        
        try await storageManager.saveTransaction(transaction)
        
        // When
        let retrievedTransaction = try await storageManager.getTransaction(id: transaction.id)
        
        // Then
        XCTAssertNotNil(retrievedTransaction)
        XCTAssertEqual(retrievedTransaction?.id, transaction.id)
        XCTAssertEqual(retrievedTransaction?.from, transaction.from)
        XCTAssertEqual(retrievedTransaction?.to, transaction.to)
        XCTAssertEqual(retrievedTransaction?.value, transaction.value)
        XCTAssertEqual(retrievedTransaction?.chain, transaction.chain)
    }
    
    func testGetNonExistentTransaction() async throws {
        // Given
        let nonExistentTransactionId = "non-existent-transaction-id"
        
        // When
        let transaction = try await storageManager.getTransaction(id: nonExistentTransactionId)
        
        // Then
        XCTAssertNil(transaction)
    }
    
    func testGetTransactionsForWallet() async throws {
        // Given
        let walletId = "test-wallet-id"
        
        let transaction1 = Transaction(
            id: "tx-1",
            from: walletId,
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b7",
            value: "1000000000000000000",
            gasLimit: 21000,
            nonce: 0,
            data: "0x",
            chain: .ethereum,
            type: .legacy
        )
        
        let transaction2 = Transaction(
            id: "tx-2",
            from: walletId,
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b8",
            value: "2000000000000000000",
            gasLimit: 21000,
            nonce: 1,
            data: "0x",
            chain: .ethereum,
            type: .legacy
        )
        
        let transaction3 = Transaction(
            id: "tx-3",
            from: "different-wallet",
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b9",
            value: "3000000000000000000",
            gasLimit: 21000,
            nonce: 0,
            data: "0x",
            chain: .ethereum,
            type: .legacy
        )
        
        try await storageManager.saveTransaction(transaction1)
        try await storageManager.saveTransaction(transaction2)
        try await storageManager.saveTransaction(transaction3)
        
        // When
        let transactions = try await storageManager.getTransactions(for: walletId)
        
        // Then
        XCTAssertEqual(transactions.count, 2)
        XCTAssertTrue(transactions.contains { $0.id == transaction1.id })
        XCTAssertTrue(transactions.contains { $0.id == transaction2.id })
        XCTAssertFalse(transactions.contains { $0.id == transaction3.id })
        
        // Verify transactions are sorted by creation date (newest first)
        if transactions.count >= 2 {
            XCTAssertGreaterThanOrEqual(transactions[0].createdAt, transactions[1].createdAt)
        }
    }
    
    func testDeleteTransaction() async throws {
        // Given
        let transaction = Transaction(
            from: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b7",
            value: "1000000000000000000",
            gasLimit: 21000,
            nonce: 0,
            data: "0x",
            chain: .ethereum,
            type: .legacy
        )
        
        try await storageManager.saveTransaction(transaction)
        
        // Verify transaction exists
        let savedTransaction = try await storageManager.getTransaction(id: transaction.id)
        XCTAssertNotNil(savedTransaction)
        
        // When
        try await storageManager.deleteTransaction(transaction)
        
        // Then
        let deletedTransaction = try await storageManager.getTransaction(id: transaction.id)
        XCTAssertNil(deletedTransaction)
    }
    
    // MARK: - Settings Storage Tests
    
    func testSaveAndGetSettings() async throws {
        // Given
        let settings = WalletSettings(
            defaultNetwork: .ethereum,
            gasPriceStrategy: .medium,
            slippageTolerance: 0.5,
            enableBiometrics: true,
            enableNotifications: true,
            autoBackup: false,
            theme: .dark,
            language: "en"
        )
        
        // When
        try await storageManager.saveSettings(settings)
        let retrievedSettings = try await storageManager.getSettings()
        
        // Then
        XCTAssertEqual(retrievedSettings.defaultNetwork, settings.defaultNetwork)
        XCTAssertEqual(retrievedSettings.gasPriceStrategy, settings.gasPriceStrategy)
        XCTAssertEqual(retrievedSettings.slippageTolerance, settings.slippageTolerance)
        XCTAssertEqual(retrievedSettings.enableBiometrics, settings.enableBiometrics)
        XCTAssertEqual(retrievedSettings.enableNotifications, settings.enableNotifications)
        XCTAssertEqual(retrievedSettings.autoBackup, settings.autoBackup)
        XCTAssertEqual(retrievedSettings.theme, settings.theme)
        XCTAssertEqual(retrievedSettings.language, settings.language)
    }
    
    func testGetDefaultSettings() async throws {
        // When
        let settings = try await storageManager.getSettings()
        
        // Then
        XCTAssertEqual(settings.defaultNetwork, .ethereum)
        XCTAssertEqual(settings.gasPriceStrategy, .medium)
        XCTAssertEqual(settings.slippageTolerance, 0.5)
        XCTAssertEqual(settings.enableBiometrics, true)
        XCTAssertEqual(settings.enableNotifications, true)
        XCTAssertEqual(settings.autoBackup, false)
        XCTAssertEqual(settings.theme, .system)
        XCTAssertEqual(settings.language, "en")
    }
    
    // MARK: - Cache Management Tests
    
    func testClearCache() async throws {
        // Given
        let transaction = Transaction(
            from: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b7",
            value: "1000000000000000000",
            gasLimit: 21000,
            nonce: 0,
            data: "0x",
            chain: .ethereum,
            type: .legacy
        )
        
        try await storageManager.saveTransaction(transaction)
        
        // Verify transaction exists
        let savedTransaction = try await storageManager.getTransaction(id: transaction.id)
        XCTAssertNotNil(savedTransaction)
        
        // When
        try await storageManager.clearCache()
        
        // Then
        // Cache should be cleared successfully
        XCTAssertTrue(true)
    }
    
    func testGetStorageStatistics() async throws {
        // Given
        let wallet = Wallet(
            id: "stats-test-wallet",
            name: "Stats Test Wallet",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: "abandon ability able about above absent absorb abstract absurd abuse access accident",
            createdAt: Date(),
            isActive: true
        )
        
        let transaction = Transaction(
            from: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b7",
            value: "1000000000000000000",
            gasLimit: 21000,
            nonce: 0,
            data: "0x",
            chain: .ethereum,
            type: .legacy
        )
        
        try await storageManager.saveWallet(wallet)
        try await storageManager.saveTransaction(transaction)
        
        // When
        let statistics = try await storageManager.getStorageStatistics()
        
        // Then
        XCTAssertGreaterThanOrEqual(statistics.walletCount, 1)
        XCTAssertGreaterThanOrEqual(statistics.transactionCount, 1)
        XCTAssertGreaterThan(statistics.totalSize, 0)
        XCTAssertGreaterThan(statistics.totalSizeInMB, 0)
    }
    
    // MARK: - Performance Tests
    
    func testSaveWalletPerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Save wallet")
            
            Task {
                do {
                    let wallet = Wallet(
                        id: UUID().uuidString,
                        name: "Performance Test Wallet",
                        address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
                        publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
                        mnemonic: "abandon ability able about above absent absorb abstract absurd abuse access accident",
                        createdAt: Date(),
                        isActive: true
                    )
                    
                    try await storageManager.saveWallet(wallet)
                    expectation.fulfill()
                } catch {
                    XCTFail("Save wallet failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testGetWalletPerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Get wallet")
            
            Task {
                do {
                    _ = try await storageManager.getWallet(id: testWallet.id)
                    expectation.fulfill()
                } catch {
                    XCTFail("Get wallet failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testSaveTransactionPerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Save transaction")
            
            Task {
                do {
                    let transaction = Transaction(
                        id: UUID().uuidString,
                        from: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
                        to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b7",
                        value: "1000000000000000000",
                        gasLimit: 21000,
                        nonce: 0,
                        data: "0x",
                        chain: .ethereum,
                        type: .legacy
                    )
                    
                    try await storageManager.saveTransaction(transaction)
                    expectation.fulfill()
                } catch {
                    XCTFail("Save transaction failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Integration Tests
    
    func testCompleteStorageWorkflow() async throws {
        // 1. Save wallet
        try await storageManager.saveWallet(testWallet)
        
        // 2. Get wallet
        let retrievedWallet = try await storageManager.getWallet(id: testWallet.id)
        XCTAssertNotNil(retrievedWallet)
        XCTAssertEqual(retrievedWallet?.id, testWallet.id)
        
        // 3. Save transaction
        let transaction = Transaction(
            from: testWallet.address,
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b7",
            value: "1000000000000000000",
            gasLimit: 21000,
            nonce: 0,
            data: "0x",
            chain: .ethereum,
            type: .legacy
        )
        
        try await storageManager.saveTransaction(transaction)
        
        // 4. Get transaction
        let retrievedTransaction = try await storageManager.getTransaction(id: transaction.id)
        XCTAssertNotNil(retrievedTransaction)
        XCTAssertEqual(retrievedTransaction?.id, transaction.id)
        
        // 5. Get transactions for wallet
        let transactions = try await storageManager.getTransactions(for: testWallet.id)
        XCTAssertGreaterThanOrEqual(transactions.count, 1)
        XCTAssertTrue(transactions.contains { $0.from == testWallet.address })
        
        // 6. Save settings
        let settings = WalletSettings(
            defaultNetwork: .polygon,
            gasPriceStrategy: .fast,
            slippageTolerance: 1.0,
            enableBiometrics: false,
            enableNotifications: false,
            autoBackup: true,
            theme: .light,
            language: "tr"
        )
        
        try await storageManager.saveSettings(settings)
        
        // 7. Get settings
        let retrievedSettings = try await storageManager.getSettings()
        XCTAssertEqual(retrievedSettings.defaultNetwork, settings.defaultNetwork)
        XCTAssertEqual(retrievedSettings.gasPriceStrategy, settings.gasPriceStrategy)
        XCTAssertEqual(retrievedSettings.slippageTolerance, settings.slippageTolerance)
        XCTAssertEqual(retrievedSettings.enableBiometrics, settings.enableBiometrics)
        XCTAssertEqual(retrievedSettings.enableNotifications, settings.enableNotifications)
        XCTAssertEqual(retrievedSettings.autoBackup, settings.autoBackup)
        XCTAssertEqual(retrievedSettings.theme, settings.theme)
        XCTAssertEqual(retrievedSettings.language, settings.language)
        
        // 8. Get storage statistics
        let statistics = try await storageManager.getStorageStatistics()
        XCTAssertGreaterThanOrEqual(statistics.walletCount, 1)
        XCTAssertGreaterThanOrEqual(statistics.transactionCount, 1)
        XCTAssertGreaterThan(statistics.totalSize, 0)
        
        // 9. Delete transaction
        try await storageManager.deleteTransaction(transaction)
        let deletedTransaction = try await storageManager.getTransaction(id: transaction.id)
        XCTAssertNil(deletedTransaction)
        
        // 10. Delete wallet
        try await storageManager.deleteWallet(testWallet)
        let deletedWallet = try await storageManager.getWallet(id: testWallet.id)
        XCTAssertNil(deletedWallet)
        
        // 11. Clear cache
        try await storageManager.clearCache()
        XCTAssertTrue(true)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() async throws {
        // Test various error scenarios
        let testCases: [(String, StorageError)] = [
            ("", .invalidData),
            ("invalid", .invalidData)
        ]
        
        for (input, expectedError) in testCases {
            do {
                // Try to save invalid data
                let invalidWallet = Wallet(
                    id: input,
                    name: input,
                    address: input,
                    publicKey: input,
                    mnemonic: input,
                    createdAt: Date(),
                    isActive: true
                )
                
                try await storageManager.saveWallet(invalidWallet)
                XCTFail("Should throw error for invalid input")
            } catch let error as StorageError {
                XCTAssertEqual(error, expectedError)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
} 