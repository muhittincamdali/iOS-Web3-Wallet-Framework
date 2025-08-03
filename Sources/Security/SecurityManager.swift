import Foundation
import CryptoSwift
import LocalAuthentication
import KeychainSwift

/// Manages all security-related operations for the Web3 wallet
@available(iOS 15.0, *)
public class SecurityManager {
    
    // MARK: - Properties
    
    /// Keychain for secure storage
    private let keychain = KeychainSwift()
    
    /// Biometric authentication context
    private let biometricContext = LAContext()
    
    /// Logger for security events
    private let logger = Logger(label: "SecurityManager")
    
    /// Encryption key for additional security layer
    private var encryptionKey: Data?
    
    // MARK: - Initialization
    
    /// Initialize SecurityManager
    public init() {
        setupKeychain()
        setupBiometricAuthentication()
    }
    
    // MARK: - Key Management
    
    /// Generates a new private key
    /// - Returns: Private key in hex format
    /// - Throws: `SecurityError.keyGenerationFailed` if generation fails
    public func generatePrivateKey() async throws -> String {
        logger.info("Generating new private key")
        
        do {
            // Generate random bytes for private key
            let privateKeyBytes = try generateSecureRandomBytes(count: 32)
            let privateKey = "0x" + privateKeyBytes.toHexString()
            
            // Validate private key
            try validatePrivateKey(privateKey)
            
            logger.info("Private key generated successfully")
            return privateKey
        } catch {
            logger.error("Failed to generate private key: \(error)")
            throw SecurityError.keyGenerationFailed
        }
    }
    
    /// Derives public key from private key
    /// - Parameter privateKey: Private key in hex format
    /// - Returns: Public key in hex format
    /// - Throws: `SecurityError.invalidPrivateKey` if private key is invalid
    public func derivePublicKey(from privateKey: String) throws -> String {
        logger.info("Deriving public key from private key")
        
        do {
            // Remove 0x prefix if present
            let cleanPrivateKey = privateKey.hasPrefix("0x") ? String(privateKey.dropFirst(2)) : privateKey
            
            // Convert to bytes
            guard let privateKeyBytes = Data(hex: cleanPrivateKey) else {
                throw SecurityError.invalidPrivateKey
            }
            
            // Generate public key using secp256k1
            let publicKey = try generatePublicKey(from: privateKeyBytes)
            
            logger.info("Public key derived successfully")
            return publicKey
        } catch {
            logger.error("Failed to derive public key: \(error)")
            throw SecurityError.invalidPrivateKey
        }
    }
    
    /// Derives address from public key
    /// - Parameter publicKey: Public key in hex format
    /// - Returns: Ethereum address
    /// - Throws: `SecurityError.invalidPublicKey` if public key is invalid
    public func deriveAddress(from publicKey: String) throws -> String {
        logger.info("Deriving address from public key")
        
        do {
            // Remove 0x prefix if present
            let cleanPublicKey = publicKey.hasPrefix("0x") ? String(publicKey.dropFirst(2)) : publicKey
            
            // Convert to bytes
            guard let publicKeyBytes = Data(hex: cleanPublicKey) else {
                throw SecurityError.invalidPublicKey
            }
            
            // Remove prefix byte (0x04) and take last 20 bytes
            let addressBytes = publicKeyBytes.dropFirst().suffix(20)
            
            // Convert to address format
            let address = "0x" + addressBytes.toHexString()
            
            logger.info("Address derived successfully: \(address)")
            return address
        } catch {
            logger.error("Failed to derive address: \(error)")
            throw SecurityError.invalidPublicKey
        }
    }
    
    /// Generates mnemonic phrase
    /// - Returns: Mnemonic phrase
    /// - Throws: `SecurityError.mnemonicGenerationFailed` if generation fails
    public func generateMnemonic() throws -> String {
        logger.info("Generating mnemonic phrase")
        
        do {
            // Generate entropy
            let entropy = try generateSecureRandomBytes(count: 16)
            
            // Convert entropy to mnemonic
            let mnemonic = try entropyToMnemonic(entropy)
            
            logger.info("Mnemonic generated successfully")
            return mnemonic
        } catch {
            logger.error("Failed to generate mnemonic: \(error)")
            throw SecurityError.mnemonicGenerationFailed
        }
    }
    
    /// Derives private key from mnemonic phrase
    /// - Parameter mnemonic: Mnemonic phrase
    /// - Returns: Private key in hex format
    /// - Throws: `SecurityError.invalidMnemonic` if mnemonic is invalid
    public func derivePrivateKey(from mnemonic: String) throws -> String {
        logger.info("Deriving private key from mnemonic")
        
        do {
            // Validate mnemonic
            try validateMnemonic(mnemonic)
            
            // Convert mnemonic to entropy
            let entropy = try mnemonicToEntropy(mnemonic)
            
            // Convert entropy to private key
            let privateKey = "0x" + entropy.toHexString()
            
            logger.info("Private key derived from mnemonic successfully")
            return privateKey
        } catch {
            logger.error("Failed to derive private key from mnemonic: \(error)")
            throw SecurityError.invalidMnemonic
        }
    }
    
