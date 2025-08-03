import XCTest
import Web3Wallet
@testable import Web3Wallet

@available(iOS 15.0, *)
final class WalletTests: XCTestCase {
    
    // MARK: - Properties
    
    var testWallet: Wallet!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
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
        testWallet = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testWalletInitialization() {
        // Given
        let id = "test-id"
        let name = "Test Wallet"
        let address = "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
        let publicKey = "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec"
        let mnemonic = "abandon ability able about above absent absorb abstract absurd abuse access accident"
        let createdAt = Date()
        let isActive = true
        
        // When
        let wallet = Wallet(
            id: id,
            name: name,
            address: address,
            publicKey: publicKey,
            mnemonic: mnemonic,
            createdAt: createdAt,
            isActive: isActive
        )
        
        // Then
        XCTAssertEqual(wallet.id, id)
        XCTAssertEqual(wallet.name, name)
        XCTAssertEqual(wallet.address, address)
        XCTAssertEqual(wallet.publicKey, publicKey)
        XCTAssertEqual(wallet.mnemonic, mnemonic)
        XCTAssertEqual(wallet.createdAt, createdAt)
        XCTAssertEqual(wallet.isActive, isActive)
        XCTAssertEqual(wallet.walletType, .hd)
        XCTAssertEqual(wallet.securityLevel, .standard)
    }
    
    func testWalletInitializationWithoutMnemonic() {
        // Given
        let id = "test-id"
        let name = "Imported Wallet"
        let address = "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
        let publicKey = "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec"
        let createdAt = Date()
        let isActive = true
        
        // When
        let wallet = Wallet(
            id: id,
            name: name,
            address: address,
            publicKey: publicKey,
            mnemonic: nil,
            createdAt: createdAt,
            isActive: isActive
        )
        
        // Then
        XCTAssertEqual(wallet.id, id)
        XCTAssertEqual(wallet.name, name)
        XCTAssertEqual(wallet.address, address)
        XCTAssertEqual(wallet.publicKey, publicKey)
        XCTAssertNil(wallet.mnemonic)
        XCTAssertEqual(wallet.createdAt, createdAt)
        XCTAssertEqual(wallet.isActive, isActive)
    }
    
    // MARK: - Computed Properties Tests
    
    func testShortAddress() {
        // Given
        let wallet = Wallet(
            id: "test",
            name: "Test",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: nil,
            createdAt: Date(),
            isActive: true
        )
        
        // When
        let shortAddress = wallet.shortAddress
        
        // Then
        XCTAssertEqual(shortAddress, "0x742d...8b6")
    }
    
    func testShortAddressWithShortAddress() {
        // Given
        let wallet = Wallet(
            id: "test",
            name: "Test",
            address: "0x123",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: nil,
            createdAt: Date(),
            isActive: true
        )
        
        // When
        let shortAddress = wallet.shortAddress
        
        // Then
        XCTAssertEqual(shortAddress, "0x123")
    }
    
    func testHasMnemonic() {
        // Given
        let walletWithMnemonic = Wallet(
            id: "test",
            name: "Test",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: "abandon ability able about above absent absorb abstract absurd abuse access accident",
            createdAt: Date(),
            isActive: true
        )
        
        let walletWithoutMnemonic = Wallet(
            id: "test",
            name: "Test",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: nil,
            createdAt: Date(),
            isActive: true
        )
        
        // Then
        XCTAssertTrue(walletWithMnemonic.hasMnemonic)
        XCTAssertFalse(walletWithoutMnemonic.hasMnemonic)
    }
    
    func testAgeInDays() {
        // Given
        let wallet = Wallet(
            id: "test",
            name: "Test",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: nil,
            createdAt: Date().addingTimeInterval(-86400 * 5), // 5 days ago
            isActive: true
        )
        
        // When
        let ageInDays = wallet.ageInDays
        
        // Then
        XCTAssertEqual(ageInDays, 5)
    }
    
