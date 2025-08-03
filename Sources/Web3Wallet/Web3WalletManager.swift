import Foundation
import CryptoSwift
import BigInt
import Logging

/// Main manager class for Web3 wallet operations
/// Provides comprehensive wallet creation, management, and transaction handling
@available(iOS 15.0, *)
public class Web3WalletManager: ObservableObject {
    
    // MARK: - Properties
    
    /// Logger for debugging and monitoring
    private let logger = Logger(label: "Web3WalletManager")
    
    /// Current active wallet
    @Published public private(set) var currentWallet: Wallet?
    
    /// Available networks configuration
    private var networks: [Blockchain: NetworkConfig] = [:]
    
    /// Security manager for key operations
    private let securityManager: SecurityManager
    
    /// Network manager for blockchain interactions
    private let networkManager: NetworkManager
    
    /// Storage manager for wallet persistence
    private let storageManager: StorageManager
    
    /// DeFi manager for protocol interactions
    private let defiManager: DeFiManager
    
    // MARK: - Initialization
    
    /// Initialize Web3WalletManager with default configuration
    public init() {
        self.securityManager = SecurityManager()
        self.networkManager = NetworkManager()
        self.storageManager = StorageManager()
        self.defiManager = DeFiManager()
        
        setupDefaultNetworks()
        loadSavedWallet()
    }
    
    /// Initialize with custom configuration
    /// - Parameter config: Custom configuration for the wallet manager
    public init(config: Web3WalletConfig) {
        self.securityManager = SecurityManager()
        self.networkManager = NetworkManager()
        self.storageManager = StorageManager()
        self.defiManager = DeFiManager()
        
        configureNetworks(config.networks)
        loadSavedWallet()
    }
    
    // MARK: - Wallet Management
    
    /// Creates a new wallet with the specified name and password
    /// - Parameters:
    ///   - name: The name for the wallet
    ///   - password: The password for wallet encryption
    /// - Returns: A new wallet instance
    /// - Throws: `WalletError.invalidName` if name is empty
    /// - Throws: `WalletError.weakPassword` if password is too weak
    public func createWallet(name: String, password: String) async throws -> Wallet {
        logger.info("Creating new wallet with name: \(name)")
        
        // Validate inputs
        try validateWalletName(name)
        try validatePassword(password)
        
        // Generate private key
        let privateKey = try await securityManager.generatePrivateKey()
        
        // Derive public key and address
        let publicKey = try securityManager.derivePublicKey(from: privateKey)
        let address = try securityManager.deriveAddress(from: publicKey)
        
        // Generate mnemonic phrase
        let mnemonic = try securityManager.generateMnemonic()
        
        // Create wallet instance
        let wallet = Wallet(
            id: UUID().uuidString,
            name: name,
            address: address,
            publicKey: publicKey,
            mnemonic: mnemonic,
            createdAt: Date(),
            isActive: true
        )
        
        // Encrypt and store private key
        try await securityManager.storePrivateKey(privateKey, for: wallet.id, password: password)
        
        // Save wallet metadata
        try await storageManager.saveWallet(wallet)
        
        // Set as current wallet
        await MainActor.run {
            self.currentWallet = wallet
        }
        
        logger.info("Wallet created successfully: \(wallet.id)")
        return wallet
    }
    
    /// Imports an existing wallet using private key
    /// - Parameters:
    ///   - privateKey: The private key in hex format
    ///   - name: The name for the imported wallet
    ///   - password: The password for wallet encryption
    /// - Returns: The imported wallet instance
    /// - Throws: `WalletError.invalidPrivateKey` if private key is invalid
    public func importWallet(privateKey: String, name: String, password: String) async throws -> Wallet {
        logger.info("Importing wallet with name: \(name)")
        
        // Validate inputs
        try validateWalletName(name)
        try validatePassword(password)
        try validatePrivateKey(privateKey)
        
        // Derive public key and address
        let publicKey = try securityManager.derivePublicKey(from: privateKey)
        let address = try securityManager.deriveAddress(from: publicKey)
        
        // Create wallet instance
        let wallet = Wallet(
            id: UUID().uuidString,
            name: name,
            address: address,
            publicKey: publicKey,
            mnemonic: nil, // Imported wallets don't have mnemonic
            createdAt: Date(),
            isActive: true
        )
        
        // Encrypt and store private key
        try await securityManager.storePrivateKey(privateKey, for: wallet.id, password: password)
        
        // Save wallet metadata
        try await storageManager.saveWallet(wallet)
        
        // Set as current wallet
        await MainActor.run {
            self.currentWallet = wallet
        }
        
        logger.info("Wallet imported successfully: \(wallet.id)")
        return wallet
    }
    
