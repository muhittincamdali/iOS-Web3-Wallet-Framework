# Multi-Chain API Documentation

<!-- TOC START -->
## Table of Contents
- [Multi-Chain API Documentation](#multi-chain-api-documentation)
- [Overview](#overview)
- [Table of Contents](#table-of-contents)
- [Supported Networks](#supported-networks)
  - [Ethereum](#ethereum)
  - [Polygon](#polygon)
  - [Binance Smart Chain](#binance-smart-chain)
  - [Arbitrum](#arbitrum)
  - [Optimism](#optimism)
- [Network Management](#network-management)
  - [NetworkManager](#networkmanager)
  - [Network Configuration](#network-configuration)
- [Cross-Chain Operations](#cross-chain-operations)
  - [CrossChainManager](#crosschainmanager)
  - [MultiChainWallet](#multichainwallet)
- [Token Standards](#token-standards)
  - [ERC-20 Support](#erc-20-support)
  - [ERC-721 Support](#erc-721-support)
  - [ERC-1155 Support](#erc-1155-support)
- [Gas Management](#gas-management)
  - [GasOptimizer](#gasoptimizer)
  - [GasPrice](#gasprice)
- [Transaction Handling](#transaction-handling)
  - [MultiChainTransaction](#multichaintransaction)
- [Bridge Operations](#bridge-operations)
  - [CrossChainBridge](#crosschainbridge)
  - [BridgeTransaction](#bridgetransaction)
- [Usage Examples](#usage-examples)
  - [Basic Multi-Chain Setup](#basic-multi-chain-setup)
  - [Cross-Chain Token Transfer](#cross-chain-token-transfer)
  - [Multi-Chain Balance Check](#multi-chain-balance-check)
- [Best Practices](#best-practices)
  - [Network Selection](#network-selection)
  - [Transaction Management](#transaction-management)
  - [Security Considerations](#security-considerations)
- [Integration](#integration)
  - [SwiftUI Integration](#swiftui-integration)
  - [UIKit Integration](#uikit-integration)
<!-- TOC END -->


## Overview

The Multi-Chain API provides comprehensive support for multiple blockchain networks, enabling seamless interaction with Ethereum, Polygon, Binance Smart Chain, Arbitrum, Optimism, and other networks. This API is designed for high performance, security, and ease of use.

## Table of Contents

- [Supported Networks](#supported-networks)
- [Network Management](#network-management)
- [Cross-Chain Operations](#cross-chain-operations)
- [Token Standards](#token-standards)
- [Gas Management](#gas-management)
- [Transaction Handling](#transaction-handling)
- [Bridge Operations](#bridge-operations)

## Supported Networks

### Ethereum

```swift
public enum EthereumNetwork {
    case mainnet
    case sepolia
    case goerli
    case local
}

public struct EthereumConfig {
    public let network: EthereumNetwork
    public let rpcURL: String
    public let chainId: Int
    public let name: String
    public let currencySymbol: String
    public let blockExplorer: String
}
```

### Polygon

```swift
public enum PolygonNetwork {
    case mainnet
    case mumbai
    case local
}

public struct PolygonConfig {
    public let network: PolygonNetwork
    public let rpcURL: String
    public let chainId: Int
    public let name: String
    public let currencySymbol: String
    public let blockExplorer: String
}
```

### Binance Smart Chain

```swift
public enum BSCNetwork {
    case mainnet
    case testnet
    case local
}

public struct BSCConfig {
    public let network: BSCNetwork
    public let rpcURL: String
    public let chainId: Int
    public let name: String
    public let currencySymbol: String
    public let blockExplorer: String
}
```

### Arbitrum

```swift
public enum ArbitrumNetwork {
    case mainnet
    case goerli
    case local
}

public struct ArbitrumConfig {
    public let network: ArbitrumNetwork
    public let rpcURL: String
    public let chainId: Int
    public let name: String
    public let currencySymbol: String
    public let blockExplorer: String
}
```

### Optimism

```swift
public enum OptimismNetwork {
    case mainnet
    case goerli
    case local
}

public struct OptimismConfig {
    public let network: OptimismNetwork
    public let rpcURL: String
    public let chainId: Int
    public let name: String
    public let currencySymbol: String
    public let blockExplorer: String
}
```

## Network Management

### NetworkManager

```swift
public class NetworkManager: ObservableObject {
    @Published public var currentNetwork: BlockchainNetwork
    @Published public var availableNetworks: [BlockchainNetwork]
    
    public init() {
        // Initialize with default networks
    }
    
    public func switchNetwork(to network: BlockchainNetwork) async throws {
        // Switch to specified network
    }
    
    public func addCustomNetwork(_ config: NetworkConfig) async throws {
        // Add custom network
    }
    
    public func removeNetwork(_ network: BlockchainNetwork) async throws {
        // Remove network
    }
}
```

### Network Configuration

```swift
public struct NetworkConfig {
    public let rpcURL: String
    public let chainId: Int
    public let name: String
    public let currencySymbol: String
    public let blockExplorer: String
    public let isTestnet: Bool
    public let gasLimit: Int
    public let gasPrice: GasPrice
}
```

## Cross-Chain Operations

### CrossChainManager

```swift
public class CrossChainManager: ObservableObject {
    public func getBalance(
        address: String,
        network: BlockchainNetwork
    ) async throws -> String {
        // Get balance for specific network
    }
    
    public func sendTransaction(
        transaction: Transaction,
        network: BlockchainNetwork
    ) async throws -> String {
        // Send transaction on specific network
    }
    
    public func getTransactionHistory(
        address: String,
        network: BlockchainNetwork,
        limit: Int
    ) async throws -> [Transaction] {
        // Get transaction history for network
    }
}
```

### MultiChainWallet

```swift
public class MultiChainWallet: ObservableObject {
    @Published public var wallets: [BlockchainNetwork: Wallet]
    @Published public var currentNetwork: BlockchainNetwork
    
    public func createWallet(for network: BlockchainNetwork) async throws -> Wallet {
        // Create wallet for specific network
    }
    
    public func importWallet(
        privateKey: String,
        network: BlockchainNetwork
    ) async throws -> Wallet {
        // Import wallet for specific network
    }
    
    public func getWallet(for network: BlockchainNetwork) -> Wallet? {
        // Get wallet for specific network
    }
}
```

## Token Standards

### ERC-20 Support

```swift
public struct ERC20Token {
    public let address: String
    public let name: String
    public let symbol: String
    public let decimals: Int
    public let totalSupply: String
    public let network: BlockchainNetwork
}

public class ERC20Manager {
    public func getTokenInfo(
        address: String,
        network: BlockchainNetwork
    ) async throws -> ERC20Token {
        // Get token information
    }
    
    public func getTokenBalance(
        tokenAddress: String,
        walletAddress: String,
        network: BlockchainNetwork
    ) async throws -> String {
        // Get token balance
    }
    
    public func transferToken(
        tokenAddress: String,
        to: String,
        amount: String,
        network: BlockchainNetwork
    ) async throws -> String {
        // Transfer tokens
    }
}
```

### ERC-721 Support

```swift
public struct ERC721Token {
    public let address: String
    public let name: String
    public let symbol: String
    public let tokenId: String
    public let metadata: TokenMetadata
    public let network: BlockchainNetwork
}

public struct TokenMetadata {
    public let name: String
    public let description: String
    public let image: String
    public let attributes: [TokenAttribute]
}

public class ERC721Manager {
    public func getNFTInfo(
        contractAddress: String,
        tokenId: String,
        network: BlockchainNetwork
    ) async throws -> ERC721Token {
        // Get NFT information
    }
    
    public func getNFTs(
        walletAddress: String,
        network: BlockchainNetwork
    ) async throws -> [ERC721Token] {
        // Get NFTs owned by wallet
    }
}
```

### ERC-1155 Support

```swift
public struct ERC1155Token {
    public let address: String
    public let tokenId: String
    public let balance: String
    public let metadata: TokenMetadata
    public let network: BlockchainNetwork
}

public class ERC1155Manager {
    public func getTokenBalance(
        contractAddress: String,
        tokenId: String,
        walletAddress: String,
        network: BlockchainNetwork
    ) async throws -> String {
        // Get token balance
    }
    
    public func batchTransfer(
        contractAddress: String,
        to: String,
        tokenIds: [String],
        amounts: [String],
        network: BlockchainNetwork
    ) async throws -> String {
        // Batch transfer tokens
    }
}
```

## Gas Management

### GasOptimizer

```swift
public class GasOptimizer {
    public func getOptimalGasPrice(
        network: BlockchainNetwork
    ) async throws -> GasPrice {
        // Get optimal gas price for network
    }
    
    public func estimateGas(
        transaction: Transaction,
        network: BlockchainNetwork
    ) async throws -> Int {
        // Estimate gas for transaction
    }
    
    public func createOptimizedTransaction(
        transaction: Transaction,
        network: BlockchainNetwork,
        maxGasPrice: GasPrice
    ) async throws -> Transaction {
        // Create optimized transaction
    }
}
```

### GasPrice

```swift
public struct GasPrice {
    public let slow: String
    public let standard: String
    public let fast: String
    public let rapid: String
    
    public init(slow: String, standard: String, fast: String, rapid: String) {
        self.slow = slow
        self.standard = standard
        self.fast = fast
        self.rapid = rapid
    }
}
```

## Transaction Handling

### MultiChainTransaction

```swift
public struct MultiChainTransaction {
    public let from: String
    public let to: String
    public let value: String
    public let gasLimit: Int
    public let gasPrice: String
    public let nonce: Int
    public let data: String
    public let network: BlockchainNetwork
    public let chainId: Int
}

public class TransactionManager {
    public func createTransaction(
        to: String,
        value: String,
        network: BlockchainNetwork
    ) async throws -> MultiChainTransaction {
        // Create transaction for network
    }
    
    public func signTransaction(
        transaction: MultiChainTransaction,
        privateKey: String
    ) async throws -> String {
        // Sign transaction
    }
    
    public func sendTransaction(
        signedTransaction: String,
        network: BlockchainNetwork
    ) async throws -> String {
        // Send signed transaction
    }
    
    public func getTransactionStatus(
        hash: String,
        network: BlockchainNetwork
    ) async throws -> TransactionStatus {
        // Get transaction status
    }
}
```

## Bridge Operations

### CrossChainBridge

```swift
public class CrossChainBridge {
    public func createBridgeTransaction(
        sourceChain: BlockchainNetwork,
        destinationChain: BlockchainNetwork,
        token: String,
        amount: String,
        recipient: String
    ) async throws -> BridgeTransaction {
        // Create bridge transaction
    }
    
    public func executeBridge(
        transaction: BridgeTransaction
    ) async throws -> String {
        // Execute bridge transaction
    }
    
    public func getBridgeStatus(
        transactionHash: String
    ) async throws -> BridgeStatus {
        // Get bridge status
    }
}
```

### BridgeTransaction

```swift
public struct BridgeTransaction {
    public let sourceChain: BlockchainNetwork
    public let destinationChain: BlockchainNetwork
    public let token: String
    public let amount: String
    public let recipient: String
    public let estimatedTime: TimeInterval
    public let fees: String
}

public enum BridgeStatus {
    case pending
    case processing
    case completed
    case failed
    case cancelled
}
```

## Usage Examples

### Basic Multi-Chain Setup

```swift
import iOSWeb3WalletFramework

class MultiChainExample {
    private let networkManager = NetworkManager()
    private let walletManager = MultiChainWallet()
    
    func setupMultiChain() async throws {
        // Switch to Ethereum mainnet
        try await networkManager.switchNetwork(to: .ethereum(.mainnet))
        
        // Create wallet for Ethereum
        let ethereumWallet = try await walletManager.createWallet(for: .ethereum(.mainnet))
        
        // Switch to Polygon
        try await networkManager.switchNetwork(to: .polygon(.mainnet))
        
        // Create wallet for Polygon
        let polygonWallet = try await walletManager.createWallet(for: .polygon(.mainnet))
    }
}
```

### Cross-Chain Token Transfer

```swift
func transferTokensCrossChain() async throws {
    let bridge = CrossChainBridge()
    
    // Create bridge transaction
    let bridgeTransaction = try await bridge.createBridgeTransaction(
        sourceChain: .ethereum(.mainnet),
        destinationChain: .polygon(.mainnet),
        token: "USDC",
        amount: "100",
        recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
    )
    
    // Execute bridge
    let bridgeHash = try await bridge.executeBridge(bridgeTransaction)
    
    // Monitor bridge status
    let status = try await bridge.getBridgeStatus(transactionHash: bridgeHash)
    print("Bridge status: \(status)")
}
```

### Multi-Chain Balance Check

```swift
func checkBalancesAcrossNetworks() async throws {
    let crossChainManager = CrossChainManager()
    let walletAddress = "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
    
    let networks: [BlockchainNetwork] = [
        .ethereum(.mainnet),
        .polygon(.mainnet),
        .bsc(.mainnet),
        .arbitrum(.mainnet),
        .optimism(.mainnet)
    ]
    
    for network in networks {
        let balance = try await crossChainManager.getBalance(
            address: walletAddress,
            network: network
        )
        print("\(network.name): \(balance)")
    }
}
```

## Best Practices

### Network Selection

1. **User Preference**: Allow users to choose their preferred networks
2. **Gas Optimization**: Automatically select networks with lower gas fees
3. **Security**: Validate network configurations before use
4. **Fallback**: Provide fallback networks for failed operations

### Transaction Management

1. **Gas Estimation**: Always estimate gas before sending transactions
2. **Nonce Management**: Properly manage nonce values for each network
3. **Error Handling**: Handle network-specific errors appropriately
4. **Confirmation**: Wait for transaction confirmations

### Security Considerations

1. **Network Validation**: Validate network configurations
2. **Transaction Verification**: Verify transaction parameters
3. **Private Key Security**: Never expose private keys in logs
4. **Network Isolation**: Isolate testnet and mainnet operations

## Integration

### SwiftUI Integration

```swift
import SwiftUI
import iOSWeb3WalletFramework

struct MultiChainWalletView: View {
    @StateObject private var networkManager = NetworkManager()
    @StateObject private var walletManager = MultiChainWallet()
    
    var body: some View {
        VStack {
            Picker("Network", selection: $networkManager.currentNetwork) {
                ForEach(networkManager.availableNetworks, id: \.self) { network in
                    Text(network.name).tag(network)
                }
            }
            
            if let wallet = walletManager.getWallet(for: networkManager.currentNetwork) {
                WalletView(wallet: wallet)
            }
        }
    }
}
```

### UIKit Integration

```swift
import UIKit
import iOSWeb3WalletFramework

class MultiChainViewController: UIViewController {
    private let networkManager = NetworkManager()
    private let walletManager = MultiChainWallet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNetworkPicker()
        setupWalletView()
    }
    
    private func setupNetworkPicker() {
        // Setup network picker
    }
    
    private func setupWalletView() {
        // Setup wallet view
    }
}
```

This comprehensive Multi-Chain API provides everything needed to build robust, secure, and user-friendly multi-chain Web3 applications.
