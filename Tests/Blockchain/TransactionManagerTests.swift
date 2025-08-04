import XCTest
import BigInt
@testable import iOSWeb3WalletFramework

final class TransactionManagerTests: XCTestCase {
    
    var transactionManager: TransactionManager!
    
    override func setUp() {
        super.setUp()
        transactionManager = TransactionManager()
    }
    
    override func tearDown() {
        transactionManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testTransactionManagerInitialization() {
        XCTAssertNotNil(transactionManager)
        XCTAssertEqual(transactionManager.currentNetwork, .ethereum)
        XCTAssertEqual(transactionManager.transactionHistory.count, 0)
        XCTAssertEqual(transactionManager.pendingTransactions.count, 0)
    }
    
    func testTransactionManagerWithCustomConfiguration() {
        let customManager = TransactionManager(
            network: .polygon,
            customRPC: "https://polygon-rpc.com",
            gasStrategy: .conservative
        )
        
        XCTAssertNotNil(customManager)
        XCTAssertEqual(customManager.currentNetwork, .polygon)
    }
    
    // MARK: - Transaction Validation Tests
    
    func testValidTransaction() {
        let transaction = Transaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "1000000000000000000", // 1 ETH
            network: .ethereum
        )
        
        XCTAssertNoThrow(try validateTransaction(transaction))
    }
    
    func testInvalidAddressTransaction() {
        let transaction = Transaction(
            to: "invalid-address",
            value: "1000000000000000000",
            network: .ethereum
        )
        
        XCTAssertThrowsError(try validateTransaction(transaction)) { error in
            XCTAssertTrue(error is TransactionError)
        }
    }
    
    func testInvalidAmountTransaction() {
        let transaction = Transaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "0",
            network: .ethereum
        )
        