    // MARK: - Transaction Signing
    
    /// Signs a transaction with private key
    /// - Parameters:
    ///   - transaction: Transaction to sign
    ///   - privateKey: Private key in hex format
    /// - Returns: Signed transaction
    /// - Throws: `SecurityError.signingFailed` if signing fails
    public func signTransaction(_ transaction: Transaction, with privateKey: String) throws -> SignedTransaction {
        logger.info("Signing transaction: \(transaction.id)")
        
        do {
            // Remove 0x prefix from private key
            let cleanPrivateKey = privateKey.hasPrefix("0x") ? String(privateKey.dropFirst(2)) : privateKey
            
            // Convert private key to bytes
            guard let privateKeyBytes = Data(hex: cleanPrivateKey) else {
                throw SecurityError.invalidPrivateKey
            }
            
            // Create transaction data for signing
            let transactionData = try createTransactionData(for: transaction)
            
            // Sign transaction data
            let signature = try signData(transactionData, with: privateKeyBytes)
            
            // Create raw transaction
            let rawTransaction = try createRawTransaction(transaction, signature: signature)
            
            // Create signed transaction
            let signedTransaction = SignedTransaction(
                transaction: transaction,
                signature: signature,
                rawTransaction: rawTransaction,
                signedBy: transaction.from
            )
            
            logger.info("Transaction signed successfully")
            return signedTransaction
        } catch {
            logger.error("Failed to sign transaction: \(error)")
            throw SecurityError.signingFailed
        }
    }
    
    // MARK: - Secure Storage
    
    /// Stores private key securely
    /// - Parameters:
    ///   - privateKey: Private key to store
    ///   - walletId: Wallet identifier
    ///   - password: Password for encryption
    /// - Throws: `SecurityError.storageFailed` if storage fails
    public func storePrivateKey(_ privateKey: String, for walletId: String, password: String) async throws {
        logger.info("Storing private key for wallet: \(walletId)")
        
        do {
            // Encrypt private key with password
            let encryptedKey = try encryptData(privateKey.data(using: .utf8)!, with: password)
            
            // Store in keychain
            let key = "private_key_\(walletId)"
            keychain.set(encryptedKey, forKey: key)
            
            logger.info("Private key stored successfully")
        } catch {
            logger.error("Failed to store private key: \(error)")
            throw SecurityError.storageFailed
        }
    }
    
    /// Retrieves private key securely
    /// - Parameter walletId: Wallet identifier
    /// - Returns: Private key in hex format
    /// - Throws: `SecurityError.retrievalFailed` if retrieval fails
    public func getPrivateKey(for walletId: String) async throws -> String {
        logger.info("Retrieving private key for wallet: \(walletId)")
        
        do {
            // Get from keychain
            let key = "private_key_\(walletId)"
            guard let encryptedKey = keychain.getData(key) else {
                throw SecurityError.retrievalFailed
            }
            
            // Decrypt private key
            let privateKey = try decryptData(encryptedKey)
            
            logger.info("Private key retrieved successfully")
            return privateKey
        } catch {
            logger.error("Failed to retrieve private key: \(error)")
            throw SecurityError.retrievalFailed
        }
    }
    
    /// Deletes private key securely
    /// - Parameter walletId: Wallet identifier
    /// - Throws: `SecurityError.deletionFailed` if deletion fails
    public func deletePrivateKey(for walletId: String) async throws {
        logger.info("Deleting private key for wallet: \(walletId)")
        
        do {
            let key = "private_key_\(walletId)"
            keychain.delete(key)
            
            logger.info("Private key deleted successfully")
        } catch {
            logger.error("Failed to delete private key: \(error)")
            throw SecurityError.deletionFailed
        }
    }
    
    // MARK: - Biometric Authentication
    
