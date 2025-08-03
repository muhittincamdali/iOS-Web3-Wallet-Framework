import Foundation
import Alamofire
import Logging

/// Manages all network interactions with blockchain networks
@available(iOS 15.0, *)
public class NetworkManager {
    
    // MARK: - Properties
    
    /// Alamofire session for network requests
    private let session: Session
    
    /// Current network configuration
    private var networks: [Blockchain: NetworkConfig] = [:]
    
    /// Current active network
    private var currentNetwork: Blockchain = .ethereum
    
    /// Logger for network events
    private let logger = Logger(label: "NetworkManager")
    
    /// Request timeout in seconds
    private let timeout: TimeInterval = 30.0
    
    /// Rate limiting configuration
    private var rateLimiter: RateLimiter
    
    // MARK: - Initialization
    
    /// Initialize NetworkManager
    public init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        
        self.session = Session(configuration: configuration)
        self.rateLimiter = RateLimiter(maxRequests: 100, timeWindow: 60)
    }
    
    // MARK: - Network Configuration
    
    /// Configures supported networks
    /// - Parameter networks: Dictionary of blockchain to network configuration
    public func configureNetworks(_ networks: [Blockchain: NetworkConfig]) {
        self.networks = networks
        logger.info("Configured \(networks.count) networks")
    }
    
    /// Switches to a different blockchain network
    /// - Parameter chain: The blockchain to switch to
    /// - Throws: `NetworkError.unsupportedChain` if chain is not supported
    public func switchChain(_ chain: Blockchain) async throws {
        guard networks[chain] != nil else {
            throw NetworkError.unsupportedChain
        }
        
        logger.info("Switching to chain: \(chain)")
        currentNetwork = chain
    }
    
    /// Gets the current active network
    /// - Returns: Current blockchain network
    public func getCurrentNetwork() -> Blockchain {
        return currentNetwork
    }
    
    /// Gets network configuration for a specific chain
    /// - Parameter chain: Blockchain chain
    /// - Returns: Network configuration
    /// - Throws: `NetworkError.unsupportedChain` if chain is not supported
    public func getNetworkConfig(for chain: Blockchain) throws -> NetworkConfig {
        guard let config = networks[chain] else {
            throw NetworkError.unsupportedChain
        }
        return config
    }
    
    // MARK: - Balance Operations
    
    /// Gets balance for an address on the current network
    /// - Parameters:
    ///   - address: Address to get balance for
    ///   - chain: Blockchain network (optional, uses current if not specified)
    /// - Returns: Balance as string in wei
    /// - Throws: `NetworkError.connectionFailed` if connection fails
    public func getBalance(address: String, on chain: Blockchain? = nil) async throws -> String {
        let targetChain = chain ?? currentNetwork
        let config = try getNetworkConfig(for: targetChain)
        
        logger.info("Getting balance for address: \(address) on chain: \(targetChain)")
        
        // Check rate limiting
        try await rateLimiter.checkRateLimit()
        
        let parameters: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_getBalance",
            "params": [address, "latest"],
            "id": 1
        ]
        
        let response: RPCResponse<String> = try await performRPCRequest(
            url: config.rpcUrl,
            parameters: parameters
        )
        
        guard let balance = response.result else {
            throw NetworkError.invalidResponse
        }
        
        logger.info("Balance retrieved: \(balance)")
        return balance
    }
    
    // MARK: - Transaction Operations
    
    /// Sends a signed transaction to the network
    /// - Parameter signedTransaction: The signed transaction to send
    /// - Returns: Transaction hash
    /// - Throws: `NetworkError.transactionFailed` if transaction fails
    public func sendTransaction(_ signedTransaction: SignedTransaction) async throws -> String {
        let config = try getNetworkConfig(for: currentNetwork)
        
        logger.info("Sending transaction: \(signedTransaction.hash)")
        
        // Check rate limiting
        try await rateLimiter.checkRateLimit()
        
        let parameters: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_sendRawTransaction",
            "params": [signedTransaction.rawTransaction],
            "id": 1
        ]
        
        let response: RPCResponse<String> = try await performRPCRequest(
            url: config.rpcUrl,
            parameters: parameters
        )
        
        guard let txHash = response.result else {
            if let error = response.error {
                logger.error("Transaction failed: \(error)")
                throw NetworkError.transactionFailed
            }
            throw NetworkError.invalidResponse
        }
        
        logger.info("Transaction sent successfully: \(txHash)")
        return txHash
    }
    
    /// Gets transaction receipt
    /// - Parameter txHash: Transaction hash
    /// - Returns: Transaction receipt
    /// - Throws: `NetworkError.connectionFailed` if connection fails
    public func getTransactionReceipt(_ txHash: String) async throws -> TransactionReceipt {
        let config = try getNetworkConfig(for: currentNetwork)
        
        logger.info("Getting transaction receipt: \(txHash)")
        
        // Check rate limiting
        try await rateLimiter.checkRateLimit()
        
        let parameters: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_getTransactionReceipt",
            "params": [txHash],
            "id": 1
        ]
        
        let response: RPCResponse<TransactionReceipt> = try await performRPCRequest(
            url: config.rpcUrl,
            parameters: parameters
        )
        
        guard let receipt = response.result else {
            throw NetworkError.invalidResponse
        }
        
        logger.info("Transaction receipt retrieved")
        return receipt
    }
    
    /// Gets transaction by hash
    /// - Parameter txHash: Transaction hash
    /// - Returns: Transaction details
    /// - Throws: `NetworkError.connectionFailed` if connection fails
    public func getTransaction(_ txHash: String) async throws -> TransactionDetails {
        let config = try getNetworkConfig(for: currentNetwork)
        
        logger.info("Getting transaction: \(txHash)")
        
        // Check rate limiting
        try await rateLimiter.checkRateLimit()
        
        let parameters: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_getTransactionByHash",
            "params": [txHash],
            "id": 1
        ]
        
        let response: RPCResponse<TransactionDetails> = try await performRPCRequest(
            url: config.rpcUrl,
            parameters: parameters
        )
        
        guard let transaction = response.result else {
            throw NetworkError.invalidResponse
        }
        
        logger.info("Transaction details retrieved")
        return transaction
    }
    
    // MARK: - Gas Operations
    
    /// Estimates gas for a transaction
    /// - Parameter transaction: Transaction to estimate gas for
    /// - Returns: Estimated gas limit
    /// - Throws: `NetworkError.connectionFailed` if connection fails
    public func estimateGas(for transaction: Transaction) async throws -> UInt64 {
        let config = try getNetworkConfig(for: currentNetwork)
        
        logger.info("Estimating gas for transaction")
        
        // Check rate limiting
        try await rateLimiter.checkRateLimit()
        
        let parameters: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_estimateGas",
            "params": [[
                "from": transaction.from,
                "to": transaction.to,
                "value": transaction.value,
                "data": transaction.data
            ]],
            "id": 1
        ]
        
        let response: RPCResponse<String> = try await performRPCRequest(
            url: config.rpcUrl,
            parameters: parameters
        )
        
        guard let gasHex = response.result,
              let gas = UInt64(gasHex.dropFirst(2), radix: 16) else {
            throw NetworkError.invalidResponse
        }
        
        logger.info("Gas estimated: \(gas)")
        return gas
    }
    
    /// Gets current gas price
    /// - Returns: Gas price in wei
    /// - Throws: `NetworkError.connectionFailed` if connection fails
    public func getGasPrice() async throws -> String {
        let config = try getNetworkConfig(for: currentNetwork)
        
        logger.info("Getting current gas price")
        
        // Check rate limiting
        try await rateLimiter.checkRateLimit()
        
        let parameters: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_gasPrice",
            "params": [],
            "id": 1
        ]
        
        let response: RPCResponse<String> = try await performRPCRequest(
            url: config.rpcUrl,
            parameters: parameters
        )
        
        guard let gasPrice = response.result else {
            throw NetworkError.invalidResponse
        }
        
        logger.info("Gas price retrieved: \(gasPrice)")
        return gasPrice
    }
    
    /// Gets fee history for EIP-1559 transactions
    /// - Parameter blockCount: Number of blocks to look back
    /// - Returns: Fee history
    /// - Throws: `NetworkError.connectionFailed` if connection fails
    public func getFeeHistory(blockCount: UInt64 = 20) async throws -> FeeHistory {
        let config = try getNetworkConfig(for: currentNetwork)
        
        logger.info("Getting fee history")
        
        // Check rate limiting
        try await rateLimiter.checkRateLimit()
        
        let parameters: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_feeHistory",
            "params": [
                String(format: "0x%x", blockCount),
                "latest",
                [25, 75]
            ],
            "id": 1
        ]
        
        let response: RPCResponse<FeeHistory> = try await performRPCRequest(
            url: config.rpcUrl,
            parameters: parameters
        )
        
        guard let feeHistory = response.result else {
            throw NetworkError.invalidResponse
        }
        
        logger.info("Fee history retrieved")
        return feeHistory
    }
    
    // MARK: - Block Operations
    
    /// Gets current block number
    /// - Returns: Current block number
    /// - Throws: `NetworkError.connectionFailed` if connection fails
    public func getBlockNumber() async throws -> UInt64 {
        let config = try getNetworkConfig(for: currentNetwork)
        
        logger.info("Getting current block number")
        
        // Check rate limiting
        try await rateLimiter.checkRateLimit()
        
        let parameters: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_blockNumber",
            "params": [],
            "id": 1
        ]
        
        let response: RPCResponse<String> = try await performRPCRequest(
            url: config.rpcUrl,
            parameters: parameters
        )
        
        guard let blockNumberHex = response.result,
              let blockNumber = UInt64(blockNumberHex.dropFirst(2), radix: 16) else {
            throw NetworkError.invalidResponse
        }
        
        logger.info("Block number retrieved: \(blockNumber)")
        return blockNumber
    }
    
    /// Gets block by number
    /// - Parameter blockNumber: Block number
    /// - Returns: Block details
    /// - Throws: `NetworkError.connectionFailed` if connection fails
    public func getBlock(byNumber blockNumber: UInt64) async throws -> BlockDetails {
        let config = try getNetworkConfig(for: currentNetwork)
        
        logger.info("Getting block: \(blockNumber)")
        
        // Check rate limiting
        try await rateLimiter.checkRateLimit()
        
        let parameters: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_getBlockByNumber",
            "params": [String(format: "0x%x", blockNumber), false],
            "id": 1
        ]
        
        let response: RPCResponse<BlockDetails> = try await performRPCRequest(
            url: config.rpcUrl,
            parameters: parameters
        )
        
        guard let block = response.result else {
            throw NetworkError.invalidResponse
        }
        
        logger.info("Block details retrieved")
        return block
    }
    
    // MARK: - Transaction History
    
    /// Gets transaction history for an address
    /// - Parameters:
    ///   - address: Address to get history for
    ///   - chain: Blockchain network (optional, uses current if not specified)
    /// - Returns: Array of transaction records
    /// - Throws: `NetworkError.connectionFailed` if connection fails
    public func getTransactionHistory(address: String, on chain: Blockchain? = nil) async throws -> [TransactionRecord] {
        let targetChain = chain ?? currentNetwork
        let config = try getNetworkConfig(for: targetChain)
        
        logger.info("Getting transaction history for address: \(address)")
        
        // Check rate limiting
        try await rateLimiter.checkRateLimit()
        
        // This is a simplified implementation
        // In a real implementation, you would use an API that provides transaction history
        // like Etherscan API, or implement pagination for large histories
        
        let parameters: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_getLogs",
            "params": [[
                "address": address,
                "fromBlock": "0x0",
                "toBlock": "latest"
            ]],
            "id": 1
        ]
        
        let response: RPCResponse<[TransactionLog]> = try await performRPCRequest(
            url: config.rpcUrl,
            parameters: parameters
        )
        
        guard let logs = response.result else {
            throw NetworkError.invalidResponse
        }
        
        // Convert logs to transaction records
        let records = logs.map { log in
            TransactionRecord(
                hash: log.transactionHash,
                from: "", // Would need to get from transaction details
                to: log.address,
                value: "0",
                gasUsed: 0,
                gasPrice: "0",
                blockNumber: log.blockNumber,
                timestamp: Date(),
                status: .confirmed
            )
        }
        
        logger.info("Retrieved \(records.count) transaction records")
        return records
    }
    
    // MARK: - Private Methods
    
    /// Performs RPC request to blockchain network
    /// - Parameters:
    ///   - url: RPC endpoint URL
    ///   - parameters: RPC parameters
    /// - Returns: RPC response
    /// - Throws: `NetworkError.connectionFailed` if connection fails
    private func performRPCRequest<T: Codable>(url: String, parameters: [String: Any]) async throws -> RPCResponse<T> {
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                url,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: ["Content-Type": "application/json"]
            )
            .validate()
            .responseDecodable(of: RPCResponse<T>.self) { response in
                switch response.result {
                case .success(let rpcResponse):
                    continuation.resume(returning: rpcResponse)
                case .failure(let error):
                    self.logger.error("RPC request failed: \(error)")
                    continuation.resume(throwing: NetworkError.connectionFailed)
                }
            }
        }
    }
}