    func testIsNew() {
        // Given
        let newWallet = Wallet(
            id: "test",
            name: "Test",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: nil,
            createdAt: Date().addingTimeInterval(-86400 * 3), // 3 days ago
            isActive: true
        )
        
        let oldWallet = Wallet(
            id: "test",
            name: "Test",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: nil,
            createdAt: Date().addingTimeInterval(-86400 * 10), // 10 days ago
            isActive: true
        )
        
        // Then
        XCTAssertTrue(newWallet.isNew)
        XCTAssertFalse(oldWallet.isNew)
    }
    
    // MARK: - Validation Tests
    
    func testWalletValidation() {
        // Given
        let validWallet = Wallet(
            id: "test",
            name: "Test Wallet",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: nil,
            createdAt: Date(),
            isActive: true
        )
        
        // Then
        XCTAssertTrue(validWallet.isValid)
    }
    
    func testWalletValidationWithInvalidAddress() {
        // Given
        let invalidWallet = Wallet(
            id: "test",
            name: "Test Wallet",
            address: "invalid-address",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: nil,
            createdAt: Date(),
            isActive: true
        )
        
        // Then
        XCTAssertFalse(invalidWallet.isValid)
    }
    
    func testWalletValidationWithInvalidPublicKey() {
        // Given
        let invalidWallet = Wallet(
            id: "test",
            name: "Test Wallet",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            publicKey: "invalid-public-key",
            mnemonic: nil,
            createdAt: Date(),
            isActive: true
        )
        
        // Then
        XCTAssertFalse(invalidWallet.isValid)
    }
    
    func testWalletValidationWithEmptyFields() {
        // Given
        let invalidWallet = Wallet(
            id: "",
            name: "",
            address: "",
            publicKey: "",
            mnemonic: nil,
            createdAt: Date(),
            isActive: true
        )
        
        // Then
        XCTAssertFalse(invalidWallet.isValid)
    }
    
    func testChecksumValidation() {
        // Given
        let walletWithValidChecksum = Wallet(
            id: "test",
            name: "Test",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: nil,
            createdAt: Date(),
            isActive: true
        )
        
        // Then
        XCTAssertTrue(walletWithValidChecksum.hasValidChecksum)
    }
    
    // MARK: - Methods Tests
    
    func testUpdateLastUsed() {
        // Given
        var wallet = testWallet
        let originalLastUsed = wallet.lastUsed
        
        // When
        wallet.updateLastUsed()
        
        // Then
        XCTAssertNotEqual(wallet.lastUsed, originalLastUsed)
        XCTAssertGreaterThan(wallet.lastUsed!, originalLastUsed!)
    }
    
    func testAddMetadata() {
        // Given
        var wallet = testWallet
        let key = "test_key"
        let value = "test_value"
        
        // When
        wallet.addMetadata(key: key, value: value)
        
        // Then
        XCTAssertEqual(wallet.metadata[key], value)
    }
    
    func testRemoveMetadata() {
        // Given
        var wallet = testWallet
        let key = "test_key"
        let value = "test_value"
        wallet.addMetadata(key: key, value: value)
        
        // When
        wallet.removeMetadata(key: key)
        
        // Then
        XCTAssertNil(wallet.metadata[key])
    }
    
    func testSupportsBlockchain() {
        // Given
        var wallet = testWallet
        
        // Then
        XCTAssertTrue(wallet.supports(.ethereum))
        XCTAssertTrue(wallet.supports(.polygon))
        XCTAssertTrue(wallet.supports(.bsc))
        XCTAssertFalse(wallet.supports(.arbitrum))
    }
    
    func testAddNetworkSupport() {
        // Given
        var wallet = testWallet
        let newNetwork: Blockchain = .arbitrum
        
        // When
        wallet.addNetworkSupport(newNetwork)
        
        // Then
        XCTAssertTrue(wallet.supports(newNetwork))
    }
    