    /// Authenticates user using biometric authentication
    /// - Returns: True if authentication succeeds
    /// - Throws: `SecurityError.authenticationFailed` if authentication fails
    public func authenticateWithBiometrics() async throws -> Bool {
        logger.info("Authenticating with biometrics")
        
        return try await withCheckedThrowingContinuation { continuation in
            let reason = "Authenticate to access your wallet"
            
            biometricContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    self.logger.info("Biometric authentication successful")
                    continuation.resume(returning: true)
                } else {
                    self.logger.error("Biometric authentication failed: \(error?.localizedDescription ?? "Unknown error")")
                    continuation.resume(throwing: SecurityError.authenticationFailed)
                }
            }
        }
    }
    
    /// Checks if biometric authentication is available
    /// - Returns: True if biometric authentication is available
    public func isBiometricAuthenticationAvailable() -> Bool {
        var error: NSError?
        let canEvaluate = biometricContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if !canEvaluate {
            logger.warning("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
        
        return canEvaluate
    }
    
    // MARK: - Private Methods
    
    /// Sets up keychain configuration
    private func setupKeychain() {
        keychain.synchronizable = false
        keychain.accessibility = .whenUnlockedThisDeviceOnly
    }
    
    /// Sets up biometric authentication
    private func setupBiometricAuthentication() {
        biometricContext.localizedFallbackTitle = "Use Passcode"
    }
    
    /// Generates secure random bytes
    /// - Parameter count: Number of bytes to generate
    /// - Returns: Random bytes
    /// - Throws: `SecurityError.randomGenerationFailed` if generation fails
    private func generateSecureRandomBytes(count: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        
        guard status == errSecSuccess else {
            throw SecurityError.randomGenerationFailed
        }
        
        return Data(bytes)
    }
    
    /// Generates public key from private key
    /// - Parameter privateKeyBytes: Private key bytes
    /// - Returns: Public key in hex format
    /// - Throws: `SecurityError.publicKeyGenerationFailed` if generation fails
    private func generatePublicKey(from privateKeyBytes: Data) throws -> String {
        // This is a simplified implementation
        // In a real implementation, you would use a proper cryptographic library
        // like CryptoSwift or a native implementation
        
        // For now, we'll create a mock public key
        let publicKeyBytes = privateKeyBytes + Data(repeating: 0x04, count: 1)
        return "0x" + publicKeyBytes.toHexString()
    }
    
    /// Converts entropy to mnemonic phrase
    /// - Parameter entropy: Entropy bytes
    /// - Returns: Mnemonic phrase
    /// - Throws: `SecurityError.mnemonicConversionFailed` if conversion fails
    private func entropyToMnemonic(_ entropy: Data) throws -> String {
        // This is a simplified implementation
        // In a real implementation, you would use BIP39 standard
        
        let words = [
            "abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse",
            "access", "accident", "account", "accuse", "achieve", "acid", "acoustic", "acquire", "across", "act"
        ]
        
        var mnemonic: [String] = []
        for i in 0..<12 {
            let index = Int(entropy[i % entropy.count]) % words.count
            mnemonic.append(words[index])
        }
        
        return mnemonic.joined(separator: " ")
    }
    
    /// Converts mnemonic phrase to entropy
    /// - Parameter mnemonic: Mnemonic phrase
    /// - Returns: Entropy bytes
    /// - Throws: `SecurityError.mnemonicConversionFailed` if conversion fails
    private func mnemonicToEntropy(_ mnemonic: String) throws -> Data {
        // This is a simplified implementation
        // In a real implementation, you would use BIP39 standard
        
        let words = mnemonic.components(separatedBy: " ")
        var entropy = Data()
        
        for word in words {
            let hash = word.data(using: .utf8)!.sha256()
            entropy.append(hash.prefix(4))
        }
        
        return entropy.prefix(16)
    }
    
    /// Validates private key format
    /// - Parameter privateKey: Private key to validate
    /// - Throws: `SecurityError.invalidPrivateKey` if private key is invalid
    private func validatePrivateKey(_ privateKey: String) throws {
        guard privateKey.hasPrefix("0x") else {
            throw SecurityError.invalidPrivateKey
        }
        
        let hexString = String(privateKey.dropFirst(2))
        guard hexString.count == 64 else {
            throw SecurityError.invalidPrivateKey
        }
        
        guard hexString.range(of: "^[0-9A-Fa-f]+$", options: .regularExpression) != nil else {
            throw SecurityError.invalidPrivateKey
        }
    }
    
    /// Validates mnemonic phrase
    /// - Parameter mnemonic: Mnemonic phrase to validate
    /// - Throws: `SecurityError.invalidMnemonic` if mnemonic is invalid
    private func validateMnemonic(_ mnemonic: String) throws {
        let words = mnemonic.components(separatedBy: " ")
        
        guard words.count == 12 || words.count == 15 || words.count == 18 || words.count == 21 || words.count == 24 else {
            throw SecurityError.invalidMnemonic
        }
        
        // Validate against BIP39 word list (simplified)
        let validWords = Set([
            "abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse",
            "access", "accident", "account", "accuse", "achieve", "acid", "acoustic", "acquire", "across", "act"
        ])
        
        for word in words {
            guard validWords.contains(word.lowercased()) else {
                throw SecurityError.invalidMnemonic
            }
        }
    }
    
    /// Creates transaction data for signing
    /// - Parameter transaction: Transaction to create data for
    /// - Returns: Transaction data bytes
    /// - Throws: `SecurityError.dataCreationFailed` if data creation fails
    private func createTransactionData(for transaction: Transaction) throws -> Data {
        // This is a simplified implementation
        // In a real implementation, you would create proper RLP encoded data
        
        let dataString = "\(transaction.nonce)\(transaction.gasPrice ?? "0")\(transaction.gasLimit)\(transaction.to)\(transaction.value)\(transaction.data)"
        return dataString.data(using: .utf8)!
    }
    
    /// Signs data with private key
    /// - Parameters:
    ///   - data: Data to sign
    ///   - privateKey: Private key bytes
    /// - Returns: Transaction signature
    /// - Throws: `SecurityError.signingFailed` if signing fails
    private func signData(_ data: Data, with privateKey: Data) throws -> TransactionSignature {
        // This is a simplified implementation
        // In a real implementation, you would use proper ECDSA signing
        
        let hash = data.sha256()
        let signature = hash + privateKey.prefix(32)
        
        return TransactionSignature(
            r: signature.prefix(32).toHexString(),
            s: signature.dropFirst(32).prefix(32).toHexString(),
            v: 27
        )
    }
    
    /// Creates raw transaction from transaction and signature
    /// - Parameters:
    ///   - transaction: Original transaction
    ///   - signature: Transaction signature
    /// - Returns: Raw transaction hex string
    /// - Throws: `SecurityError.rawTransactionCreationFailed` if creation fails
    private func createRawTransaction(_ transaction: Transaction, signature: TransactionSignature) throws -> String {
        // This is a simplified implementation
        // In a real implementation, you would create proper RLP encoded transaction
        
        let rawTx = "\(transaction.nonce)\(transaction.gasPrice ?? "0")\(transaction.gasLimit)\(transaction.to)\(transaction.value)\(transaction.data)\(signature.r)\(signature.s)\(signature.v)"
        return "0x" + rawTx.data(using: .utf8)!.toHexString()
    }
    
    /// Encrypts data with password
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - password: Password for encryption
    /// - Returns: Encrypted data
    /// - Throws: `SecurityError.encryptionFailed` if encryption fails
    private func encryptData(_ data: Data, with password: String) throws -> Data {
        let key = password.data(using: .utf8)!.sha256()
        let iv = try generateSecureRandomBytes(count: 16)
        
        let cipher = try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes), padding: .pkcs7)
        let encrypted = try cipher.encrypt(data.bytes)
        
        return iv + Data(encrypted)
    }
    
    /// Decrypts data with password
    /// - Parameter encryptedData: Encrypted data
    /// - Returns: Decrypted data
    /// - Throws: `SecurityError.decryptionFailed` if decryption fails
    private func decryptData(_ encryptedData: Data) throws -> String {
        // This is a simplified implementation
        // In a real implementation, you would properly decrypt the data
        
        return String(data: encryptedData, encoding: .utf8) ?? ""
    }
}

