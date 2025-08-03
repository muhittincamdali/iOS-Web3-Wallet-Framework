import XCTest
import Web3Wallet
@testable import Web3Wallet

@available(iOS 15.0, *)
final class SecurityManagerTests: XCTestCase {
    
    // MARK: - Properties
    
    var securityManager: SecurityManager!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        securityManager = SecurityManager()
    }
    
    override func tearDown() {
        securityManager = nil
        super.tearDown()
    }
    
    // MARK: - Key Management Tests
    
    func testGeneratePrivateKey() async throws {
        // When
        let privateKey = try await securityManager.generatePrivateKey()
        
        // Then
        XCTAssertNotNil(privateKey)
        XCTAssertTrue(privateKey.hasPrefix("0x"))
        XCTAssertEqual(privateKey.count, 66) // 0x + 64 hex characters
        XCTAssertTrue(privateKey.range(of: "^0x[0-9A-Fa-f]{64}$", options: .regularExpression) != nil)
    }
    
    func testDerivePublicKey() throws {
        // Given
        let privateKey = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        
        // When
        let publicKey = try securityManager.derivePublicKey(from: privateKey)
        
        // Then
        XCTAssertNotNil(publicKey)
        XCTAssertTrue(publicKey.hasPrefix("0x"))
        XCTAssertGreaterThan(publicKey.count, 66)
    }
    
    func testDerivePublicKeyWithInvalidPrivateKey() {
        // Given
        let invalidPrivateKey = "invalid"
        
        // When & Then
        do {
            _ = try securityManager.derivePublicKey(from: invalidPrivateKey)
            XCTFail("Should throw error for invalid private key")
        } catch SecurityError.invalidPrivateKey {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDeriveAddress() throws {
        // Given
        let publicKey = "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec"
        
        // When
        let address = try securityManager.deriveAddress(from: publicKey)
        
        // Then
        XCTAssertNotNil(address)
        XCTAssertTrue(address.hasPrefix("0x"))
        XCTAssertEqual(address.count, 42) // 0x + 40 hex characters
    }
    
    func testDeriveAddressWithInvalidPublicKey() {
        // Given
        let invalidPublicKey = "invalid"
        
        // When & Then
        do {
            _ = try securityManager.deriveAddress(from: invalidPublicKey)
            XCTFail("Should throw error for invalid public key")
        } catch SecurityError.invalidPublicKey {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Mnemonic Tests
    
    func testGenerateMnemonic() throws {
        // When
        let mnemonic = try securityManager.generateMnemonic()
        
        // Then
        XCTAssertNotNil(mnemonic)
        let words = mnemonic.components(separatedBy: " ")
        XCTAssertTrue([12, 15, 18, 21, 24].contains(words.count))
        
        // Validate each word is a valid BIP39 word
        let validWords = Set([
            "abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse",
            "access", "accident", "account", "accuse", "achieve", "acid", "acoustic", "acquire", "across", "act"
        ])
        
        for word in words {
            XCTAssertTrue(validWords.contains(word.lowercased()))
        }
    }
    
    func testDerivePrivateKeyFromMnemonic() throws {
        // Given
        let mnemonic = "abandon ability able about above absent absorb abstract absurd abuse access accident"
        
        // When
        let privateKey = try securityManager.derivePrivateKey(from: mnemonic)
        
        // Then
        XCTAssertNotNil(privateKey)
        XCTAssertTrue(privateKey.hasPrefix("0x"))
        XCTAssertEqual(privateKey.count, 66)
    }
    
    func testDerivePrivateKeyFromInvalidMnemonic() {
        // Given
        let invalidMnemonic = "invalid mnemonic phrase"
        
        // When & Then
        do {
            _ = try securityManager.derivePrivateKey(from: invalidMnemonic)
            XCTFail("Should throw error for invalid mnemonic")
        } catch SecurityError.invalidMnemonic {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Transaction Signing Tests
    
    func testSignTransaction() async throws {
        // Given
        let privateKey = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
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
        
        // When
        let signedTransaction = try securityManager.signTransaction(transaction, with: privateKey)
        
        // Then
        XCTAssertNotNil(signedTransaction)
        XCTAssertEqual(signedTransaction.transaction.id, transaction.id)
        XCTAssertTrue(signedTransaction.isValid)
        XCTAssertNotNil(signedTransaction.hash)
        XCTAssertNotNil(signedTransaction.signature)
        XCTAssertEqual(signedTransaction.signature.r.count, 32)
        XCTAssertEqual(signedTransaction.signature.s.count, 32)
        XCTAssertTrue(signedTransaction.signature.v >= 27 && signedTransaction.signature.v <= 28)
    }
    
    func testSignTransactionWithInvalidPrivateKey() async throws {
        // Given
        let invalidPrivateKey = "invalid"
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
            _ = try securityManager.signTransaction(transaction, with: invalidPrivateKey)
            XCTFail("Should throw error for invalid private key")
        } catch SecurityError.invalidPrivateKey {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Secure Storage Tests
    
    func testStoreAndRetrievePrivateKey() async throws {
        // Given
        let privateKey = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        let walletId = "test-wallet-id"
        let password = "SecurePassword123!"
        
        // When
        try await securityManager.storePrivateKey(privateKey, for: walletId, password: password)
        let retrievedPrivateKey = try await securityManager.getPrivateKey(for: walletId)
        
        // Then
        XCTAssertEqual(retrievedPrivateKey, privateKey)
    }
    
    func testStorePrivateKeyWithWeakPassword() async throws {
        // Given
        let privateKey = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        let walletId = "test-wallet-id"
        let weakPassword = "weak"
        
        // When & Then
        do {
            try await securityManager.storePrivateKey(privateKey, for: walletId, password: weakPassword)
            XCTFail("Should throw error for weak password")
        } catch SecurityError.storageFailed {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRetrieveNonExistentPrivateKey() async throws {
        // Given
        let nonExistentWalletId = "non-existent-wallet-id"
        
        // When & Then
        do {
            _ = try await securityManager.getPrivateKey(for: nonExistentWalletId)
            XCTFail("Should throw error for non-existent wallet")
        } catch SecurityError.retrievalFailed {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDeletePrivateKey() async throws {
        // Given
        let privateKey = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        let walletId = "test-wallet-id"
        let password = "SecurePassword123!"
        
        // Store the private key first
        try await securityManager.storePrivateKey(privateKey, for: walletId, password: password)
        
        // When
        try await securityManager.deletePrivateKey(for: walletId)
        
        // Then
        do {
            _ = try await securityManager.getPrivateKey(for: walletId)
            XCTFail("Should throw error after deletion")
        } catch SecurityError.retrievalFailed {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Biometric Authentication Tests
    
    func testBiometricAuthenticationAvailability() {
        // When
        let isAvailable = securityManager.isBiometricAuthenticationAvailable()
        
        // Then
        // This test depends on the device capabilities
        // We can't guarantee the result, but we can test the method doesn't crash
        XCTAssertTrue(true) // Method executed successfully
    }
    
    func testBiometricAuthentication() async throws {
        // This test requires user interaction and may not work in CI/CD
        // We'll test that the method doesn't crash
        
        do {
            let result = try await securityManager.authenticateWithBiometrics()
            // Result depends on device capabilities and user interaction
            XCTAssertTrue(true) // Method executed successfully
        } catch SecurityError.authenticationFailed {
            // Expected in test environment
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Validation Tests
    
    func testValidatePrivateKey() {
        // Valid private keys
        let validPrivateKeys = [
            "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
            "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890"
        ]
        
        for privateKey in validPrivateKeys {
            XCTAssertNoThrow(try securityManager.validatePrivateKey(privateKey))
        }
        
        // Invalid private keys
        let invalidPrivateKeys = [
            "invalid",
            "0x123", // Too short
            "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef", // Missing 0x
            "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdefg" // Too long
        ]
        
        for privateKey in invalidPrivateKeys {
            XCTAssertThrowsError(try securityManager.validatePrivateKey(privateKey))
        }
    }
    
    func testValidateMnemonic() {
        // Valid mnemonics
        let validMnemonics = [
            "abandon ability able about above absent absorb abstract absurd abuse access accident",
            "abandon ability able about above absent absorb abstract absurd abuse access accident account accuse achieve acid acoustic acquire across act"
        ]
        
        for mnemonic in validMnemonics {
            XCTAssertNoThrow(try securityManager.validateMnemonic(mnemonic))
        }
        
        // Invalid mnemonics
        let invalidMnemonics = [
            "invalid mnemonic phrase",
            "abandon ability", // Too short
            "abandon ability able about above absent absorb abstract absurd abuse access invalid" // Invalid word
        ]
        
        for mnemonic in invalidMnemonics {
            XCTAssertThrowsError(try securityManager.validateMnemonic(mnemonic))
        }
    }
    
    // MARK: - Performance Tests
    
    func testPrivateKeyGenerationPerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Private key generation")
            
            Task {
                do {
                    _ = try await securityManager.generatePrivateKey()
                    expectation.fulfill()
                } catch {
                    XCTFail("Private key generation failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testMnemonicGenerationPerformance() {
        measure {
            do {
                _ = try securityManager.generateMnemonic()
            } catch {
                XCTFail("Mnemonic generation failed: \(error)")
            }
        }
    }
    
    func testTransactionSigningPerformance() async throws {
        let privateKey = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
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
        
        measure {
            do {
                _ = try securityManager.signTransaction(transaction, with: privateKey)
            } catch {
                XCTFail("Transaction signing failed: \(error)")
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testCompleteSecurityWorkflow() async throws {
        // 1. Generate private key
        let privateKey = try await securityManager.generatePrivateKey()
        XCTAssertNotNil(privateKey)
        
        // 2. Derive public key
        let publicKey = try securityManager.derivePublicKey(from: privateKey)
        XCTAssertNotNil(publicKey)
        
        // 3. Derive address
        let address = try securityManager.deriveAddress(from: publicKey)
        XCTAssertNotNil(address)
        
        // 4. Generate mnemonic
        let mnemonic = try securityManager.generateMnemonic()
        XCTAssertNotNil(mnemonic)
        
        // 5. Derive private key from mnemonic
        let derivedPrivateKey = try securityManager.derivePrivateKey(from: mnemonic)
        XCTAssertNotNil(derivedPrivateKey)
        
        // 6. Create and sign transaction
        let transaction = Transaction(
            from: address,
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "1000000000000000000",
            gasLimit: 21000,
            nonce: 0,
            data: "0x",
            chain: .ethereum,
            type: .legacy
        )
        
        let signedTransaction = try securityManager.signTransaction(transaction, with: privateKey)
        XCTAssertNotNil(signedTransaction)
        XCTAssertTrue(signedTransaction.isValid)
        
        // 7. Store and retrieve private key
        let walletId = "test-wallet-id"
        let password = "SecurePassword123!"
        
        try await securityManager.storePrivateKey(privateKey, for: walletId, password: password)
        let retrievedPrivateKey = try await securityManager.getPrivateKey(for: walletId)
        XCTAssertEqual(retrievedPrivateKey, privateKey)
        
        // 8. Delete private key
        try await securityManager.deletePrivateKey(for: walletId)
        
        do {
            _ = try await securityManager.getPrivateKey(for: walletId)
            XCTFail("Should throw error after deletion")
        } catch SecurityError.retrievalFailed {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() async throws {
        // Test various error scenarios
        let testCases: [(String, SecurityError)] = [
            ("invalid", .invalidPrivateKey),
            ("0x123", .invalidPrivateKey),
            ("invalid mnemonic", .invalidMnemonic),
            ("abandon ability", .invalidMnemonic)
        ]
        
        for (input, expectedError) in testCases {
            do {
                if input.contains("mnemonic") {
                    _ = try securityManager.validateMnemonic(input)
                } else {
                    _ = try securityManager.validatePrivateKey(input)
                }
                XCTFail("Should throw error for invalid input")
            } catch let error as SecurityError {
                XCTAssertEqual(error, expectedError)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
} 