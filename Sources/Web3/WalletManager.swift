//
//  WalletManager.swift
//  iOSWeb3WalletFramework
//
//  Created by Muhittin Camdali on 2023-06-15.
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import Foundation
import CryptoKit
import Security
import LocalAuthentication
import Combine

// MARK: - Wallet Manager Core

/// Comprehensive Web3 wallet manager with multi-chain support
@available(iOS 15.0, macOS 12.0, *)
public final class WalletManager: ObservableObject {
    
    // MARK: - Properties
    
    /// Shared instance for global wallet management
    public static let shared = WalletManager()
    
    /// Current wallet state
    @Published public private(set) var walletState = WalletState()
    
    /// Active wallet instance
    @Published public private(set) var currentWallet: Wallet?
    
    /// Network configuration
    @Published public private(set) var currentNetwork: BlockchainNetwork = .ethereum
    
    /// Transaction history
    @Published public private(set) var transactionHistory: [Transaction] = []
    
    /// Token balances
    @Published public private(set) var tokenBalances: [String: TokenBalance] = [:]
    
    /// Security manager for key management
    private let securityManager = SecurityManager()
    
    /// Network manager for blockchain communication
    private let networkManager = NetworkManager()
    
    /// Transaction manager for transaction handling
    private let transactionManager = TransactionManager()
    
    /// DeFi manager for protocol integrations
    private let defiManager = DeFiManager()
    
    /// Hardware wallet manager
    private let hardwareWalletManager = HardwareWalletManager()
    
    /// Biometric authentication manager
    private let biometricManager = BiometricManager()
    
    /// Wallet storage manager
    private let storageManager = WalletStorageManager()
    
