# 🧪 Testing Guide

Comprehensive testing guide for the iOS Web3 Wallet Framework, covering unit tests, integration tests, and performance testing.

## 📋 Overview

This guide covers all aspects of testing the framework:

- ✅ Unit testing
- ✅ Integration testing
- ✅ Performance testing
- ✅ Security testing
- ✅ UI testing
- ✅ Test coverage

## 🚀 Quick Start

### Running Tests

```bash
# Run all tests
swift test

# Run specific test category
swift test --filter TransactionManagerTests

# Run with coverage
swift test --enable-code-coverage

# Run performance tests
swift test --filter PerformanceTests
```

### Test Structure

```
Tests/
├── Blockchain/
│   ├── TransactionManagerTests.swift
│   └── NetworkManagerTests.swift
├── DeFi/
│   ├── UniswapManagerTests.swift
│   └── AaveManagerTests.swift
├── Security/
│   ├── WalletManagerTests.swift
│   └── BiometricAuthTests.swift
├── UI/
│   ├── WalletViewTests.swift
│   └── TransactionViewTests.swift
└── Utils/
    ├── AddressValidatorTests.swift
    └── EncryptionTests.swift
```

## 📚 Unit Testing

### Basic Unit Test Structure

```swift
import XCTest
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
    
    func testTransactionCreation() {
        // Given
        let toAddress = "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
        let amount = "0.1"
        let network = BlockchainNetwork.ethereum
        
        // When
        let transaction = Transaction(
            to: toAddress,
            value: amount,
            network: network
        )
        
        // Then
        XCTAssertEqual(transaction.to, toAddress)
        XCTAssertEqual(transaction.value, amount)
        XCTAssertEqual(transaction.network, network)
    }
    
    func testInvalidAddressValidation() {
        // Given
        let invalidAddress = "invalid-address"
        
        // When & Then
        XCTAssertThrowsError(try validateAddress(invalidAddress)) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }
}
```

### Async Testing

```swift
func testAsyncTransactionSending() async throws {
    // Given
    let transaction = Transaction(
        to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
        value: "0.1",
        network: .ethereum
    )
    
    // When
    let txHash = try await transactionManager.sendTransaction(transaction)
    
    // Then
    XCTAssertFalse(txHash.isEmpty)
    XCTAssertTrue(txHash.hasPrefix("0x"))
}
```

### Mock Testing

```swift
class MockNetworkManager: NetworkManaging {
    var shouldFail = false
    var mockResponse: String = "0x1234567890abcdef"
    
    func sendRequest(_ request: NetworkRequest) async throws -> NetworkResponse {
        if shouldFail {
            throw NetworkError.connectionFailed
        }
        
        return NetworkResponse(data: mockResponse.data(using: .utf8)!)
    }
}

func testTransactionWithMockNetwork() async throws {
    // Given
    let mockNetwork = MockNetworkManager()
    let transactionManager = TransactionManager(networkManager: mockNetwork)
    
    // When
    let transaction = Transaction(
        to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
        value: "0.1",
        network: .ethereum
    )
    
    let txHash = try await transactionManager.sendTransaction(transaction)
    
    // Then
    XCTAssertEqual(txHash, mockNetwork.mockResponse)
}
```

## 🔗 Integration Testing

### End-to-End Testing

```swift
final class IntegrationTests: XCTestCase {
    
    var walletManager: WalletManager!
    var transactionManager: TransactionManager!
    var uniswapManager: UniswapManager!
    
    override func setUp() {
        super.setUp()
        walletManager = WalletManager()
        transactionManager = TransactionManager()
        uniswapManager = UniswapManager()
    }
    
    func testCompleteWalletWorkflow() async throws {
        // 1. Create wallet
        let wallet = try await createWallet()
        XCTAssertNotNil(wallet)
        XCTAssertFalse(wallet.address.isEmpty)
        
        // 2. Get balance
        let balance = try await getBalance(for: wallet.address)
        XCTAssertNotNil(balance)
        
        // 3. Send transaction
        let transaction = Transaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "0.01",
            network: .ethereum
        )
        
        let txHash = try await transactionManager.sendTransaction(transaction)
        XCTAssertFalse(txHash.isEmpty)
        
        // 4. Check transaction status
        let status = try await transactionManager.getTransactionStatus(txHash)
        XCTAssertEqual(status, .pending)
    }
    
    func testDeFiIntegration() async throws {
        // 1. Setup wallet
        let wallet = try await createWallet()
        
        // 2. Perform swap
        let swap = UniswapSwap(
            tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            tokenOut: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            amountIn: "0.1",
            slippageTolerance: 0.5,
            recipient: wallet.address,
            deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
        )
        
        let txHash = try await uniswapManager.swap(swap)
        XCTAssertFalse(txHash.isEmpty)
    }
}
```

### Network Integration Testing

