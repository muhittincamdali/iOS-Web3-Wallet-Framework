import Foundation
import Logging

/// Manages storage and persistence of wallet data
@available(iOS 15.0, *)
public class StorageManager {
    
    // MARK: - Properties
    
    /// UserDefaults for simple data storage
    private let userDefaults = UserDefaults.standard
    
    /// FileManager for file-based storage
    private let fileManager = FileManager.default
    
    /// Logger for storage operations
    private let logger = Logger(label: "StorageManager")
    
    /// Documents directory for file storage
    private var documentsDirectory: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// Wallets directory
    private var walletsDirectory: URL {
        return documentsDirectory.appendingPathComponent("Wallets")
    }
    
    /// Transactions directory
    private var transactionsDirectory: URL {
        return documentsDirectory.appendingPathComponent("Transactions")
    }
    
    /// Settings directory
    private var settingsDirectory: URL {
        return documentsDirectory.appendingPathComponent("Settings")
    }
    
    // MARK: - Initialization
    
    /// Initialize StorageManager
    public init() {
        setupDirectories()
    }
    
    // MARK: - Wallet Storage
    
    /// Saves wallet to storage
    /// - Parameter wallet: Wallet to save
    /// - Throws: `StorageError.saveFailed` if save fails
    public func saveWallet(_ wallet: Wallet) async throws {
        logger.info("Saving wallet: \(wallet.id)")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(wallet)
            let fileURL = walletsDirectory.appendingPathComponent("\(wallet.id).json")
            
            try data.write(to: fileURL)
            
            // Update last active wallet
            userDefaults.set(wallet.id, forKey: "lastActiveWalletId")
            
            logger.info("Wallet saved successfully")
        } catch {
            logger.error("Failed to save wallet: \(error)")
            throw StorageError.saveFailed
        }
    }
    
    /// Gets wallet by ID
    /// - Parameter id: Wallet ID
    /// - Returns: Wallet if found
    /// - Throws: `StorageError.loadFailed` if load fails
    public func getWallet(id: String) async throws -> Wallet? {
        logger.info("Loading wallet: \(id)")
        
        do {
            let fileURL = walletsDirectory.appendingPathComponent("\(id).json")
            
            guard fileManager.fileExists(atPath: fileURL.path) else {
                logger.info("Wallet file not found: \(id)")
                return nil
            }
            
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let wallet = try decoder.decode(Wallet.self, from: data)
            
            logger.info("Wallet loaded successfully")
            return wallet
        } catch {
            logger.error("Failed to load wallet: \(error)")
            throw StorageError.loadFailed
        }
    }
    
    /// Gets all saved wallets
    /// - Returns: Array of wallets
    /// - Throws: `StorageError.loadFailed` if load fails
    public func getAllWallets() async throws -> [Wallet] {
        logger.info("Loading all wallets")
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: walletsDirectory, includingPropertiesForKeys: nil)
            let jsonFiles = fileURLs.filter { $0.pathExtension == "json" }
            
            var wallets: [Wallet] = []
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            for fileURL in jsonFiles {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let wallet = try decoder.decode(Wallet.self, from: data)
                    wallets.append(wallet)
                } catch {
                    logger.warning("Failed to load wallet from file: \(fileURL.lastPathComponent)")
                }
            }
            
            logger.info("Loaded \(wallets.count) wallets")
            return wallets
        } catch {
            logger.error("Failed to load wallets: \(error)")
            throw StorageError.loadFailed
        }
    }
    
    /// Gets the last active wallet
    /// - Returns: Last active wallet if found
    /// - Throws: `StorageError.loadFailed` if load fails
    public func getLastActiveWallet() async throws -> Wallet? {
        guard let walletId = userDefaults.string(forKey: "lastActiveWalletId") else {
            return nil
        }
        
        return try await getWallet(id: walletId)
    }
    
    /// Deletes wallet from storage
    /// - Parameter wallet: Wallet to delete
    /// - Throws: `StorageError.deleteFailed` if deletion fails
    public func deleteWallet(_ wallet: Wallet) async throws {
        logger.info("Deleting wallet: \(wallet.id)")
        
        do {
            let fileURL = walletsDirectory.appendingPathComponent("\(wallet.id).json")
            
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
            }
            
            // Clear last active wallet if it's the one being deleted
            if userDefaults.string(forKey: "lastActiveWalletId") == wallet.id {
                userDefaults.removeObject(forKey: "lastActiveWalletId")
            }
            
            logger.info("Wallet deleted successfully")
        } catch {
            logger.error("Failed to delete wallet: \(error)")
            throw StorageError.deleteFailed
        }
    }
    
    // MARK: - Transaction Storage
    
    /// Saves transaction to storage
    /// - Parameter transaction: Transaction to save
    /// - Throws: `StorageError.saveFailed` if save fails
    public func saveTransaction(_ transaction: Transaction) async throws {
        logger.info("Saving transaction: \(transaction.id)")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(transaction)
            let fileURL = transactionsDirectory.appendingPathComponent("\(transaction.id).json")
            
            try data.write(to: fileURL)
            
            logger.info("Transaction saved successfully")
        } catch {
            logger.error("Failed to save transaction: \(error)")
            throw StorageError.saveFailed
        }
    }
    
    /// Gets transaction by ID
    /// - Parameter id: Transaction ID
    /// - Returns: Transaction if found
    /// - Throws: `StorageError.loadFailed` if load fails
    public func getTransaction(id: String) async throws -> Transaction? {
        logger.info("Loading transaction: \(id)")
        
        do {
            let fileURL = transactionsDirectory.appendingPathComponent("\(id).json")
            
            guard fileManager.fileExists(atPath: fileURL.path) else {
                logger.info("Transaction file not found: \(id)")
                return nil
            }
            
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let transaction = try decoder.decode(Transaction.self, from: data)
            
            logger.info("Transaction loaded successfully")
            return transaction
        } catch {
            logger.error("Failed to load transaction: \(error)")
            throw StorageError.loadFailed
        }
    }
    
    /// Gets all transactions for a wallet
    /// - Parameter walletId: Wallet ID
    /// - Returns: Array of transactions
    /// - Throws: `StorageError.loadFailed` if load fails
    public func getTransactions(for walletId: String) async throws -> [Transaction] {
        logger.info("Loading transactions for wallet: \(walletId)")
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: transactionsDirectory, includingPropertiesForKeys: nil)
            let jsonFiles = fileURLs.filter { $0.pathExtension == "json" }
            
            var transactions: [Transaction] = []
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            for fileURL in jsonFiles {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let transaction = try decoder.decode(Transaction.self, from: data)
                    
                    if transaction.from == walletId {
                        transactions.append(transaction)
                    }
                } catch {
                    logger.warning("Failed to load transaction from file: \(fileURL.lastPathComponent)")
                }
            }
            
            // Sort by creation date (newest first)
            transactions.sort { $0.createdAt > $1.createdAt }
            
            logger.info("Loaded \(transactions.count) transactions")
            return transactions
        } catch {
            logger.error("Failed to load transactions: \(error)")
            throw StorageError.loadFailed
        }
    }
    
    /// Deletes transaction from storage
    /// - Parameter transaction: Transaction to delete
    /// - Throws: `StorageError.deleteFailed` if deletion fails
    public func deleteTransaction(_ transaction: Transaction) async throws {
        logger.info("Deleting transaction: \(transaction.id)")
        
        do {
            let fileURL = transactionsDirectory.appendingPathComponent("\(transaction.id).json")
            
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
            }
            
            logger.info("Transaction deleted successfully")
        } catch {
            logger.error("Failed to delete transaction: \(error)")
            throw StorageError.deleteFailed
        }
    }
    
    // MARK: - Settings Storage
    
    /// Saves settings to storage
    /// - Parameter settings: Settings to save
    /// - Throws: `StorageError.saveFailed` if save fails
    public func saveSettings(_ settings: WalletSettings) async throws {
        logger.info("Saving settings")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(settings)
            let fileURL = settingsDirectory.appendingPathComponent("settings.json")
            
            try data.write(to: fileURL)
            
            logger.info("Settings saved successfully")
        } catch {
            logger.error("Failed to save settings: \(error)")
            throw StorageError.saveFailed
        }
    }
    
    /// Gets settings from storage
    /// - Returns: Settings if found, default settings otherwise
    /// - Throws: `StorageError.loadFailed` if load fails
    public func getSettings() async throws -> WalletSettings {
        logger.info("Loading settings")
        
        do {
            let fileURL = settingsDirectory.appendingPathComponent("settings.json")
            
            guard fileManager.fileExists(atPath: fileURL.path) else {
                logger.info("Settings file not found, using defaults")
                return WalletSettings()
            }
            
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let settings = try decoder.decode(WalletSettings.self, from: data)
            
            logger.info("Settings loaded successfully")
            return settings
        } catch {
            logger.error("Failed to load settings: \(error)")
            throw StorageError.loadFailed
        }
    }
    
    // MARK: - Cache Management
    
    /// Clears all cached data
    /// - Throws: `StorageError.clearFailed` if clearing fails
    public func clearCache() async throws {
        logger.info("Clearing cache")
        
        do {
            // Clear transaction cache
            let transactionFiles = try fileManager.contentsOfDirectory(at: transactionsDirectory, includingPropertiesForKeys: nil)
            for file in transactionFiles {
                try fileManager.removeItem(at: file)
            }
            
            logger.info("Cache cleared successfully")
        } catch {
            logger.error("Failed to clear cache: \(error)")
            throw StorageError.clearFailed
        }
    }
    
    /// Gets storage statistics
    /// - Returns: Storage statistics
    public func getStorageStatistics() async throws -> StorageStatistics {
        logger.info("Getting storage statistics")
        
        do {
            let walletFiles = try fileManager.contentsOfDirectory(at: walletsDirectory, includingPropertiesForKeys: nil)
            let transactionFiles = try fileManager.contentsOfDirectory(at: transactionsDirectory, includingPropertiesForKeys: nil)
            
            let walletCount = walletFiles.filter { $0.pathExtension == "json" }.count
            let transactionCount = transactionFiles.filter { $0.pathExtension == "json" }.count
            
            let statistics = StorageStatistics(
                walletCount: walletCount,
                transactionCount: transactionCount,
                totalSize: try calculateTotalSize()
            )
            
            logger.info("Storage statistics retrieved")
            return statistics
        } catch {
            logger.error("Failed to get storage statistics: \(error)")
            throw StorageError.loadFailed
        }
    }
    
    // MARK: - Private Methods
    
    /// Sets up required directories
    private func setupDirectories() {
        do {
            try fileManager.createDirectory(at: walletsDirectory, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: transactionsDirectory, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: settingsDirectory, withIntermediateDirectories: true)
            
            logger.info("Storage directories created successfully")
        } catch {
            logger.error("Failed to create storage directories: \(error)")
        }
    }
    
    /// Calculates total storage size
    /// - Returns: Total size in bytes
    /// - Throws: `StorageError.loadFailed` if calculation fails
    private func calculateTotalSize() throws -> Int64 {
        var totalSize: Int64 = 0
        
        // Calculate wallets directory size
        let walletFiles = try fileManager.contentsOfDirectory(at: walletsDirectory, includingPropertiesForKeys: [.fileSizeKey])
        for file in walletFiles {
            if let size = try file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(size)
            }
        }
        
        // Calculate transactions directory size
        let transactionFiles = try fileManager.contentsOfDirectory(at: transactionsDirectory, includingPropertiesForKeys: [.fileSizeKey])
        for file in transactionFiles {
            if let size = try file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(size)
            }
        }
        
        // Calculate settings directory size
        let settingsFiles = try fileManager.contentsOfDirectory(at: settingsDirectory, includingPropertiesForKeys: [.fileSizeKey])
        for file in settingsFiles {
            if let size = try file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(size)
            }
        }
        
        return totalSize
    }
}