    /// Imports an existing wallet using mnemonic phrase
    /// - Parameters:
    ///   - mnemonic: The mnemonic phrase
    ///   - name: The name for the imported wallet
    ///   - password: The password for wallet encryption
    /// - Returns: The imported wallet instance
    /// - Throws: `WalletError.invalidMnemonic` if mnemonic is invalid
    public func importWallet(mnemonic: String, name: String, password: String) async throws -> Wallet {
        logger.info("Importing wallet with mnemonic, name: \(name)")
        
        // Validate inputs
        try validateWalletName(name)
        try validatePassword(password)
        try validateMnemonic(mnemonic)
        
        // Derive private key from mnemonic
        let privateKey = try securityManager.derivePrivateKey(from: mnemonic)
        
        // Derive public key and address
        let publicKey = try securityManager.derivePublicKey(from: privateKey)
        let address = try securityManager.deriveAddress(from: publicKey)
        
        // Create wallet instance
        let wallet = Wallet(
            id: UUID().uuidString,
            name: name,
            address: address,
            publicKey: publicKey,
            mnemonic: mnemonic,
            createdAt: Date(),
            isActive: true
        )
        
        // Encrypt and store private key
        try await securityManager.storePrivateKey(privateKey, for: wallet.id, password: password)
        
        // Save wallet metadata
        try await storageManager.saveWallet(wallet)
        
        // Set as current wallet
        await MainActor.run {
            self.currentWallet = wallet
        }
        
        logger.info("Wallet imported successfully: \(wallet.id)")
        return wallet
    }
    
    /// Switches to a different wallet
    /// - Parameter wallet: The wallet to switch to
    public func switchWallet(to wallet: Wallet) async throws {
        logger.info("Switching to wallet: \(wallet.id)")
        
        // Verify wallet exists
        guard let savedWallet = try await storageManager.getWallet(id: wallet.id) else {
            throw WalletError.walletNotFound
        }
        
        // Set as current wallet
        await MainActor.run {
            self.currentWallet = savedWallet
        }
        
        logger.info("Switched to wallet: \(wallet.id)")
    }
    
    /// Deletes a wallet and all associated data
    /// - Parameter wallet: The wallet to delete
    public func deleteWallet(_ wallet: Wallet) async throws {
        logger.info("Deleting wallet: \(wallet.id)")
        
        // Remove private key
        try await securityManager.deletePrivateKey(for: wallet.id)
        
        // Remove wallet metadata
        try await storageManager.deleteWallet(wallet)
        
        // Clear current wallet if it's the one being deleted
        if currentWallet?.id == wallet.id {
            await MainActor.run {
                self.currentWallet = nil
            }
        }
        
        logger.info("Wallet deleted successfully: \(wallet.id)")
    }
    
    // MARK: - Transaction Management
    
    /// Signs a transaction with the current wallet
    /// - Parameter transaction: The transaction to sign
    /// - Returns: The signed transaction
    /// - Throws: `WalletError.noActiveWallet` if no wallet is active
    public func signTransaction(_ transaction: Transaction) async throws -> SignedTransaction {
        guard let wallet = currentWallet else {
            throw WalletError.noActiveWallet
        }
        
        logger.info("Signing transaction for wallet: \(wallet.id)")
        
        // Get private key
        let privateKey = try await securityManager.getPrivateKey(for: wallet.id)
        
        // Sign transaction
        let signedTx = try securityManager.signTransaction(transaction, with: privateKey)
        
        logger.info("Transaction signed successfully")
        return signedTx
    }
    
    /// Sends a signed transaction to the network
    /// - Parameter signedTransaction: The signed transaction to send
    /// - Returns: The transaction hash
    /// - Throws: `NetworkError.transactionFailed` if transaction fails
    public func sendTransaction(_ signedTransaction: SignedTransaction) async throws -> String {
        logger.info("Sending transaction: \(signedTransaction.hash)")
        
        // Send transaction
        let txHash = try await networkManager.sendTransaction(signedTransaction)
        
        logger.info("Transaction sent successfully: \(txHash)")
        return txHash
    }
    