```swift
final class NetworkIntegrationTests: XCTestCase {
    
    func testEthereumNetworkConnection() async throws {
        let networkManager = NetworkManager()
        
        // Test Ethereum mainnet
        let ethereumResponse = try await networkManager.getBalance(
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            network: .ethereum
        )
        XCTAssertNotNil(ethereumResponse)
        
        // Test Polygon network
        let polygonResponse = try await networkManager.getBalance(
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            network: .polygon
        )
        XCTAssertNotNil(polygonResponse)
    }
    
    func testGasEstimation() async throws {
        let networkManager = NetworkManager()
        
        let transaction = Transaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "0.1",
            network: .ethereum
        )
        
        let gasEstimate = try await networkManager.estimateGas(for: transaction)
        XCTAssertGreaterThan(gasEstimate, 0)
    }
}
```

## ⚡ Performance Testing

### Performance Test Structure

```swift
final class PerformanceTests: XCTestCase {
    
    func testTransactionValidationPerformance() {
        let transaction = Transaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "0.1",
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
    
    func testMemoryUsage() {
        var wallets: [Wallet] = []
        
        measure {
            for i in 0..<100 {
                let wallet = Wallet(
                    address: "0x\(i)",
                    privateKey: "0x\(i)",
                    network: .ethereum
                )
                wallets.append(wallet)
            }
        }
        
        // Check memory usage
        let memoryUsage = getMemoryUsage()
        XCTAssertLessThan(memoryUsage, 50 * 1024 * 1024) // 50MB limit
    }
}
```

### Memory Testing

```swift
func testMemoryLeaks() {
    weak var weakReference: TransactionManager?
    
    autoreleasepool {
        let transactionManager = TransactionManager()
        weakReference = transactionManager
        
        // Perform operations
        for i in 0..<100 {
            let transaction = Transaction(
                to: "0x\(i)",
                value: "0.1",
                network: .ethereum
            )
            transactionManager.transactionHistory.append(transaction)
        }
    }
    
    // Check if object was deallocated
    XCTAssertNil(weakReference, "Memory leak detected")
}
```

## 🛡️ Security Testing

### Security Test Structure

```swift
final class SecurityTests: XCTestCase {
    
    func testPrivateKeyEncryption() {
        let privateKey = "0x1234567890abcdef"
        let keyManager = SecureKeyManager()
        
        // Test encryption
        XCTAssertNoThrow(try keyManager.storePrivateKey(privateKey, for: "test_address"))
        
        // Test retrieval
        let retrievedKey = try keyManager.retrievePrivateKey(for: "test_address")
        XCTAssertEqual(retrievedKey, privateKey)
    }
    
    func testBiometricAuthentication() async throws {
        let biometricAuth = BiometricAuthManager()
        
        // Test biometric availability
        let isAvailable = biometricAuth.isBiometricsAvailable()
        XCTAssertTrue(isAvailable)
        
        // Test authentication (requires device)
        if isAvailable {
            XCTAssertNoThrow(try await biometricAuth.authenticateWithBiometrics())
        }
    }
    
    func testInputValidation() {
        // Test malicious inputs
        let maliciousInputs = [
            "javascript:alert('xss')",
            "<script>alert('xss')</script>",
            "'; DROP TABLE users; --",
            "../../../etc/passwd"
        ]
        
        for input in maliciousInputs {
            XCTAssertThrowsError(try validateUserInput(input)) { error in
                XCTAssertTrue(error is ValidationError)
            }
        }
    }
}
```

### Penetration Testing

```swift
final class PenetrationTests: XCTestCase {
    
    func testSQLInjectionPrevention() {
        let maliciousQueries = [
            "'; DROP TABLE wallets; --",
            "' OR '1'='1",
            "'; INSERT INTO wallets VALUES ('hacker', 'key'); --"
        ]
        
        for query in maliciousQueries {
            XCTAssertThrowsError(try executeQuery(query)) { error in
                XCTAssertTrue(error is SecurityError)
            }
        }
    }
    
    func testXSSPrevention() {
        let maliciousScripts = [
            "<script>alert('xss')</script>",
            "javascript:alert('xss')",
            "onload=\"alert('xss')\""
        ]
        
        for script in maliciousScripts {
            let sanitized = sanitizeInput(script)
            XCTAssertFalse(sanitized.contains("<script>"))
            XCTAssertFalse(sanitized.contains("javascript:"))
        }
    }
}
```

## 📱 UI Testing

### SwiftUI Testing

```swift
final class UITests: XCTestCase {
    
    func testWalletViewDisplay() {
        let wallet = Wallet(
            address: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            privateKey: "0x1234567890abcdef",
            network: .ethereum
        )
        
        let walletView = WalletView(wallet: wallet)
        let viewController = UIHostingController(rootView: walletView)
        
        // Test view loads
        viewController.loadViewIfNeeded()
        XCTAssertNotNil(viewController.view)
        
        // Test wallet address display
        let addressLabel = viewController.view.findSubview(with: "wallet_address_label")
        XCTAssertNotNil(addressLabel)
        XCTAssertEqual(addressLabel.text, wallet.address)
    }
    
    func testTransactionViewInteraction() {
        let transactionView = TransactionView()
        let viewController = UIHostingController(rootView: transactionView)
        
        viewController.loadViewIfNeeded()
        
        // Test button interaction
        let sendButton = viewController.view.findSubview(with: "send_button")
        XCTAssertNotNil(sendButton)
        
        // Simulate button tap
        sendButton.sendActions(for: .touchUpInside)
        
        // Verify action was triggered
        // (Implementation depends on your UI structure)
    }
}
```