// MARK: - Supporting Types

/// Network configuration for blockchain networks
public struct NetworkConfig: Codable, Equatable {
    public let chainId: Int
    public let rpcUrl: String
    public let explorerUrl: String
    public let name: String
    
    public init(chainId: Int, rpcUrl: String, explorerUrl: String, name: String) {
        self.chainId = chainId
        self.rpcUrl = rpcUrl
        self.explorerUrl = explorerUrl
        self.name = name
    }
}

/// RPC response wrapper
public struct RPCResponse<T: Codable>: Codable {
    public let jsonrpc: String
    public let id: Int
    public let result: T?
    public let error: RPCError?
}

/// RPC error
public struct RPCError: Codable {
    public let code: Int
    public let message: String
}

/// Transaction details from network
public struct TransactionDetails: Codable, Equatable {
    public let hash: String
    public let nonce: String
    public let blockHash: String?
    public let blockNumber: String?
    public let transactionIndex: String?
    public let from: String
    public let to: String?
    public let value: String
    public let gas: String
    public let gasPrice: String
    public let input: String
    public let v: String
    public let r: String
    public let s: String
}

/// Block details from network
public struct BlockDetails: Codable, Equatable {
    public let number: String
    public let hash: String
    public let parentHash: String
    public let nonce: String
    public let sha3Uncles: String
    public let logsBloom: String
    public let transactionsRoot: String
    public let stateRoot: String
    public let receiptsRoot: String
    public let miner: String
    public let difficulty: String
    public let totalDifficulty: String
    public let extraData: String
    public let size: String
    public let gasLimit: String
    public let gasUsed: String
    public let timestamp: String
    public let transactions: [String]
    public let uncles: [String]
}

/// Fee history for EIP-1559
public struct FeeHistory: Codable, Equatable {
    public let oldestBlock: String
    public let baseFeePerGas: [String]
    public let gasUsedRatio: [Double]
    public let reward: [[String]]
}

/// Transaction record for history
public struct TransactionRecord: Codable, Identifiable, Equatable {
    public let id = UUID()
    public let hash: String
    public let from: String
    public let to: String
    public let value: String
    public let gasUsed: UInt64
    public let gasPrice: String
    public let blockNumber: UInt64
    public let timestamp: Date
    public let status: TransactionStatus
}

/// Rate limiter for API requests
private class RateLimiter {
    private let maxRequests: Int
    private let timeWindow: TimeInterval
    private var requests: [Date] = []
    
    init(maxRequests: Int, timeWindow: TimeInterval) {
        self.maxRequests = maxRequests
        self.timeWindow = timeWindow
    }
    
    func checkRateLimit() async throws {
        let now = Date()
        requests = requests.filter { now.timeIntervalSince($0) < timeWindow }
        
        if requests.count >= maxRequests {
            throw NetworkError.rateLimitExceeded
        }
        
        requests.append(now)
    }
} 