// MARK: - Supporting Types

/// Wallet settings
public struct WalletSettings: Codable, Equatable {
    public var defaultNetwork: Blockchain
    public var gasPriceStrategy: GasPriceStrategy
    public var slippageTolerance: Double
    public var enableBiometrics: Bool
    public var enableNotifications: Bool
    public var autoBackup: Bool
    public var theme: AppTheme
    public var language: String
    
    public init(
        defaultNetwork: Blockchain = .ethereum,
        gasPriceStrategy: GasPriceStrategy = .medium,
        slippageTolerance: Double = 0.5,
        enableBiometrics: Bool = true,
        enableNotifications: Bool = true,
        autoBackup: Bool = false,
        theme: AppTheme = .system,
        language: String = "en"
    ) {
        self.defaultNetwork = defaultNetwork
        self.gasPriceStrategy = gasPriceStrategy
        self.slippageTolerance = slippageTolerance
        self.enableBiometrics = enableBiometrics
        self.enableNotifications = enableNotifications
        self.autoBackup = autoBackup
        self.theme = theme
        self.language = language
    }
}

/// Gas price strategy
public enum GasPriceStrategy: String, Codable, CaseIterable {
    case slow = "Slow"
    case medium = "Medium"
    case fast = "Fast"
    case custom = "Custom"
    