### Accessibility Testing

```swift
final class AccessibilityTests: XCTestCase {
    
    func testVoiceOverSupport() {
        let walletView = WalletView()
        let viewController = UIHostingController(rootView: walletView)
        
        viewController.loadViewIfNeeded()
        
        // Test accessibility labels
        let addressLabel = viewController.view.findSubview(with: "wallet_address_label")
        XCTAssertNotNil(addressLabel?.accessibilityLabel)
        XCTAssertNotNil(addressLabel?.accessibilityHint)
        
        // Test accessibility traits
        let sendButton = viewController.view.findSubview(with: "send_button")
        XCTAssertTrue(sendButton?.accessibilityTraits.contains(.button) ?? false)
    }
    
    func testDynamicTypeSupport() {
        let walletView = WalletView()
        
        // Test with different text sizes
        let contentSizeCategories: [UIContentSizeCategory] = [
            .accessibilityExtraExtraExtraLarge,
            .accessibilityExtraExtraLarge,
            .accessibilityExtraLarge,
            .accessibilityLarge,
            .accessibilityMedium
        ]
        
        for category in contentSizeCategories {
            let traitCollection = UITraitCollection(preferredContentSizeCategory: category)
            let adaptedView = walletView.adaptToTraitCollection(traitCollection)
            
            // Verify view adapts properly
            XCTAssertNotNil(adaptedView)
        }
    }
}
```

## 📊 Test Coverage

### Coverage Reporting

```bash
# Generate coverage report
swift test --enable-code-coverage

# View coverage in Xcode
open Package.swift
# Then Product -> Show Test Coverage
```

### Coverage Targets

```swift
// Target coverage percentages
let coverageTargets = [
    "TransactionManager": 95.0,
    "WalletManager": 90.0,
    "UniswapManager": 85.0,
    "SecurityManager": 100.0, // Security critical
    "AddressValidator": 100.0, // Validation critical
    "EncryptionManager": 100.0 // Security critical
]

func testCoverageTargets() {
    for (component, target) in coverageTargets {
        let coverage = getCoverage(for: component)
        XCTAssertGreaterThanOrEqual(coverage, target, "\(component) coverage below target")
    }
}
```

## 🚀 Test Automation

### CI/CD Integration

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: '15.0'
    
    - name: Run Tests
      run: |
        swift test --enable-code-coverage
        
    - name: Upload Coverage
      uses: codecov/codecov-action@v3
      with:
        file: .build/debug/codecov/default.profdata
```

### Test Scripts

```bash
#!/bin/bash
# scripts/run-tests.sh

echo "Running unit tests..."
swift test --filter UnitTests

echo "Running integration tests..."
swift test --filter IntegrationTests

echo "Running performance tests..."
swift test --filter PerformanceTests

echo "Running security tests..."
swift test --filter SecurityTests

echo "Running UI tests..."
swift test --filter UITests

echo "All tests completed!"
```

## 📋 Testing Best Practices

### Test Organization

1. **Arrange-Act-Assert**: Structure tests clearly
2. **Given-When-Then**: Use descriptive test structure
3. **One assertion per test**: Keep tests focused
4. **Descriptive names**: Use clear test names
5. **Test isolation**: Each test should be independent

### Test Data Management

```swift
class TestData {
    static let validAddress = "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
    static let validPrivateKey = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
    static let validAmount = "0.1"
    
    static func createTestTransaction() -> Transaction {
        return Transaction(
            to: validAddress,
            value: validAmount,
            network: .ethereum
        )
    }
    
    static func createTestWallet() -> Wallet {
        return Wallet(
            address: validAddress,
            privateKey: validPrivateKey,
            network: .ethereum
        )
    }
}
```

### Mock Objects

```swift
class MockNetworkManager: NetworkManaging {
    var shouldFail = false
    var mockResponses: [String: Any] = [:]
    
    func sendRequest(_ request: NetworkRequest) async throws -> NetworkResponse {
        if shouldFail {
            throw NetworkError.connectionFailed
        }
        
        if let mockResponse = mockResponses[request.endpoint] {
            return NetworkResponse(data: mockResponse)
        }
        
        return NetworkResponse(data: "{}".data(using: .utf8)!)
    }
}
```

## 📚 Related Documentation

- [Wallet Management](API/WalletManagement.md)
- [Blockchain Integration](API/BlockchainIntegration.md)
- [Security Guidelines](Guides/Security.md)
- [Performance Optimization](Guides/Performance.md)

---

**Need help?** Check our [Support Guide](../../README.md#support) or create an [Issue](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/issues). 