    func testRemoveNetworkSupport() {
        // Given
        var wallet = testWallet
        let network: Blockchain = .ethereum
        
        // When
        wallet.removeNetworkSupport(network)
        
        // Then
        XCTAssertFalse(wallet.supports(network))
    }
    
    // MARK: - Codable Tests
    
    func testWalletEncoding() throws {
        // Given
        let wallet = testWallet
        
        // When
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(wallet)
        
        // Then
        XCTAssertNotNil(data)
        XCTAssertGreaterThan(data.count, 0)
    }
    
    func testWalletDecoding() throws {
        // Given
        let wallet = testWallet
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(wallet)
        
        // When
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedWallet = try decoder.decode(Wallet.self, from: data)
        
        // Then
        XCTAssertEqual(decodedWallet.id, wallet.id)
        XCTAssertEqual(decodedWallet.name, wallet.name)
        XCTAssertEqual(decodedWallet.address, wallet.address)
        XCTAssertEqual(decodedWallet.publicKey, wallet.publicKey)
        XCTAssertEqual(decodedWallet.mnemonic, wallet.mnemonic)
        XCTAssertEqual(decodedWallet.isActive, wallet.isActive)
    }
    
    // MARK: - Equatable Tests
    
    func testWalletEquality() {
        // Given
        let wallet1 = testWallet
        let wallet2 = Wallet(
            id: "test-wallet-id",
            name: "Test Wallet",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: "abandon ability able about above absent absorb abstract absurd abuse access accident",
            createdAt: testWallet.createdAt,
            isActive: true
        )
        
        // Then
        XCTAssertEqual(wallet1, wallet2)
    }
    
    func testWalletInequality() {
        // Given
        let wallet1 = testWallet
        let wallet2 = Wallet(
            id: "different-id",
            name: "Test Wallet",
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            publicKey: "0x04a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e2477a2a0c0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaec",
            mnemonic: "abandon ability able about above absent absorb abstract absurd abuse access accident",
            createdAt: testWallet.createdAt,
            isActive: true
        )
        
        // Then
        XCTAssertNotEqual(wallet1, wallet2)
    }
}

// MARK: - Supporting Types Tests

@available(iOS 15.0, *)
final class SupportingTypesTests: XCTestCase {
    
    // MARK: - WalletType Tests
    
    func testWalletTypeDisplayNames() {
        XCTAssertEqual(WalletType.hd.displayName, "HD Wallet")
        XCTAssertEqual(WalletType.hardware.displayName, "Hardware Wallet")
        XCTAssertEqual(WalletType.watchOnly.displayName, "Watch Only")
        XCTAssertEqual(WalletType.multiSig.displayName, "Multi-Signature")
        XCTAssertEqual(WalletType.smartContract.displayName, "Smart Contract")
    }
    
    func testWalletTypeDescriptions() {
        XCTAssertFalse(WalletType.hd.description.isEmpty)
        XCTAssertFalse(WalletType.hardware.description.isEmpty)
        XCTAssertFalse(WalletType.watchOnly.description.isEmpty)
        XCTAssertFalse(WalletType.multiSig.description.isEmpty)
        XCTAssertFalse(WalletType.smartContract.description.isEmpty)
    }
    
    // MARK: - SecurityLevel Tests
    
    func testSecurityLevelDisplayNames() {
        XCTAssertEqual(SecurityLevel.basic.displayName, "Basic Security")
        XCTAssertEqual(SecurityLevel.standard.displayName, "Standard Security")
        XCTAssertEqual(SecurityLevel.high.displayName, "High Security")
        XCTAssertEqual(SecurityLevel.maximum.displayName, "Maximum Security")
    }
    
    func testSecurityLevelDescriptions() {
        XCTAssertFalse(SecurityLevel.basic.description.isEmpty)
        XCTAssertFalse(SecurityLevel.standard.description.isEmpty)
        XCTAssertFalse(SecurityLevel.high.description.isEmpty)
        XCTAssertFalse(SecurityLevel.maximum.description.isEmpty)
    }
    