    /// Creates and sends a transaction
    /// - Parameter transaction: The transaction to create and send
    /// - Returns: The transaction hash
    public func createAndSendTransaction(_ transaction: Transaction) async throws -> String {
        let signedTx = try await signTransaction(transaction)
        return try await sendTransaction(signedTx)
    }
    
    // MARK: - Balance and Account Management
    
    /// Gets the balance for the current wallet on the specified chain
    /// - Parameter chain: The blockchain to check balance on
    /// - Returns: The balance as a string
    /// - Throws: `WalletError.noActiveWallet` if no wallet is active
    public func getBalance(on chain: Blockchain) async throws -> String {
        guard let wallet = currentWallet else {
            throw WalletError.noActiveWallet
        }
        
        logger.info("Getting balance for wallet: \(wallet.id) on chain: \(chain)")
        
        let balance = try await networkManager.getBalance(address: wallet.address, on: chain)
        
        logger.info("Balance retrieved: \(balance)")
        return balance
    }
    
    /// Gets transaction history for the current wallet
    /// - Parameter chain: The blockchain to get history from
    /// - Returns: Array of transactions
    public func getTransactionHistory(on chain: Blockchain) async throws -> [TransactionRecord] {
        guard let wallet = currentWallet else {
            throw WalletError.noActiveWallet
        }
        
        logger.info("Getting transaction history for wallet: \(wallet.id)")
        
        let history = try await networkManager.getTransactionHistory(address: wallet.address, on: chain)
        
        logger.info("Retrieved \(history.count) transactions")
        return history
    }
    
    // MARK: - Network Management
    
    /// Configures supported networks
    /// - Parameter networks: Dictionary of blockchain to network configuration
    public func configureNetworks(_ networks: [Blockchain: NetworkConfig]) {
        self.networks = networks
        networkManager.configureNetworks(networks)
        logger.info("Configured \(networks.count) networks")
    }
    
    /// Switches to a different blockchain network
    /// - Parameter chain: The blockchain to switch to
    public func switchChain(_ chain: Blockchain) async throws {
        guard networks[chain] != nil else {
            throw NetworkError.unsupportedChain
        }
        
        logger.info("Switching to chain: \(chain)")
        
        // Update network configuration
        try await networkManager.switchChain(chain)
        
        logger.info("Switched to chain: \(chain)")
    }
    
    // MARK: - DeFi Integration
    
    /// Gets available DeFi protocols for the current chain
    /// - Returns: Array of DeFi protocols
    public func getAvailableDeFiProtocols() async throws -> [DeFiProtocol] {
        guard let wallet = currentWallet else {
            throw WalletError.noActiveWallet
        }
        
        return try await defiManager.getAvailableProtocols()
    }
    
    /// Creates a swap transaction using DeFi protocols
    /// - Parameter swapRequest: The swap request details
    /// - Returns: The transaction to be signed and sent
    public func createSwapTransaction(_ swapRequest: SwapRequest) async throws -> Transaction {
        guard let wallet = currentWallet else {
            throw WalletError.noActiveWallet
        }
        
        logger.info("Creating swap transaction: \(swapRequest.fromToken) -> \(swapRequest.toToken)")
        
        let transaction = try await defiManager.createSwapTransaction(swapRequest, for: wallet)
        
        logger.info("Swap transaction created successfully")
        return transaction
    }
    
    // MARK: - Private Methods
    
    /// Sets up default supported networks
    private func setupDefaultNetworks() {
        let defaultNetworks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/YOUR_PROJECT_ID",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            ),
            .polygon: NetworkConfig(
                chainId: 137,
                rpcUrl: "https://polygon-rpc.com",
                explorerUrl: "https://polygonscan.com",
                name: "Polygon Mainnet"
            ),
            .bsc: NetworkConfig(
                chainId: 56,
                rpcUrl: "https://bsc-dataseed.binance.org",
                explorerUrl: "https://bscscan.com",
                name: "Binance Smart Chain"
            )
        ]
        