    public var displayName: String {
        switch self {
        case .slow:
            return "Slow (Cheaper)"
        case .medium:
            return "Medium (Balanced)"
        case .fast:
            return "Fast (Expensive)"
        case .custom:
            return "Custom"
        }
    }
}

/// App theme
public enum AppTheme: String, Codable, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    public var displayName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        }
    }
}

/// Storage statistics
public struct StorageStatistics: Codable, Equatable {
    public let walletCount: Int
    public let transactionCount: Int
    public let totalSize: Int64
    
    public init(walletCount: Int, transactionCount: Int, totalSize: Int64) {
        self.walletCount = walletCount
        self.transactionCount = transactionCount
        self.totalSize = totalSize
    }
    
    public var totalSizeInMB: Double {
        return Double(totalSize) / (1024 * 1024)
    }
}

// MARK: - Error Types

/// Storage-related errors
public enum StorageError: LocalizedError {
    case saveFailed
    case loadFailed
    case deleteFailed
    case clearFailed
    case invalidData
    case insufficientSpace
    
    public var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save data"
        case .loadFailed:
            return "Failed to load data"
        case .deleteFailed:
            return "Failed to delete data"
        case .clearFailed:
            return "Failed to clear cache"
        case .invalidData:
            return "Invalid data format"
        case .insufficientSpace:
            return "Insufficient storage space"
        }
    }
} 