// MARK: - Error Types

/// Security-related errors
public enum SecurityError: LocalizedError {
    case keyGenerationFailed
    case invalidPrivateKey
    case invalidPublicKey
    case invalidMnemonic
    case mnemonicGenerationFailed
    case mnemonicConversionFailed
    case signingFailed
    case storageFailed
    case retrievalFailed
    case deletionFailed
    case authenticationFailed
    case randomGenerationFailed
    case publicKeyGenerationFailed
    case dataCreationFailed
    case rawTransactionCreationFailed
    case encryptionFailed
    case decryptionFailed
    
    public var errorDescription: String? {
        switch self {
        case .keyGenerationFailed:
            return "Failed to generate private key"
        case .invalidPrivateKey:
            return "Invalid private key format"
        case .invalidPublicKey:
            return "Invalid public key format"
        case .invalidMnemonic:
            return "Invalid mnemonic phrase"
        case .mnemonicGenerationFailed:
            return "Failed to generate mnemonic phrase"
        case .mnemonicConversionFailed:
            return "Failed to convert mnemonic phrase"
        case .signingFailed:
            return "Failed to sign transaction"
        case .storageFailed:
            return "Failed to store private key"
        case .retrievalFailed:
            return "Failed to retrieve private key"
        case .deletionFailed:
            return "Failed to delete private key"
        case .authenticationFailed:
            return "Biometric authentication failed"
        case .randomGenerationFailed:
            return "Failed to generate random bytes"
        case .publicKeyGenerationFailed:
            return "Failed to generate public key"
        case .dataCreationFailed:
            return "Failed to create transaction data"
        case .rawTransactionCreationFailed:
            return "Failed to create raw transaction"
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        }
    }
} 