    /// Performance monitoring
    private let performanceMonitor = PerformanceMonitor()
    
    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        setupObservers()
        setupPerformanceMonitoring()
        loadWalletFromStorage()
    }
    
    // MARK: - Public API
    
    /// Creates a new wallet with secure key generation
    /// - Parameters:
    ///   - password: User password for encryption
    ///   - mnemonic: Optional mnemonic phrase (generated if nil)
    ///   - completion: Completion handler with wallet creation result
    public func createWallet(
        password: String,
        mnemonic: String? = nil,
        completion: @escaping (Result<Wallet, WalletError>) -> Void
    ) {
        
        // Validate password strength
        guard validatePasswordStrength(password) else {
            completion(.failure(.weakPassword))
            return
        }
        
        // Generate or validate mnemonic
        let finalMnemonic: String
        if let providedMnemonic = mnemonic {
            guard validateMnemonic(providedMnemonic) else {
                completion(.failure(.invalidMnemonic))
                return
            }
            finalMnemonic = providedMnemonic
        } else {
            finalMnemonic = generateMnemonic()
        }
        
        // Generate wallet from mnemonic
        generateWalletFromMnemonic(finalMnemonic, password: password) { [weak self] result in
            switch result {
            case .success(let wallet):
                self?.currentWallet = wallet
                self?.walletState.isWalletCreated = true
                self?.walletState.isUnlocked = true
                self?.saveWalletToStorage(wallet)
                self?.setupWalletObservers(wallet)
                completion(.success(wallet))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Imports an existing wallet from private key
    /// - Parameters:
    ///   - privateKey: Private key in hex format
    ///   - password: Password for encryption
    ///   - completion: Completion handler with import result
    public func importWallet(
        privateKey: String,
        password: String,
        completion: @escaping (Result<Wallet, WalletError>) -> Void
    ) {
        
        // Validate private key format
        guard validatePrivateKey(privateKey) else {
            completion(.failure(.invalidPrivateKey))
            return
        }
        
        // Validate password strength
        guard validatePasswordStrength(password) else {
            completion(.failure(.weakPassword))
            return
        }
        
        // Import wallet from private key
        importWalletFromPrivateKey(privateKey, password: password) { [weak self] result in
            switch result {
            case .success(let wallet):
                self?.currentWallet = wallet
                self?.walletState.isWalletCreated = true
                self?.walletState.isUnlocked = true
                self?.saveWalletToStorage(wallet)
                self?.setupWalletObservers(wallet)
                completion(.success(wallet))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Unlocks wallet with password or biometric authentication
    /// - Parameters:
    ///   - useBiometrics: Whether to use biometric authentication
    ///   - completion: Completion handler with unlock result
    public func unlockWallet(
        useBiometrics: Bool = true,
        completion: @escaping (Result<Void, WalletError>) -> Void
    ) {
        
        guard let wallet = currentWallet else {
            completion(.failure(.walletNotCreated))
            return
        }
        
        if useBiometrics && biometricManager.isBiometricAvailable {
            unlockWithBiometrics { [weak self] result in
                switch result {
                case .success:
                    self?.walletState.isUnlocked = true
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            // Fallback to password unlock
            unlockWithPassword { [weak self] result in
                switch result {
                case .success:
                    self?.walletState.isUnlocked = true
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Locks the wallet for security
    public func lockWallet() {
        walletState.isUnlocked = false
        clearSensitiveData()
    }
    
    /// Switches to a different blockchain network
    /// - Parameters:
    ///   - network: Target blockchain network
    ///   - completion: Completion handler with network switch result
    public func switchNetwork(
        _ network: BlockchainNetwork,
        completion: @escaping (Result<Void, WalletError>) -> Void
    ) {
        
        guard walletState.isUnlocked else {
            completion(.failure(.walletLocked))
            return
        }
        
        networkManager.switchNetwork(network) { [weak self] result in
            switch result {
            case .success:
                self?.currentNetwork = network
                self?.refreshTokenBalances()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }
    
    /// Gets current wallet balance
    /// - Parameter completion: Completion handler with balance result
    public func getBalance(completion: @escaping (Result<Balance, WalletError>) -> Void) {
        
        guard let wallet = currentWallet, walletState.isUnlocked else {
            completion(.failure(.walletLocked))
            return
        }
        
        networkManager.getBalance(address: wallet.address, network: currentNetwork) { result in
            completion(result)
        }
    }
    
    /// Gets token balances for current wallet
    /// - Parameter completion: Completion handler with token balances
    public func getTokenBalances(completion: @escaping (Result<[TokenBalance], WalletError>) -> Void) {
        
        guard let wallet = currentWallet, walletState.isUnlocked else {
            completion(.failure(.walletLocked))
            return
        }
        
        networkManager.getTokenBalances(address: wallet.address, network: currentNetwork) { [weak self] result in
            switch result {
            case .success(let balances):
                self?.tokenBalances = Dictionary(uniqueKeysWithValues: balances.map { ($0.tokenAddress, $0) })
                completion(.success(balances))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }
    
    /// Sends a transaction
    /// - Parameters:
    ///   - transaction: Transaction to send
    ///   - completion: Completion handler with transaction result
    public func sendTransaction(
        _ transaction: Transaction,
        completion: @escaping (Result<String, WalletError>) -> Void
    ) {
        
        guard let wallet = currentWallet, walletState.isUnlocked else {
            completion(.failure(.walletLocked))
            return
        }
        
        // Validate transaction
        guard validateTransaction(transaction) else {
            completion(.failure(.invalidTransaction))
            return
        }
        
        // Sign and send transaction
        transactionManager.sendTransaction(transaction, wallet: wallet) { [weak self] result in
            switch result {
            case .success(let txHash):
                self?.addTransactionToHistory(transaction, hash: txHash)
                completion(.success(txHash))
            case .failure(let error):
                completion(.failure(.transactionError(error)))
            }
        }
    }
    
    /// Gets transaction history
    /// - Parameters:
    ///   - address: Wallet address
    ///   - limit: Maximum number of transactions to fetch
    ///   - completion: Completion handler with transaction history
    public func getTransactionHistory(
        address: String,
        limit: Int = 50,
        completion: @escaping (Result<[Transaction], WalletError>) -> Void
    ) {
        
        networkManager.getTransactionHistory(address: address, network: currentNetwork, limit: limit) { [weak self] result in
            switch result {
            case .success(let transactions):
                self?.transactionHistory = transactions
                completion(.success(transactions))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }
    
    /// Connects to hardware wallet
    /// - Parameters:
    ///   - walletType: Type of hardware wallet
    ///   - completion: Completion handler with connection result
    public func connectHardwareWallet(
        _ walletType: HardwareWalletType,
        completion: @escaping (Result<HardwareWallet, WalletError>) -> Void
    ) {
        
        hardwareWalletManager.connect(walletType) { result in
            completion(result)
        }
    }
    
    /// Estimates gas for transaction
    /// - Parameters:
    ///   - transaction: Transaction to estimate gas for
    ///   - completion: Completion handler with gas estimation
    public func estimateGas(
        _ transaction: Transaction,
        completion: @escaping (Result<GasEstimate, WalletError>) -> Void
    ) {
        
        networkManager.estimateGas(transaction: transaction, network: currentNetwork) { result in
            completion(result)
        }
    }
    
    /// Gets current gas prices
    /// - Parameter completion: Completion handler with gas prices
    public func getGasPrices(completion: @escaping (Result<GasPrices, WalletError>) -> Void) {
        
        networkManager.getGasPrices(network: currentNetwork) { result in
            completion(result)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        // Monitor wallet state changes
        $currentWallet
            .sink { [weak self] wallet in
                self?.handleWalletChange(wallet)
            }
            .store(in: &cancellables)
        
        // Monitor network changes
        $currentNetwork
            .sink { [weak self] network in
                self?.handleNetworkChange(network)
            }
            .store(in: &cancellables)
    }
    
    private func setupPerformanceMonitoring() {
        performanceMonitor.startMonitoring()
        
        // Monitor performance metrics
        performanceMonitor.performanceMetrics
            .sink { [weak self] metrics in
                self?.handlePerformanceMetrics(metrics)
            }
            .store(in: &cancellables)
    }
    
    private func loadWalletFromStorage() {
        storageManager.loadWallet { [weak self] result in
            switch result {
            case .success(let wallet):
                self?.currentWallet = wallet
                self?.walletState.isWalletCreated = true
                self?.setupWalletObservers(wallet)
            case .failure:
                // No wallet found, this is normal for new users
                break
            }
        }
    }
    
    private func setupWalletObservers(_ wallet: Wallet) {
        // Monitor wallet balance changes
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshWalletData()
            }
            .store(in: &cancellables)
    }
    
    private func generateWalletFromMnemonic(
        _ mnemonic: String,
        password: String,
        completion: @escaping (Result<Wallet, WalletError>) -> Void
    ) {
        
        // Generate seed from mnemonic
        guard let seed = generateSeed(from: mnemonic) else {
            completion(.failure(.seedGenerationFailed))
            return
        }
        
        // Generate private key from seed
        guard let privateKey = generatePrivateKey(from: seed) else {
            completion(.failure(.privateKeyGenerationFailed))
            return
        }
        
        // Generate public key and address
        guard let publicKey = generatePublicKey(from: privateKey) else {
            completion(.failure(.publicKeyGenerationFailed))
            return
        }
        
        guard let address = generateAddress(from: publicKey) else {
            completion(.failure(.addressGenerationFailed))
            return
        }
        
        // Create wallet instance
        let wallet = Wallet(
            address: address,
            privateKey: privateKey,
            publicKey: publicKey,
            mnemonic: mnemonic,
            network: currentNetwork
        )
        
        // Encrypt and store wallet
        securityManager.encryptWallet(wallet, password: password) { result in
            switch result {
            case .success(let encryptedWallet):
                completion(.success(encryptedWallet))
            case .failure(let error):
                completion(.failure(.encryptionFailed(error)))
            }
        }
    }
    
    private func importWalletFromPrivateKey(
        _ privateKey: String,
        password: String,
        completion: @escaping (Result<Wallet, WalletError>) -> Void
    ) {
        
        // Generate public key from private key
        guard let publicKey = generatePublicKey(from: privateKey) else {
            completion(.failure(.publicKeyGenerationFailed))
            return
        }
        
        // Generate address from public key
        guard let address = generateAddress(from: publicKey) else {
            completion(.failure(.addressGenerationFailed))
            return
        }
        
        // Create wallet instance
        let wallet = Wallet(
            address: address,
            privateKey: privateKey,
            publicKey: publicKey,
            mnemonic: nil,
            network: currentNetwork
        )
        
        // Encrypt and store wallet
        securityManager.encryptWallet(wallet, password: password) { result in
            switch result {
            case .success(let encryptedWallet):
                completion(.success(encryptedWallet))
            case .failure(let error):
                completion(.failure(.encryptionFailed(error)))
            }
        }
    }
    
    private func unlockWithBiometrics(completion: @escaping (Result<Void, WalletError>) -> Void) {
        biometricManager.authenticate { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(.biometricAuthenticationFailed(error)))
            }
        }
    }
    
    private func unlockWithPassword(completion: @escaping (Result<Void, WalletError>) -> Void) {
        // This would typically show a password prompt
        // For now, we'll assume the wallet is already unlocked
        completion(.success(()))
    }
    
    private func saveWalletToStorage(_ wallet: Wallet) {
        storageManager.saveWallet(wallet) { result in
            switch result {
            case .success:
                print("Wallet saved successfully")
            case .failure(let error):
                print("Failed to save wallet: \(error)")
            }
        }
    }
    
    private func refreshWalletData() {
        guard let wallet = currentWallet, walletState.isUnlocked else { return }
        
        // Refresh balance
        getBalance { _ in }
        
        // Refresh token balances
        getTokenBalances { _ in }
        
        // Refresh transaction history
        getTransactionHistory(address: wallet.address) { _ in }
    }
    
    private func handleWalletChange(_ wallet: Wallet?) {
        if let wallet = wallet {
            print("Wallet changed to: \(wallet.address)")
        } else {
            print("Wallet cleared")
        }
    }
    
    private func handleNetworkChange(_ network: BlockchainNetwork) {
        print("Network changed to: \(network.name)")
        refreshWalletData()
    }
    
    private func handlePerformanceMetrics(_ metrics: PerformanceMetrics) {
        // Handle performance monitoring
        if metrics.memoryUsage > 100 * 1024 * 1024 { // 100MB
            print("High memory usage detected: \(metrics.memoryUsage) bytes")
        }
    }
    
    private func clearSensitiveData() {
        // Clear sensitive data from memory
        currentWallet = nil
        tokenBalances.removeAll()
    }
    
    private func addTransactionToHistory(_ transaction: Transaction, hash: String) {
        var updatedTransaction = transaction
        updatedTransaction.hash = hash
        updatedTransaction.timestamp = Date()
        transactionHistory.insert(updatedTransaction, at: 0)
    }
    
    // MARK: - Validation Methods
    
    private func validatePasswordStrength(_ password: String) -> Bool {
        // Minimum 8 characters, at least one uppercase, one lowercase, one number
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d@$!%*?&]{8,}$"
        return password.range(of: passwordRegex, options: .regularExpression) != nil
    }
    
    private func validateMnemonic(_ mnemonic: String) -> Bool {
        // Validate BIP-39 mnemonic
        let words = mnemonic.components(separatedBy: " ")
        return words.count == 12 || words.count == 24
    }
    
    private func validatePrivateKey(_ privateKey: String) -> Bool {
        // Validate hex format and length
        let hexRegex = "^[0-9a-fA-F]{64}$"
        return privateKey.range(of: hexRegex, options: .regularExpression) != nil
    }
    
    private func validateTransaction(_ transaction: Transaction) -> Bool {
        // Validate transaction parameters
        guard !transaction.to.isEmpty else { return false }
        guard !transaction.value.isEmpty else { return false }
        guard transaction.gasLimit > 0 else { return false }
        return true
    }
    
    // MARK: - Cryptographic Methods
    
    private func generateMnemonic() -> String {
        // Generate BIP-39 mnemonic
        let wordCount = 12
        let entropy = Data((0..<16).map { _ in UInt8.random(in: 0...255) })
        return BIP39.generateMnemonic(entropy: entropy, wordCount: wordCount)
    }
    
    private func generateSeed(from mnemonic: String) -> Data? {
        return BIP39.generateSeed(mnemonic: mnemonic, passphrase: "")
    }
    
    private func generatePrivateKey(from seed: Data) -> String? {
        // Generate private key using BIP-44 derivation
        let derivationPath = "m/44'/60'/0'/0/0"
        return HDWallet.derivePrivateKey(seed: seed, path: derivationPath)
    }
    
    private func generatePublicKey(from privateKey: String) -> String? {
        // Generate public key from private key
        guard let privateKeyData = Data(hexString: privateKey) else { return nil }
        return CryptoKit.SECP256k1.generatePublicKey(from: privateKeyData)?.hexString
    }
    
    private func generateAddress(from publicKey: String) -> String? {
        // Generate Ethereum address from public key
        guard let publicKeyData = Data(hexString: publicKey) else { return nil }
        return EthereumAddress.generate(from: publicKeyData)
    }
}

// MARK: - Supporting Types

/// Wallet state management
@available(iOS 15.0, macOS 12.0, *)
public struct WalletState {
    public var isWalletCreated: Bool = false
    public var isUnlocked: Bool = false
    public var isHardwareWalletConnected: Bool = false
    public var lastUnlockTime: Date?
    public var failedUnlockAttempts: Int = 0
}

/// Wallet instance
@available(iOS 15.0, macOS 12.0, *)
public struct Wallet {
    public let address: String
    public let privateKey: String
    public let publicKey: String
    public let mnemonic: String?
    public let network: BlockchainNetwork
    public let createdAt: Date
    
    public init(
        address: String,
        privateKey: String,
        publicKey: String,
        mnemonic: String?,
        network: BlockchainNetwork
    ) {
        self.address = address
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.mnemonic = mnemonic
        self.network = network
        self.createdAt = Date()
    }
}

/// Blockchain network types
@available(iOS 15.0, macOS 12.0, *)
public enum BlockchainNetwork: String, CaseIterable {
    case ethereum = "ethereum"
    case polygon = "polygon"
    case binanceSmartChain = "bsc"
    case arbitrum = "arbitrum"
    case optimism = "optimism"
    
    public var name: String {
        switch self {
        case .ethereum: return "Ethereum"
        case .polygon: return "Polygon"
        case .binanceSmartChain: return "Binance Smart Chain"
        case .arbitrum: return "Arbitrum"
        case .optimism: return "Optimism"
        }
    }
    
    public var chainId: Int {
        switch self {
        case .ethereum: return 1
        case .polygon: return 137
        case .binanceSmartChain: return 56
        case .arbitrum: return 42161
        case .optimism: return 10
        }
    }
}

/// Wallet errors
@available(iOS 15.0, macOS 12.0, *)
public enum WalletError: Error, LocalizedError {
    case walletNotCreated
    case walletLocked
    case weakPassword
    case invalidMnemonic
    case invalidPrivateKey
    case seedGenerationFailed
    case privateKeyGenerationFailed
    case publicKeyGenerationFailed
    case addressGenerationFailed
    case encryptionFailed(Error)
    case decryptionFailed(Error)
    case biometricAuthenticationFailed(Error)
    case invalidTransaction
    case transactionError(Error)
    case networkError(Error)
    case hardwareWalletError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .walletNotCreated:
            return "Wallet has not been created"
        case .walletLocked:
            return "Wallet is locked"
        case .weakPassword:
            return "Password does not meet security requirements"
        case .invalidMnemonic:
            return "Invalid mnemonic phrase"
        case .invalidPrivateKey:
            return "Invalid private key format"
        case .seedGenerationFailed:
            return "Failed to generate seed from mnemonic"
        case .privateKeyGenerationFailed:
            return "Failed to generate private key"
        case .publicKeyGenerationFailed:
            return "Failed to generate public key"
        case .addressGenerationFailed:
            return "Failed to generate address"
        case .encryptionFailed(let error):
            return "Encryption failed: \(error.localizedDescription)"
        case .decryptionFailed(let error):
            return "Decryption failed: \(error.localizedDescription)"
        case .biometricAuthenticationFailed(let error):
            return "Biometric authentication failed: \(error.localizedDescription)"
        case .invalidTransaction:
            return "Invalid transaction parameters"
        case .transactionError(let error):
            return "Transaction failed: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .hardwareWalletError(let error):
            return "Hardware wallet error: \(error.localizedDescription)"
        }
    }
} 