        XCTAssertThrowsError(try validateTransaction(transaction)) { error in
            XCTAssertTrue(error is TransactionError)
        }
    }
    
    func testInvalidGasLimitTransaction() {
        let transaction = Transaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "1000000000000000000",
            gasLimit: 0,
            network: .ethereum
        )
        
        XCTAssertThrowsError(try validateTransaction(transaction)) { error in
            XCTAssertTrue(error is TransactionError)
        }
    }
    
    func testNetworkMismatchTransaction() {
        let transaction = Transaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "1000000000000000000",
            network: .polygon
        )
        
        XCTAssertThrowsError(try validateTransaction(transaction)) { error in
            XCTAssertTrue(error is TransactionError)
        }
    }
    
    // MARK: - Address Validation Tests
    
    func testValidEthereumAddress() {
        let validAddress = "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
        XCTAssertTrue(isValidAddress(validAddress))
    }
    
    func testInvalidEthereumAddress() {
        let invalidAddresses = [
            "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b", // Too short
            "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6G", // Invalid character
            "742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6", // No 0x prefix
            "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6", // Valid but test should fail
        ]
        
        for address in invalidAddresses {
            XCTAssertFalse(isValidAddress(address), "Address should be invalid: \(address)")
        }
    }
    
    // MARK: - Network Tests
    
    func testBlockchainNetworkProperties() {
        let ethereum = BlockchainNetwork.ethereum
        XCTAssertEqual(ethereum.chainId, 1)
        XCTAssertEqual(ethereum.name, "Ethereum")
        XCTAssertTrue(ethereum.defaultRPC.contains("infura.io"))
        
        let polygon = BlockchainNetwork.polygon
        XCTAssertEqual(polygon.chainId, 137)
        XCTAssertEqual(polygon.name, "Polygon")
        XCTAssertTrue(polygon.defaultRPC.contains("polygon-rpc.com"))
        
        let bsc = BlockchainNetwork.binanceSmartChain
        XCTAssertEqual(bsc.chainId, 56)
        XCTAssertEqual(bsc.name, "Binance Smart Chain")
        XCTAssertTrue(bsc.defaultRPC.contains("bsc-dataseed.binance.org"))
    }
    
    func testAllNetworksAvailable() {
        let networks = BlockchainNetwork.allCases
        XCTAssertEqual(networks.count, 5)
        XCTAssertTrue(networks.contains(.ethereum))
        XCTAssertTrue(networks.contains(.polygon))
        XCTAssertTrue(networks.contains(.binanceSmartChain))
        XCTAssertTrue(networks.contains(.arbitrum))
        XCTAssertTrue(networks.contains(.optimism))
    }
    
    // MARK: - Transaction Model Tests
    
    func testTransactionInitialization() {
        let transaction = Transaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "1000000000000000000",
            gasLimit: 21000,
            network: .ethereum,
            data: Data(),
            nonce: 5
        )
        
        XCTAssertEqual(transaction.to, "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6")
        XCTAssertEqual(transaction.value, "1000000000000000000")
        XCTAssertEqual(transaction.gasLimit, 21000)
        XCTAssertEqual(transaction.network, .ethereum)
        XCTAssertNotNil(transaction.data)
        XCTAssertEqual(transaction.nonce, 5)
    }
    
    func testTransactionWithOptionalParameters() {
        let transaction = Transaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "1000000000000000000",
            network: .ethereum
        )
        
        XCTAssertEqual(transaction.to, "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6")
        XCTAssertEqual(transaction.value, "1000000000000000000")
        XCTAssertNil(transaction.gasLimit)
        XCTAssertEqual(transaction.network, .ethereum)
        XCTAssertNil(transaction.data)
        XCTAssertNil(transaction.nonce)
    }
    
    // MARK: - Transaction Status Tests
    
    func testTransactionStatusCases() {
        XCTAssertEqual(TransactionStatus.pending.rawValue, "pending")
        XCTAssertEqual(TransactionStatus.confirmed.rawValue, "confirmed")
        XCTAssertEqual(TransactionStatus.failed.rawValue, "failed")
        XCTAssertEqual(TransactionStatus.dropped.rawValue, "dropped")
    }
    
    // MARK: - Transaction Receipt Tests
    
    func testTransactionReceiptInitialization() {
        let logs = [
            TransactionLog(
                address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
                topics: ["0xevent"],
                data: "0xdata"
            )
        ]
        
        let receipt = TransactionReceipt(
            transactionHash: "0xhash",
            blockNumber: BigUInt(12345),
            gasUsed: BigUInt(21000),
            status: .confirmed,
            logs: logs
        )
        
        XCTAssertEqual(receipt.transactionHash, "0xhash")
        XCTAssertEqual(receipt.blockNumber, BigUInt(12345))
        XCTAssertEqual(receipt.gasUsed, BigUInt(21000))
        XCTAssertEqual(receipt.status, .confirmed)
        XCTAssertEqual(receipt.logs.count, 1)
    }
    
    // MARK: - Gas Strategy Tests
    
    func testGasStrategyCases() {
        let automatic = GasStrategy.automatic
        let conservative = GasStrategy.conservative
        let aggressive = GasStrategy.aggressive
        let custom = GasStrategy.custom(BigUInt(50000))
        
        XCTAssertNotNil(automatic)
        XCTAssertNotNil(conservative)
        XCTAssertNotNil(aggressive)
        XCTAssertNotNil(custom)
    }
    
    // MARK: - Error Tests
    
    func testTransactionErrorDescriptions() {
        let invalidAddressError = TransactionError.invalidAddress("0xinvalid")
        XCTAssertNotNil(invalidAddressError.errorDescription)
        XCTAssertTrue(invalidAddressError.errorDescription!.contains("Invalid address"))
        
        let invalidAmountError = TransactionError.invalidAmount("0")
        XCTAssertNotNil(invalidAmountError.errorDescription)
        XCTAssertTrue(invalidAmountError.errorDescription!.contains("Invalid amount"))
        
        let invalidGasLimitError = TransactionError.invalidGasLimit(0)
        XCTAssertNotNil(invalidGasLimitError.errorDescription)
        XCTAssertTrue(invalidGasLimitError.errorDescription!.contains("Invalid gas limit"))
        
        let networkMismatchError = TransactionError.networkMismatch(.ethereum, .polygon)
        XCTAssertNotNil(networkMismatchError.errorDescription)
        XCTAssertTrue(networkMismatchError.errorDescription!.contains("Network mismatch"))
    }
    
    // MARK: - Data Extension Tests
    
    func testDataFromHex() {
        let hexString = "48656c6c6f" // "Hello" in hex
        let data = Data(hex: hexString)
        XCTAssertEqual(data.count, 5)
        
        let emptyData = Data(hex: "")
        XCTAssertEqual(emptyData.count, 0)
    }
    
    func testBigUIntSerialization() {
        let bigUInt = BigUInt(12345)
        let serialized = bigUInt.serialize()
        XCTAssertNotNil(serialized)
        XCTAssertGreaterThan(serialized.count, 0)
    }
    
    // MARK: - Performance Tests
    
    func testTransactionValidationPerformance() {
        let transaction = Transaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "1000000000000000000",
            network: .ethereum
        )
        
        measure {
            for _ in 0..<1000 {
                XCTAssertNoThrow(try validateTransaction(transaction))
            }
        }
    }
    
    func testAddressValidationPerformance() {
        let validAddress = "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
        
        measure {
            for _ in 0..<10000 {
                XCTAssertTrue(isValidAddress(validAddress))
            }
        }
    }
    
    // MARK: - Memory Tests
    
    func testTransactionManagerMemoryUsage() {
        let initialMemory = getMemoryUsage()
        
        for i in 0..<100 {
            let transaction = Transaction(
                to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
                value: "\(i)",
                network: .ethereum
            )
            transactionManager.transactionHistory.append(transaction)
        }
        
        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        // Memory increase should be reasonable (less than 1MB)
        XCTAssertLessThan(memoryIncrease, 1024 * 1024)
    }
    
    // MARK: - Helper Methods
    
    private func validateTransaction(_ transaction: Transaction) throws {
        // Validate recipient address
        guard isValidAddress(transaction.to) else {
            throw TransactionError.invalidAddress(transaction.to)
        }
        
        // Validate amount
        guard let amount = BigUInt(transaction.value), amount > 0 else {
            throw TransactionError.invalidAmount(transaction.value)
        }
        
        // Validate gas limit
        if let gasLimit = transaction.gasLimit {
            guard gasLimit > 0 else {
                throw TransactionError.invalidGasLimit(gasLimit)
            }
        }
        
        // Validate network compatibility
        guard transaction.network == transactionManager.currentNetwork else {
            throw TransactionError.networkMismatch(transaction.network, transactionManager.currentNetwork)
        }
    }
    
    private func isValidAddress(_ address: String) -> Bool {
        let pattern = "^0x[a-fA-F0-9]{40}$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: address.utf16.count)
        return regex.firstMatch(in: address, range: range) != nil
    }
    
    private func getMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int(info.resident_size)
        } else {
            return 0
        }
    }
} 