    func testSecurityLevelBiometricRequirements() {
        XCTAssertFalse(SecurityLevel.basic.requiresBiometric)
        XCTAssertTrue(SecurityLevel.standard.requiresBiometric)
        XCTAssertTrue(SecurityLevel.high.requiresBiometric)
        XCTAssertTrue(SecurityLevel.maximum.requiresBiometric)
    }
    
    func testSecurityLevelHardwareRequirements() {
        XCTAssertFalse(SecurityLevel.basic.requiresHardwareWallet)
        XCTAssertFalse(SecurityLevel.standard.requiresHardwareWallet)
        XCTAssertFalse(SecurityLevel.high.requiresHardwareWallet)
        XCTAssertTrue(SecurityLevel.maximum.requiresHardwareWallet)
    }
    
    // MARK: - Blockchain Tests
    
    func testBlockchainDisplayNames() {
        XCTAssertEqual(Blockchain.ethereum.displayName, "Ethereum")
        XCTAssertEqual(Blockchain.polygon.displayName, "Polygon")
        XCTAssertEqual(Blockchain.bsc.displayName, "Binance Smart Chain")
        XCTAssertEqual(Blockchain.arbitrum.displayName, "Arbitrum")
        XCTAssertEqual(Blockchain.optimism.displayName, "Optimism")
        XCTAssertEqual(Blockchain.avalanche.displayName, "Avalanche")
        XCTAssertEqual(Blockchain.goerli.displayName, "Goerli Testnet")
        XCTAssertEqual(Blockchain.mumbai.displayName, "Mumbai Testnet")
    }
    
    func testBlockchainChainIds() {
        XCTAssertEqual(Blockchain.ethereum.chainId, 1)
        XCTAssertEqual(Blockchain.polygon.chainId, 137)
        XCTAssertEqual(Blockchain.bsc.chainId, 56)
        XCTAssertEqual(Blockchain.arbitrum.chainId, 42161)
        XCTAssertEqual(Blockchain.optimism.chainId, 10)
        XCTAssertEqual(Blockchain.avalanche.chainId, 43114)
        XCTAssertEqual(Blockchain.goerli.chainId, 5)
        XCTAssertEqual(Blockchain.mumbai.chainId, 80001)
    }
    
    func testBlockchainTestnetStatus() {
        XCTAssertFalse(Blockchain.ethereum.isTestnet)
        XCTAssertFalse(Blockchain.polygon.isTestnet)
        XCTAssertFalse(Blockchain.bsc.isTestnet)
        XCTAssertFalse(Blockchain.arbitrum.isTestnet)
        XCTAssertFalse(Blockchain.optimism.isTestnet)
        XCTAssertFalse(Blockchain.avalanche.isTestnet)
        XCTAssertTrue(Blockchain.goerli.isTestnet)
        XCTAssertTrue(Blockchain.mumbai.isTestnet)
    }
    
    func testBlockchainExplorerUrls() {
        XCTAssertEqual(Blockchain.ethereum.explorerUrl, "https://etherscan.io")
        XCTAssertEqual(Blockchain.polygon.explorerUrl, "https://polygonscan.com")
        XCTAssertEqual(Blockchain.bsc.explorerUrl, "https://bscscan.com")
        XCTAssertEqual(Blockchain.arbitrum.explorerUrl, "https://arbiscan.io")
        XCTAssertEqual(Blockchain.optimism.explorerUrl, "https://optimistic.etherscan.io")
        XCTAssertEqual(Blockchain.avalanche.explorerUrl, "https://snowtrace.io")
        XCTAssertEqual(Blockchain.goerli.explorerUrl, "https://goerli.etherscan.io")
        XCTAssertEqual(Blockchain.mumbai.explorerUrl, "https://mumbai.polygonscan.com")
    }
} 