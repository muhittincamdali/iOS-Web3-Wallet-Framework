import XCTest
import Web3Wallet

class BlockchainTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testBlockchainInitialization() {
        let blockchain = Blockchain(
            id: "test-chain",
            name: "Test Chain",
            chainId: 1,
            rpcUrl: "https://test-rpc.com",
            explorerUrl: "https://test-explorer.com",
            nativeCurrency: NativeCurrency(
                name: "Test Token",
                symbol: "TEST",
                decimals: 18
            ),
            blockTime: 12
        )
        
        XCTAssertEqual(blockchain.id, "test-chain")
        XCTAssertEqual(blockchain.name, "Test Chain")
        XCTAssertEqual(blockchain.chainId, 1)
        XCTAssertEqual(blockchain.rpcUrl, "https://test-rpc.com")
        XCTAssertEqual(blockchain.explorerUrl, "https://test-explorer.com")
        XCTAssertEqual(blockchain.nativeCurrency.name, "Test Token")
        XCTAssertEqual(blockchain.nativeCurrency.symbol, "TEST")
        XCTAssertEqual(blockchain.nativeCurrency.decimals, 18)
        XCTAssertEqual(blockchain.blockTime, 12)
        XCTAssertFalse(blockchain.isTestnet)
        XCTAssertEqual(blockchain.status, .active)
    }
    
    func testBlockchainInitializationWithTestnet() {
        let blockchain = Blockchain(
            id: "test-testnet",
            name: "Test Testnet",
            chainId: 5,
            rpcUrl: "https://test-testnet-rpc.com",
            explorerUrl: "https://test-testnet-explorer.com",
            nativeCurrency: NativeCurrency(
                name: "Test Token",
                symbol: "TEST",
                decimals: 18
            ),
            blockTime: 12,
            isTestnet: true
        )
        
        XCTAssertTrue(blockchain.isTestnet)
        XCTAssertEqual(blockchain.fullName, "Test Testnet Testnet")
    }
    
    // MARK: - Computed Properties Tests
    
    func testShortName() {
        let blockchain = Blockchain(
            id: "ethereum",
            name: "Ethereum Mainnet",
            chainId: 1,
            rpcUrl: "https://mainnet.infura.io",
            explorerUrl: "https://etherscan.io",
            nativeCurrency: NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18),
            blockTime: 12
        )
        
        XCTAssertEqual(blockchain.shortName, "Ethereum")
    }
    
    func testFullName() {
        let mainnet = Blockchain(
            id: "ethereum",
            name: "Ethereum",
            chainId: 1,
            rpcUrl: "https://mainnet.infura.io",
            explorerUrl: "https://etherscan.io",
            nativeCurrency: NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18),
            blockTime: 12
        )
        
        let testnet = Blockchain(
            id: "goerli",
            name: "Goerli",
            chainId: 5,
            rpcUrl: "https://goerli.infura.io",
            explorerUrl: "https://goerli.etherscan.io",
            nativeCurrency: NativeCurrency(name: "Goerli Ether", symbol: "ETH", decimals: 18),
            blockTime: 12,
            isTestnet: true
        )
        
        XCTAssertEqual(mainnet.fullName, "Ethereum")
        XCTAssertEqual(testnet.fullName, "Goerli Testnet")
    }
    
    func testFeatureSupport() {
        let blockchain = Blockchain(
            id: "ethereum",
            name: "Ethereum",
            chainId: 1,
            rpcUrl: "https://mainnet.infura.io",
            explorerUrl: "https://etherscan.io",
            nativeCurrency: NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18),
            blockTime: 12,
            features: [.smartContracts, .deFi, .nfts]
        )
        
        XCTAssertTrue(blockchain.supportsSmartContracts)
        XCTAssertTrue(blockchain.supportsDeFi)
        XCTAssertTrue(blockchain.supportsNFTs)
        XCTAssertFalse(blockchain.supportsStaking)
    }
    
    // MARK: - Validation Tests
    
    func testBlockchainValidation() {
        let validBlockchain = Blockchain(
            id: "ethereum",
            name: "Ethereum",
            chainId: 1,
            rpcUrl: "https://mainnet.infura.io",
            explorerUrl: "https://etherscan.io",
            nativeCurrency: NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18),
            blockTime: 12
        )
        
        XCTAssertNoThrow(try validBlockchain.validate())
    }
    
    func testBlockchainValidationWithInvalidId() {
        let invalidBlockchain = Blockchain(
            id: "",
            name: "Ethereum",
            chainId: 1,
            rpcUrl: "https://mainnet.infura.io",
            explorerUrl: "https://etherscan.io",
            nativeCurrency: NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18),
            blockTime: 12
        )
        
        XCTAssertThrowsError(try invalidBlockchain.validate()) { error in
            XCTAssertEqual(error as? BlockchainError, .invalidId)
        }
    }
    
    func testBlockchainValidationWithInvalidName() {
        let invalidBlockchain = Blockchain(
            id: "ethereum",
            name: "",
            chainId: 1,
            rpcUrl: "https://mainnet.infura.io",
            explorerUrl: "https://etherscan.io",
            nativeCurrency: NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18),
            blockTime: 12
        )
        
        XCTAssertThrowsError(try invalidBlockchain.validate()) { error in
            XCTAssertEqual(error as? BlockchainError, .invalidName)
        }
    }
    
    func testBlockchainValidationWithInvalidChainId() {
        let invalidBlockchain = Blockchain(
            id: "ethereum",
            name: "Ethereum",
            chainId: 0,
            rpcUrl: "https://mainnet.infura.io",
            explorerUrl: "https://etherscan.io",
            nativeCurrency: NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18),
            blockTime: 12
        )
        
        XCTAssertThrowsError(try invalidBlockchain.validate()) { error in
            XCTAssertEqual(error as? BlockchainError, .invalidChainId)
        }
    }
    
    func testBlockchainValidationWithInvalidRpcUrl() {
        let invalidBlockchain = Blockchain(
            id: "ethereum",
            name: "Ethereum",
            chainId: 1,
            rpcUrl: "",
            explorerUrl: "https://etherscan.io",
            nativeCurrency: NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18),
            blockTime: 12
        )
        
        XCTAssertThrowsError(try invalidBlockchain.validate()) { error in
            XCTAssertEqual(error as? BlockchainError, .invalidRpcUrl)
        }
    }
    
    func testBlockchainValidationWithInvalidExplorerUrl() {
        let invalidBlockchain = Blockchain(
            id: "ethereum",
            name: "Ethereum",
            chainId: 1,
            rpcUrl: "https://mainnet.infura.io",
            explorerUrl: "",
            nativeCurrency: NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18),
            blockTime: 12
        )
        
        XCTAssertThrowsError(try invalidBlockchain.validate()) { error in
            XCTAssertEqual(error as? BlockchainError, .invalidExplorerUrl)
        }
    }
    
    // MARK: - Update Tests
    
    func testBlockchainUpdate() {
        var blockchain = Blockchain(
            id: "ethereum",
            name: "Ethereum",
            chainId: 1,
            rpcUrl: "https://mainnet.infura.io",
            explorerUrl: "https://etherscan.io",
            nativeCurrency: NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18),
            blockTime: 12
        )
        
        blockchain.update(name: "Updated Ethereum")
        
        XCTAssertEqual(blockchain.name, "Updated Ethereum")
    }
    
    func testBlockchainUpdateWithStatus() {
        var blockchain = Blockchain(
            id: "ethereum",
            name: "Ethereum",
            chainId: 1,
            rpcUrl: "https://mainnet.infura.io",
            explorerUrl: "https://etherscan.io",
            nativeCurrency: NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18),
            blockTime: 12
        )
        
        blockchain.update(status: .maintenance)
        
        XCTAssertEqual(blockchain.status, .maintenance)
    }
    
    // MARK: - Native Currency Tests
    
    func testNativeCurrencyInitialization() {
        let currency = NativeCurrency(
            name: "Ether",
            symbol: "ETH",
            decimals: 18,
            logoUrl: "https://example.com/eth.png"
        )
        
        XCTAssertEqual(currency.name, "Ether")
        XCTAssertEqual(currency.symbol, "ETH")
        XCTAssertEqual(currency.decimals, 18)
        XCTAssertEqual(currency.logoUrl, "https://example.com/eth.png")
    }
    
    func testNativeCurrencyValidation() {
        let validCurrency = NativeCurrency(
            name: "Ether",
            symbol: "ETH",
            decimals: 18
        )
        
        XCTAssertNoThrow(try validCurrency.validate())
    }
    
    func testNativeCurrencyValidationWithInvalidName() {
        let invalidCurrency = NativeCurrency(
            name: "",
            symbol: "ETH",
            decimals: 18
        )
        
        XCTAssertThrowsError(try invalidCurrency.validate()) { error in
            XCTAssertEqual(error as? BlockchainError, .invalidCurrencyName)
        }
    }
    
    func testNativeCurrencyValidationWithInvalidSymbol() {
        let invalidCurrency = NativeCurrency(
            name: "Ether",
            symbol: "",
            decimals: 18
        )
        
        XCTAssertThrowsError(try invalidCurrency.validate()) { error in
            XCTAssertEqual(error as? BlockchainError, .invalidCurrencySymbol)
        }
    }
    
    func testNativeCurrencyValidationWithInvalidDecimals() {
        let invalidCurrency = NativeCurrency(
            name: "Ether",
            symbol: "ETH",
            decimals: 19
        )
        
        XCTAssertThrowsError(try invalidCurrency.validate()) { error in
            XCTAssertEqual(error as? BlockchainError, .invalidCurrencyDecimals)
        }
    }
    
    func testNativeCurrencyFormatAmount() {
        let currency = NativeCurrency(
            name: "Ether",
            symbol: "ETH",
            decimals: 18
        )
        
        let formatted = currency.formatAmount("1000000000000000000")
        XCTAssertEqual(formatted, "1.000000000000000000")
    }
    
    func testNativeCurrencyFromWei() {
        let currency = NativeCurrency(
            name: "Ether",
            symbol: "ETH",
            decimals: 18
        )
        
        let mainUnit = currency.fromWei("1000000000000000000")
        XCTAssertEqual(mainUnit, "1.000000000000000000")
    }
    
    func testNativeCurrencyToWei() {
        let currency = NativeCurrency(
            name: "Ether",
            symbol: "ETH",
            decimals: 18
        )
        
        let wei = currency.toWei("1.5")
        XCTAssertEqual(wei, "1500000000000000000")
    }
    
    // MARK: - Blockchain Feature Tests
    
    func testBlockchainFeatureDisplayNames() {
        XCTAssertEqual(BlockchainFeature.smartContracts.displayName, "Smart Contracts")
        XCTAssertEqual(BlockchainFeature.deFi.displayName, "DeFi")
        XCTAssertEqual(BlockchainFeature.nfts.displayName, "NFTs")
        XCTAssertEqual(BlockchainFeature.staking.displayName, "Staking")
        XCTAssertEqual(BlockchainFeature.governance.displayName, "Governance")
        XCTAssertEqual(BlockchainFeature.privacy.displayName, "Privacy")
        XCTAssertEqual(BlockchainFeature.scalability.displayName, "Scalability")
        XCTAssertEqual(BlockchainFeature.interoperability.displayName, "Interoperability")
    }
    
    func testBlockchainFeatureDescriptions() {
        XCTAssertEqual(BlockchainFeature.smartContracts.description, "Support for smart contract execution")
        XCTAssertEqual(BlockchainFeature.deFi.description, "Decentralized Finance protocols")
        XCTAssertEqual(BlockchainFeature.nfts.description, "Non-Fungible Token support")
        XCTAssertEqual(BlockchainFeature.staking.description, "Proof of Stake consensus")
        XCTAssertEqual(BlockchainFeature.governance.description, "On-chain governance mechanisms")
        XCTAssertEqual(BlockchainFeature.privacy.description, "Privacy-preserving features")
        XCTAssertEqual(BlockchainFeature.scalability.description, "High transaction throughput")
        XCTAssertEqual(BlockchainFeature.interoperability.description, "Cross-chain communication")
    }
    
    // MARK: - Blockchain Status Tests
    
    func testBlockchainStatusDisplayNames() {
        XCTAssertEqual(BlockchainStatus.active.displayName, "Active")
        XCTAssertEqual(BlockchainStatus.inactive.displayName, "Inactive")
        XCTAssertEqual(BlockchainStatus.maintenance.displayName, "Maintenance")
        XCTAssertEqual(BlockchainStatus.deprecated.displayName, "Deprecated")
    }
    
    func testBlockchainStatusAvailability() {
        XCTAssertTrue(BlockchainStatus.active.isAvailable)
        XCTAssertFalse(BlockchainStatus.inactive.isAvailable)
        XCTAssertFalse(BlockchainStatus.maintenance.isAvailable)
        XCTAssertFalse(BlockchainStatus.deprecated.isAvailable)
    }
    
    func testBlockchainStatusColors() {
        XCTAssertEqual(BlockchainStatus.active.color, "green")
        XCTAssertEqual(BlockchainStatus.inactive.color, "red")
        XCTAssertEqual(BlockchainStatus.maintenance.color, "yellow")
        XCTAssertEqual(BlockchainStatus.deprecated.color, "gray")
    }
    
    // MARK: - Predefined Blockchain Tests
    
    func testEthereumBlockchain() {
        let ethereum = Blockchain.ethereum
        
        XCTAssertEqual(ethereum.id, "ethereum")
        XCTAssertEqual(ethereum.name, "Ethereum")
        XCTAssertEqual(ethereum.chainId, 1)
        XCTAssertEqual(ethereum.nativeCurrency.symbol, "ETH")
        XCTAssertTrue(ethereum.supportsSmartContracts)
        XCTAssertTrue(ethereum.supportsDeFi)
        XCTAssertTrue(ethereum.supportsNFTs)
        XCTAssertTrue(ethereum.supportsStaking)
        XCTAssertFalse(ethereum.isTestnet)
    }
    
    func testPolygonBlockchain() {
        let polygon = Blockchain.polygon
        
        XCTAssertEqual(polygon.id, "polygon")
        XCTAssertEqual(polygon.name, "Polygon")
        XCTAssertEqual(polygon.chainId, 137)
        XCTAssertEqual(polygon.nativeCurrency.symbol, "MATIC")
        XCTAssertTrue(polygon.supportsSmartContracts)
        XCTAssertTrue(polygon.supportsDeFi)
        XCTAssertTrue(polygon.supportsNFTs)
        XCTAssertFalse(polygon.supportsStaking)
        XCTAssertFalse(polygon.isTestnet)
    }
    
    func testBinanceSmartChainBlockchain() {
        let bsc = Blockchain.binanceSmartChain
        
        XCTAssertEqual(bsc.id, "binance-smart-chain")
        XCTAssertEqual(bsc.name, "Binance Smart Chain")
        XCTAssertEqual(bsc.chainId, 56)
        XCTAssertEqual(bsc.nativeCurrency.symbol, "BNB")
        XCTAssertTrue(bsc.supportsSmartContracts)
        XCTAssertTrue(bsc.supportsDeFi)
        XCTAssertTrue(bsc.supportsNFTs)
        XCTAssertFalse(bsc.supportsStaking)
        XCTAssertFalse(bsc.isTestnet)
    }
    
    func testArbitrumBlockchain() {
        let arbitrum = Blockchain.arbitrum
        
        XCTAssertEqual(arbitrum.id, "arbitrum")
        XCTAssertEqual(arbitrum.name, "Arbitrum One")
        XCTAssertEqual(arbitrum.chainId, 42161)
        XCTAssertEqual(arbitrum.nativeCurrency.symbol, "ETH")
        XCTAssertTrue(arbitrum.supportsSmartContracts)
        XCTAssertTrue(arbitrum.supportsDeFi)
        XCTAssertTrue(arbitrum.supportsNFTs)
        XCTAssertFalse(arbitrum.supportsStaking)
        XCTAssertFalse(arbitrum.isTestnet)
    }
    
    func testOptimismBlockchain() {
        let optimism = Blockchain.optimism
        
        XCTAssertEqual(optimism.id, "optimism")
        XCTAssertEqual(optimism.name, "Optimism")
        XCTAssertEqual(optimism.chainId, 10)
        XCTAssertEqual(optimism.nativeCurrency.symbol, "ETH")
        XCTAssertTrue(optimism.supportsSmartContracts)
        XCTAssertTrue(optimism.supportsDeFi)
        XCTAssertTrue(optimism.supportsNFTs)
        XCTAssertFalse(optimism.supportsStaking)
        XCTAssertFalse(optimism.isTestnet)
    }
    
    func testAvalancheBlockchain() {
        let avalanche = Blockchain.avalanche
        
        XCTAssertEqual(avalanche.id, "avalanche")
        XCTAssertEqual(avalanche.name, "Avalanche C-Chain")
        XCTAssertEqual(avalanche.chainId, 43114)
        XCTAssertEqual(avalanche.nativeCurrency.symbol, "AVAX")
        XCTAssertTrue(avalanche.supportsSmartContracts)
        XCTAssertTrue(avalanche.supportsDeFi)
        XCTAssertTrue(avalanche.supportsNFTs)
        XCTAssertTrue(avalanche.supportsStaking)
        XCTAssertFalse(avalanche.isTestnet)
    }
    
    func testGoerliTestnet() {
        let goerli = Blockchain.goerli
        
        XCTAssertEqual(goerli.id, "goerli")
        XCTAssertEqual(goerli.name, "Goerli")
        XCTAssertEqual(goerli.chainId, 5)
        XCTAssertEqual(goerli.nativeCurrency.symbol, "ETH")
        XCTAssertTrue(goerli.supportsSmartContracts)
        XCTAssertTrue(goerli.supportsDeFi)
        XCTAssertTrue(goerli.supportsNFTs)
        XCTAssertFalse(goerli.supportsStaking)
        XCTAssertTrue(goerli.isTestnet)
    }
    
    func testMumbaiTestnet() {
        let mumbai = Blockchain.mumbai
        
        XCTAssertEqual(mumbai.id, "mumbai")
        XCTAssertEqual(mumbai.name, "Mumbai")
        XCTAssertEqual(mumbai.chainId, 80001)
        XCTAssertEqual(mumbai.nativeCurrency.symbol, "MATIC")
        XCTAssertTrue(mumbai.supportsSmartContracts)
        XCTAssertTrue(mumbai.supportsDeFi)
        XCTAssertTrue(mumbai.supportsNFTs)
        XCTAssertFalse(mumbai.supportsStaking)
        XCTAssertTrue(mumbai.isTestnet)
    }
    
    // MARK: - Utility Tests
    
    func testFindByChainId() {
        let ethereum = Blockchain.findByChainId(1)
        XCTAssertNotNil(ethereum)
        XCTAssertEqual(ethereum?.name, "Ethereum")
        
        let polygon = Blockchain.findByChainId(137)
        XCTAssertNotNil(polygon)
        XCTAssertEqual(polygon?.name, "Polygon")
        
        let nonExistent = Blockchain.findByChainId(999999)
        XCTAssertNil(nonExistent)
    }
    
    func testFindById() {
        let ethereum = Blockchain.findById("ethereum")
        XCTAssertNotNil(ethereum)
        XCTAssertEqual(ethereum?.name, "Ethereum")
        
        let polygon = Blockchain.findById("polygon")
        XCTAssertNotNil(polygon)
        XCTAssertEqual(polygon?.name, "Polygon")
        
        let nonExistent = Blockchain.findById("non-existent")
        XCTAssertNil(nonExistent)
    }
    
    func testActiveNetworks() {
        let activeNetworks = Blockchain.activeNetworks
        
        XCTAssertFalse(activeNetworks.isEmpty)
        XCTAssertTrue(activeNetworks.allSatisfy { $0.status.isAvailable })
    }
    
    func testNetworksSupportingFeature() {
        let defiNetworks = Blockchain.networksSupporting(.deFi)
        
        XCTAssertFalse(defiNetworks.isEmpty)
        XCTAssertTrue(defiNetworks.allSatisfy { $0.supportsDeFi })
    }
    
    func testMainnetNetworks() {
        let mainnetNetworks = Blockchain.mainnetNetworks
        
        XCTAssertFalse(mainnetNetworks.isEmpty)
        XCTAssertTrue(mainnetNetworks.allSatisfy { !$0.isTestnet })
    }
    
    func testTestnetNetworks() {
        let testnetNetworks = Blockchain.testnetNetworks
        
        XCTAssertFalse(testnetNetworks.isEmpty)
        XCTAssertTrue(testnetNetworks.allSatisfy { $0.isTestnet })
    }
    
    // MARK: - Error Tests
    
    func testBlockchainErrorDescriptions() {
        XCTAssertEqual(BlockchainError.invalidId.errorDescription, "Invalid blockchain ID")
        XCTAssertEqual(BlockchainError.invalidName.errorDescription, "Invalid blockchain name")
        XCTAssertEqual(BlockchainError.invalidChainId.errorDescription, "Invalid chain ID")
        XCTAssertEqual(BlockchainError.invalidRpcUrl.errorDescription, "Invalid RPC URL")
        XCTAssertEqual(BlockchainError.invalidExplorerUrl.errorDescription, "Invalid explorer URL")
        XCTAssertEqual(BlockchainError.invalidCurrencyName.errorDescription, "Invalid currency name")
        XCTAssertEqual(BlockchainError.invalidCurrencySymbol.errorDescription, "Invalid currency symbol")
        XCTAssertEqual(BlockchainError.invalidCurrencyDecimals.errorDescription, "Invalid currency decimals")
        XCTAssertEqual(BlockchainError.networkNotSupported.errorDescription, "Network not supported")
        XCTAssertEqual(BlockchainError.networkUnavailable.errorDescription, "Network is currently unavailable")
    }
    
    func testBlockchainErrorFeatureNotSupported() {
        let error = BlockchainError.featureNotSupported(.deFi)
        XCTAssertEqual(error.errorDescription, "Feature not supported: DeFi")
    }
    
    // MARK: - Codable Tests
    
    func testBlockchainEncoding() {
        let blockchain = Blockchain.ethereum
        
        XCTAssertNoThrow(try JSONEncoder().encode(blockchain))
    }
    
    func testBlockchainDecoding() {
        let blockchain = Blockchain.ethereum
        let data = try! JSONEncoder().encode(blockchain)
        let decoded = try! JSONDecoder().decode(Blockchain.self, from: data)
        
        XCTAssertEqual(decoded.id, blockchain.id)
        XCTAssertEqual(decoded.name, blockchain.name)
        XCTAssertEqual(decoded.chainId, blockchain.chainId)
    }
    
    func testNativeCurrencyEncoding() {
        let currency = NativeCurrency(
            name: "Ether",
            symbol: "ETH",
            decimals: 18,
            logoUrl: "https://example.com/eth.png"
        )
        
        XCTAssertNoThrow(try JSONEncoder().encode(currency))
    }
    
    func testNativeCurrencyDecoding() {
        let currency = NativeCurrency(
            name: "Ether",
            symbol: "ETH",
            decimals: 18,
            logoUrl: "https://example.com/eth.png"
        )
        let data = try! JSONEncoder().encode(currency)
        let decoded = try! JSONDecoder().decode(NativeCurrency.self, from: data)
        
        XCTAssertEqual(decoded.name, currency.name)
        XCTAssertEqual(decoded.symbol, currency.symbol)
        XCTAssertEqual(decoded.decimals, currency.decimals)
        XCTAssertEqual(decoded.logoUrl, currency.logoUrl)
    }
    
    // MARK: - Equatable Tests
    
    func testBlockchainEquality() {
        let blockchain1 = Blockchain.ethereum
        let blockchain2 = Blockchain.ethereum
        
        XCTAssertEqual(blockchain1, blockchain2)
    }
    
    func testBlockchainInequality() {
        let ethereum = Blockchain.ethereum
        let polygon = Blockchain.polygon
        
        XCTAssertNotEqual(ethereum, polygon)
    }
    
    func testNativeCurrencyEquality() {
        let currency1 = NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18)
        let currency2 = NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18)
        
        XCTAssertEqual(currency1, currency2)
    }
    
    func testNativeCurrencyInequality() {
        let eth = NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18)
        let matic = NativeCurrency(name: "MATIC", symbol: "MATIC", decimals: 18)
        
        XCTAssertNotEqual(eth, matic)
    }
    
    // MARK: - Hashable Tests
    
    func testBlockchainHashable() {
        let blockchain = Blockchain.ethereum
        let set: Set<Blockchain> = [blockchain]
        
        XCTAssertTrue(set.contains(blockchain))
    }
    
    func testNativeCurrencyHashable() {
        let currency = NativeCurrency(name: "Ether", symbol: "ETH", decimals: 18)
        let set: Set<NativeCurrency> = [currency]
        
        XCTAssertTrue(set.contains(currency))
    }
} 