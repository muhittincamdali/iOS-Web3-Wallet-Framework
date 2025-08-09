# Wallet Management API

<!-- TOC START -->
## Table of Contents
- [Wallet Management API](#wallet-management-api)
- [Overview](#overview)
- [Wallet Creation](#wallet-creation)
  - [Wallet Manager](#wallet-manager)
  - [Wallet Model](#wallet-model)
- [Key Management](#key-management)
  - [Key Manager](#key-manager)
- [Security Management](#security-management)
  - [Security Manager](#security-manager)
- [Storage Management](#storage-management)
  - [Storage Manager](#storage-manager)
- [Error Handling](#error-handling)
  - [Wallet Errors](#wallet-errors)
- [Testing](#testing)
  - [Wallet Management Tests](#wallet-management-tests)
- [Best Practices](#best-practices)
<!-- TOC END -->


## Overview

The Wallet Management API provides comprehensive wallet creation, management, and security features for Web3 applications. It supports multiple blockchain networks, secure key management, and advanced wallet operations.

## Wallet Creation

### Wallet Manager

```swift
protocol WalletManager {
    func createWallet() async throws -> Wallet
    func importWallet(privateKey: String, password: String) async throws -> Wallet
    func importWallet(mnemonic: String, password: String) async throws -> Wallet
    func backupWallet(_ wallet: Wallet) async throws -> WalletBackup
    func restoreWallet(_ backup: WalletBackup) async throws -> Wallet
    func deleteWallet(_ wallet: Wallet) async throws
}

class WalletManagerImpl: WalletManager {
    private let keyManager: KeyManager
    private let securityManager: SecurityManager
    private let storageManager: StorageManager
    
    init(keyManager: KeyManager, securityManager: SecurityManager, storageManager: StorageManager) {
        self.keyManager = keyManager
        self.securityManager = securityManager
        self.storageManager = storageManager
    }
    
    func createWallet() async throws -> Wallet {
        // Generate new private key
        let privateKey = try keyManager.generatePrivateKey()
        
        // Create wallet instance
        let wallet = Wallet(
            id: UUID(),
            address: try keyManager.deriveAddress(from: privateKey),
            privateKey: privateKey,
            publicKey: try keyManager.derivePublicKey(from: privateKey),
            networks: [.ethereum, .polygon, .bsc],
            createdAt: Date()
        )
        
        // Encrypt and store wallet
        try await securityManager.encryptWallet(wallet)
        try await storageManager.saveWallet(wallet)
        
        return wallet
    }
    
    func importWallet(privateKey: String, password: String) async throws -> Wallet {
        // Validate private key format
        guard keyManager.isValidPrivateKey(privateKey) else {
            throw WalletError.invalidPrivateKey
        }
        
        // Create wallet from private key
        let wallet = Wallet(
            id: UUID(),
            address: try keyManager.deriveAddress(from: privateKey),
            privateKey: privateKey,
            publicKey: try keyManager.derivePublicKey(from: privateKey),
            networks: [.ethereum, .polygon, .bsc],
            createdAt: Date()
        )
        
        // Encrypt and store wallet
        try await securityManager.encryptWallet(wallet)
        try await storageManager.saveWallet(wallet)
        
        return wallet
    }
    
    func importWallet(mnemonic: String, password: String) async throws -> Wallet {
        // Validate mnemonic
        guard keyManager.isValidMnemonic(mnemonic) else {
            throw WalletError.invalidMnemonic
        }
        
        // Derive private key from mnemonic
        let privateKey = try keyManager.derivePrivateKey(from: mnemonic)
        
        // Create wallet
        let wallet = Wallet(
            id: UUID(),
            address: try keyManager.deriveAddress(from: privateKey),
            privateKey: privateKey,
            publicKey: try keyManager.derivePublicKey(from: privateKey),
            networks: [.ethereum, .polygon, .bsc],
            createdAt: Date()
        )
        
        // Encrypt and store wallet
        try await securityManager.encryptWallet(wallet)
        try await storageManager.saveWallet(wallet)
        
        return wallet
    }
    
    func backupWallet(_ wallet: Wallet) async throws -> WalletBackup {
        let encryptedData = try await securityManager.encryptWalletData(wallet)
        
        return WalletBackup(
            id: UUID(),
            walletId: wallet.id,
            encryptedData: encryptedData,
            networks: wallet.networks,
            createdAt: Date()
        )
    }
    
    func restoreWallet(_ backup: WalletBackup) async throws -> Wallet {
        let wallet = try await securityManager.decryptWalletData(backup.encryptedData)
        try await storageManager.saveWallet(wallet)
        return wallet
    }
    
    func deleteWallet(_ wallet: Wallet) async throws {
        try await storageManager.deleteWallet(wallet)
    }
}
```

### Wallet Model

```swift
struct Wallet: Identifiable, Codable {
    let id: UUID
    let address: String
    let privateKey: String
    let publicKey: String
    let networks: [BlockchainNetwork]
    let createdAt: Date
    var updatedAt: Date
    
    var isActive: Bool {
        return !privateKey.isEmpty && !address.isEmpty
    }
    
    var supportedNetworks: [BlockchainNetwork] {
        return networks
    }
}

enum BlockchainNetwork: String, CaseIterable, Codable {
    case ethereum = "Ethereum"
    case polygon = "Polygon"
    case bsc = "BSC"
    case arbitrum = "Arbitrum"
    case optimism = "Optimism"
    case avalanche = "Avalanche"
    case fantom = "Fantom"
    case solana = "Solana"
    
    var chainId: Int {
        switch self {
        case .ethereum: return 1
        case .polygon: return 137
        case .bsc: return 56
        case .arbitrum: return 42161
        case .optimism: return 10
        case .avalanche: return 43114
        case .fantom: return 250
        case .solana: return 101
        }
    }
    
    var rpcUrl: String {
        switch self {
        case .ethereum: return "https://mainnet.infura.io/v3/YOUR_PROJECT_ID"
        case .polygon: return "https://polygon-rpc.com"
        case .bsc: return "https://bsc-dataseed.binance.org"
        case .arbitrum: return "https://arb1.arbitrum.io/rpc"
        case .optimism: return "https://mainnet.optimism.io"
        case .avalanche: return "https://api.avax.network/ext/bc/C/rpc"
        case .fantom: return "https://rpc.ftm.tools"
        case .solana: return "https://api.mainnet-beta.solana.com"
        }
    }
}

struct WalletBackup: Identifiable, Codable {
    let id: UUID
    let walletId: UUID
    let encryptedData: Data
    let networks: [BlockchainNetwork]
    let createdAt: Date
}
```

## Key Management

### Key Manager

```swift
protocol KeyManager {
    func generatePrivateKey() throws -> String
    func deriveAddress(from privateKey: String) throws -> String
    func derivePublicKey(from privateKey: String) throws -> String
    func isValidPrivateKey(_ privateKey: String) -> Bool
    func isValidMnemonic(_ mnemonic: String) -> Bool
    func derivePrivateKey(from mnemonic: String) throws -> String
    func generateMnemonic() throws -> String
}

class KeyManagerImpl: KeyManager {
    func generatePrivateKey() throws -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        
        guard status == errSecSuccess else {
            throw KeyManagerError.randomGenerationFailed
        }
        
        return bytes.map { String(format: "%02x", $0) }.joined()
    }
    
    func deriveAddress(from privateKey: String) throws -> String {
        // Implementation for deriving Ethereum address from private key
        // This would use secp256k1 curve and Keccak-256 hashing
        return "0x" + privateKey.suffix(40)
    }
    
    func derivePublicKey(from privateKey: String) throws -> String {
        // Implementation for deriving public key from private key
        // This would use secp256k1 curve
        return "0x" + privateKey.suffix(66)
    }
    
    func isValidPrivateKey(_ privateKey: String) -> Bool {
        // Validate private key format (64 hex characters)
        let hexRegex = "^[0-9a-fA-F]{64}$"
        return privateKey.range(of: hexRegex, options: .regularExpression) != nil
    }
    
    func isValidMnemonic(_ mnemonic: String) -> Bool {
        // Validate mnemonic format (12, 15, 18, 21, or 24 words)
        let words = mnemonic.components(separatedBy: " ")
        return [12, 15, 18, 21, 24].contains(words.count)
    }
    
    func derivePrivateKey(from mnemonic: String) throws -> String {
        // Implementation for deriving private key from mnemonic
        // This would use BIP-39 and BIP-44 standards
        return "0x" + mnemonic.hash.suffix(64)
    }
    
    func generateMnemonic() throws -> String {
        // Implementation for generating BIP-39 mnemonic
        // This would use cryptographically secure random generation
        let words = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", "accident"]
        return words.joined(separator: " ")
    }
}

enum KeyManagerError: Error, LocalizedError {
    case randomGenerationFailed
    case invalidPrivateKey
    case invalidMnemonic
    case derivationFailed
    
    var errorDescription: String? {
        switch self {
        case .randomGenerationFailed:
            return "Failed to generate random private key"
        case .invalidPrivateKey:
            return "Invalid private key format"
        case .invalidMnemonic:
            return "Invalid mnemonic format"
        case .derivationFailed:
            return "Failed to derive key from mnemonic"
        }
    }
}
```

## Security Management

### Security Manager

```swift
protocol SecurityManager {
    func encryptWallet(_ wallet: Wallet) async throws
    func decryptWallet(_ wallet: Wallet) async throws -> Wallet
    func encryptWalletData(_ wallet: Wallet) async throws -> Data
    func decryptWalletData(_ data: Data) async throws -> Wallet
    func validateBiometricAuth() async throws -> Bool
    func enableBiometricAuth(_ wallet: Wallet) async throws
    func disableBiometricAuth(_ wallet: Wallet) async throws
}

class SecurityManagerImpl: SecurityManager {
    private let keychain = KeychainService()
    private let biometricAuth = BiometricAuthenticator()
    
    func encryptWallet(_ wallet: Wallet) async throws {
        let walletData = try JSONEncoder().encode(wallet)
        let encryptedData = try await encryptData(walletData)
        try await keychain.save(encryptedData, forKey: "wallet_\(wallet.id)")
    }
    
    func decryptWallet(_ wallet: Wallet) async throws -> Wallet {
        let encryptedData = try await keychain.load(forKey: "wallet_\(wallet.id)")
        let walletData = try await decryptData(encryptedData)
        return try JSONDecoder().decode(Wallet.self, from: walletData)
    }
    
    func encryptWalletData(_ wallet: Wallet) async throws -> Data {
        let walletData = try JSONEncoder().encode(wallet)
        return try await encryptData(walletData)
    }
    
    func decryptWalletData(_ data: Data) async throws -> Wallet {
        let walletData = try await decryptData(data)
        return try JSONDecoder().decode(Wallet.self, from: walletData)
    }
    
    func validateBiometricAuth() async throws -> Bool {
        return try await biometricAuth.authenticate(reason: "Access wallet")
    }
    
    func enableBiometricAuth(_ wallet: Wallet) async throws {
        let isAuthenticated = try await validateBiometricAuth()
        guard isAuthenticated else {
            throw SecurityError.biometricAuthFailed
        }
        
        // Enable biometric authentication for wallet
        try await biometricAuth.enableForWallet(wallet.id)
    }
    
    func disableBiometricAuth(_ wallet: Wallet) async throws {
        let isAuthenticated = try await validateBiometricAuth()
        guard isAuthenticated else {
            throw SecurityError.biometricAuthFailed
        }
        
        // Disable biometric authentication for wallet
        try await biometricAuth.disableForWallet(wallet.id)
    }
    
    private func encryptData(_ data: Data) async throws -> Data {
        // Implementation for AES encryption
        return data // Placeholder
    }
    
    private func decryptData(_ data: Data) async throws -> Data {
        // Implementation for AES decryption
        return data // Placeholder
    }
}

enum SecurityError: Error, LocalizedError {
    case biometricAuthFailed
    case encryptionFailed
    case decryptionFailed
    case keychainError
    
    var errorDescription: String? {
        switch self {
        case .biometricAuthFailed:
            return "Biometric authentication failed"
        case .encryptionFailed:
            return "Failed to encrypt wallet data"
        case .decryptionFailed:
            return "Failed to decrypt wallet data"
        case .keychainError:
            return "Keychain operation failed"
        }
    }
}
```

## Storage Management

### Storage Manager

```swift
protocol StorageManager {
    func saveWallet(_ wallet: Wallet) async throws
    func loadWallet(id: UUID) async throws -> Wallet
    func loadAllWallets() async throws -> [Wallet]
    func deleteWallet(_ wallet: Wallet) async throws
    func updateWallet(_ wallet: Wallet) async throws
}

class StorageManagerImpl: StorageManager {
    private let keychain = KeychainService()
    private let userDefaults = UserDefaults.standard
    
    func saveWallet(_ wallet: Wallet) async throws {
        // Save wallet metadata to UserDefaults
        let walletInfo = WalletInfo(
            id: wallet.id,
            address: wallet.address,
            networks: wallet.networks,
            createdAt: wallet.createdAt,
            updatedAt: wallet.updatedAt
        )
        
        let walletInfoData = try JSONEncoder().encode(walletInfo)
        userDefaults.set(walletInfoData, forKey: "wallet_info_\(wallet.id)")
        
        // Save encrypted wallet data to Keychain
        let walletData = try JSONEncoder().encode(wallet)
        let encryptedData = try await encryptWalletData(walletData)
        try await keychain.save(encryptedData, forKey: "wallet_data_\(wallet.id)")
    }
    
    func loadWallet(id: UUID) async throws -> Wallet {
        // Load encrypted wallet data from Keychain
        let encryptedData = try await keychain.load(forKey: "wallet_data_\(id)")
        let walletData = try await decryptWalletData(encryptedData)
        return try JSONDecoder().decode(Wallet.self, from: walletData)
    }
    
    func loadAllWallets() async throws -> [Wallet] {
        let walletIds = getWalletIds()
        var wallets: [Wallet] = []
        
        for id in walletIds {
            do {
                let wallet = try await loadWallet(id: id)
                wallets.append(wallet)
            } catch {
                // Skip corrupted wallets
                continue
            }
        }
        
        return wallets
    }
    
    func deleteWallet(_ wallet: Wallet) async throws {
        // Remove wallet metadata from UserDefaults
        userDefaults.removeObject(forKey: "wallet_info_\(wallet.id)")
        
        // Remove encrypted wallet data from Keychain
        try await keychain.delete(forKey: "wallet_data_\(wallet.id)")
        
        // Update wallet IDs list
        removeWalletId(wallet.id)
    }
    
    func updateWallet(_ wallet: Wallet) async throws {
        var updatedWallet = wallet
        updatedWallet.updatedAt = Date()
        try await saveWallet(updatedWallet)
    }
    
    private func getWalletIds() -> [UUID] {
        guard let data = userDefaults.data(forKey: "wallet_ids"),
              let ids = try? JSONDecoder().decode([UUID].self, from: data) else {
            return []
        }
        return ids
    }
    
    private func addWalletId(_ id: UUID) {
        var ids = getWalletIds()
        if !ids.contains(id) {
            ids.append(id)
            if let data = try? JSONEncoder().encode(ids) {
                userDefaults.set(data, forKey: "wallet_ids")
            }
        }
    }
    
    private func removeWalletId(_ id: UUID) {
        var ids = getWalletIds()
        ids.removeAll { $0 == id }
        if let data = try? JSONEncoder().encode(ids) {
            userDefaults.set(data, forKey: "wallet_ids")
        }
    }
    
    private func encryptWalletData(_ data: Data) async throws -> Data {
        // Implementation for encrypting wallet data
        return data // Placeholder
    }
    
    private func decryptWalletData(_ data: Data) async throws -> Data {
        // Implementation for decrypting wallet data
        return data // Placeholder
    }
}

struct WalletInfo: Codable {
    let id: UUID
    let address: String
    let networks: [BlockchainNetwork]
    let createdAt: Date
    let updatedAt: Date
}
```

## Error Handling

### Wallet Errors

```swift
enum WalletError: Error, LocalizedError {
    case walletNotFound
    case invalidPrivateKey
    case invalidMnemonic
    case walletAlreadyExists
    case backupFailed
    case restoreFailed
    case networkNotSupported
    case insufficientBalance
    
    var errorDescription: String? {
        switch self {
        case .walletNotFound:
            return "Wallet not found"
        case .invalidPrivateKey:
            return "Invalid private key format"
        case .invalidMnemonic:
            return "Invalid mnemonic format"
        case .walletAlreadyExists:
            return "Wallet already exists"
        case .backupFailed:
            return "Failed to backup wallet"
        case .restoreFailed:
            return "Failed to restore wallet"
        case .networkNotSupported:
            return "Network not supported"
        case .insufficientBalance:
            return "Insufficient balance"
        }
    }
}
```

## Testing

### Wallet Management Tests

```swift
class WalletManagementTests: XCTestCase {
    var walletManager: WalletManager!
    var mockKeyManager: MockKeyManager!
    var mockSecurityManager: MockSecurityManager!
    var mockStorageManager: MockStorageManager!
    
    override func setUp() {
        super.setUp()
        mockKeyManager = MockKeyManager()
        mockSecurityManager = MockSecurityManager()
        mockStorageManager = MockStorageManager()
        walletManager = WalletManagerImpl(
            keyManager: mockKeyManager,
            securityManager: mockSecurityManager,
            storageManager: mockStorageManager
        )
    }
    
    func testCreateWalletSuccess() async throws {
        // Given
        let expectedPrivateKey = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        let expectedAddress = "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
        mockKeyManager.mockPrivateKey = expectedPrivateKey
        mockKeyManager.mockAddress = expectedAddress
        
        // When
        let wallet = try await walletManager.createWallet()
        
        // Then
        XCTAssertEqual(wallet.address, expectedAddress)
        XCTAssertEqual(wallet.privateKey, expectedPrivateKey)
        XCTAssertTrue(wallet.isActive)
    }
    
    func testImportWalletSuccess() async throws {
        // Given
        let privateKey = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        let expectedAddress = "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
        mockKeyManager.mockAddress = expectedAddress
        mockKeyManager.mockIsValidPrivateKey = true
        
        // When
        let wallet = try await walletManager.importWallet(privateKey: privateKey, password: "password")
        
        // Then
        XCTAssertEqual(wallet.address, expectedAddress)
        XCTAssertEqual(wallet.privateKey, privateKey)
        XCTAssertTrue(wallet.isActive)
    }
    
    func testImportWalletInvalidPrivateKey() async throws {
        // Given
        let invalidPrivateKey = "invalid_key"
        mockKeyManager.mockIsValidPrivateKey = false
        
        // When & Then
        do {
            let _ = try await walletManager.importWallet(privateKey: invalidPrivateKey, password: "password")
            XCTFail("Expected error but got success")
        } catch WalletError.invalidPrivateKey {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
```

## Best Practices

1. **Security First**: Always encrypt sensitive wallet data
2. **Biometric Authentication**: Use biometric auth for wallet access
3. **Key Management**: Implement secure key generation and storage
4. **Multi-Network Support**: Support multiple blockchain networks
5. **Backup & Recovery**: Provide secure backup and restore functionality
6. **Error Handling**: Provide clear error messages for wallet operations 