        configureNetworks(defaultNetworks)
    }
    
    /// Loads the last saved wallet
    private func loadSavedWallet() {
        Task {
            do {
                if let savedWallet = try await storageManager.getLastActiveWallet() {
                    await MainActor.run {
                        self.currentWallet = savedWallet
                    }
                    logger.info("Loaded saved wallet: \(savedWallet.id)")
                }
            } catch {
                logger.error("Failed to load saved wallet: \(error)")
            }
        }
    }
    
    /// Validates wallet name
    /// - Parameter name: The wallet name to validate
    /// - Throws: `WalletError.invalidName` if name is invalid
    private func validateWalletName(_ name: String) throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw WalletError.invalidName
        }
        
        guard name.count <= 50 else {
            throw WalletError.invalidName
        }
    }
    
    /// Validates password strength
    /// - Parameter password: The password to validate
    /// - Throws: `WalletError.weakPassword` if password is too weak
    private func validatePassword(_ password: String) throws {
        guard password.count >= 8 else {
            throw WalletError.weakPassword
        }
        
        // Check for at least one uppercase, lowercase, number, and special character
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecial = password.rangeOfCharacter(from: .punctuationCharacters) != nil
        
        guard hasUppercase && hasLowercase && hasNumber && hasSpecial else {
            throw WalletError.weakPassword
        }
    }
    
    /// Validates private key format
    /// - Parameter privateKey: The private key to validate
    /// - Throws: `WalletError.invalidPrivateKey` if private key is invalid
    private func validatePrivateKey(_ privateKey: String) throws {
        guard privateKey.hasPrefix("0x") else {
            throw WalletError.invalidPrivateKey
        }
        
        guard privateKey.count == 66 else { // 0x + 64 hex characters
            throw WalletError.invalidPrivateKey
        }
        
        // Validate hex format
        let hexString = String(privateKey.dropFirst(2))
        guard hexString.range(of: "^[0-9A-Fa-f]+$", options: .regularExpression) != nil else {
            throw WalletError.invalidPrivateKey
        }
    }
    
    /// Validates mnemonic phrase
    /// - Parameter mnemonic: The mnemonic phrase to validate
    /// - Throws: `WalletError.invalidMnemonic` if mnemonic is invalid
    private func validateMnemonic(_ mnemonic: String) throws {
        let words = mnemonic.components(separatedBy: " ")
        
        guard words.count == 12 || words.count == 15 || words.count == 18 || words.count == 21 || words.count == 24 else {
            throw WalletError.invalidMnemonic
        }
        
        // Validate against BIP39 word list
        let validWords = BIP39WordList.words
        for word in words {
            guard validWords.contains(word.lowercased()) else {
                throw WalletError.invalidMnemonic
            }
        }
    }
}

// MARK: - Error Types

/// Errors that can occur during wallet operations
public enum WalletError: LocalizedError {
    case invalidName
    case weakPassword
    case invalidPrivateKey
    case invalidMnemonic
    case walletNotFound
    case noActiveWallet
    case authenticationFailed
    case encryptionFailed
    case decryptionFailed
    
    public var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Invalid wallet name. Name must be between 1 and 50 characters."
        case .weakPassword:
            return "Password is too weak. Must be at least 8 characters with uppercase, lowercase, number, and special character."
        case .invalidPrivateKey:
            return "Invalid private key format. Must be 64 hex characters with 0x prefix."
        case .invalidMnemonic:
            return "Invalid mnemonic phrase. Must be 12, 15, 18, 21, or 24 valid BIP39 words."
        case .walletNotFound:
            return "Wallet not found."
        case .noActiveWallet:
            return "No active wallet. Please create or import a wallet first."
        case .authenticationFailed:
            return "Authentication failed. Please try again."
        case .encryptionFailed:
            return "Failed to encrypt wallet data."
        case .decryptionFailed:
            return "Failed to decrypt wallet data."
        }
    }
}

/// Errors that can occur during network operations
public enum NetworkError: LocalizedError {
    case unsupportedChain
    case connectionFailed
    case transactionFailed
    case invalidResponse
    case rateLimitExceeded
    
    public var errorDescription: String? {
        switch self {
        case .unsupportedChain:
            return "Unsupported blockchain network."
        case .connectionFailed:
            return "Network connection failed. Please check your internet connection."
        case .transactionFailed:
            return "Transaction failed. Please try again."
        case .invalidResponse:
            return "Invalid response from network."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please wait before trying again."
        }
    }
} 