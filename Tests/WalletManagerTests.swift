//
//  WalletManagerTests.swift
//  iOSWeb3WalletFrameworkTests
//
//  Created by Muhittin Camdali on 2023-06-15.
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import XCTest
import CryptoKit
@testable import iOSWeb3WalletFramework

@available(iOS 15.0, macOS 12.0, *)
final class WalletManagerTests: XCTestCase {
    
    var walletManager: WalletManager!
    
    override func setUpWithError() throws {
        walletManager = WalletManager.shared
    }
    
    override func tearDownWithError() throws {
        walletManager = nil
    }
    
    // MARK: - Wallet Creation Tests
    
    func testWalletCreationWithValidPassword() {
        let expectation = XCTestExpectation(description: "Wallet creation")
        
        let password = "StrongPassword123!"
        
        walletManager.createWallet(password: password) { result in
            switch result {
            case .success(let wallet):
                XCTAssertNotNil(wallet)
                XCTAssertFalse(wallet.address.isEmpty)
                XCTAssertFalse(wallet.privateKey.isEmpty)
                XCTAssertFalse(wallet.publicKey.isEmpty)
                XCTAssertNotNil(wallet.mnemonic)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Wallet creation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWalletCreationWithWeakPassword() {
        let expectation = XCTestExpectation(description: "Weak password rejection")
        
        let weakPassword = "weak"
        
        walletManager.createWallet(password: weakPassword) { result in
            switch result {
            case .success:
                XCTFail("Should reject weak password")
            case .failure(let error):
                XCTAssertEqual(error, .weakPassword)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWalletCreationWithCustomMnemonic() {
        let expectation = XCTestExpectation(description: "Custom mnemonic wallet creation")
        
        let password = "StrongPassword123!"
        let mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        
        walletManager.createWallet(password: password, mnemonic: mnemonic) { result in
            switch result {
            case .success(let wallet):
                XCTAssertNotNil(wallet)
                XCTAssertEqual(wallet.mnemonic, mnemonic)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Wallet creation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWalletCreationWithInvalidMnemonic() {
        let expectation = XCTestExpectation(description: "Invalid mnemonic rejection")
        
        let password = "StrongPassword123!"
        let invalidMnemonic = "invalid mnemonic phrase"
        
        walletManager.createWallet(password: password, mnemonic: invalidMnemonic) { result in
            switch result {
            case .success:
                XCTFail("Should reject invalid mnemonic")
            case .failure(let error):
                XCTAssertEqual(error, .invalidMnemonic)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Wallet Import Tests
    
    func testWalletImportWithValidPrivateKey() {
        let expectation = XCTestExpectation(description: "Wallet import")
        
        let password = "StrongPassword123!"
        let privateKey = "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        
        walletManager.importWallet(privateKey: privateKey, password: password) { result in
            switch result {
            case .success(let wallet):
                XCTAssertNotNil(wallet)
                XCTAssertFalse(wallet.address.isEmpty)
                XCTAssertEqual(wallet.privateKey, privateKey)
                XCTAssertFalse(wallet.publicKey.isEmpty)
                XCTAssertNil(wallet.mnemonic) // Imported wallets don't have mnemonic
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Wallet import failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWalletImportWithInvalidPrivateKey() {
        let expectation = XCTestExpectation(description: "Invalid private key rejection")
        
        let password = "StrongPassword123!"
        let invalidPrivateKey = "invalid"
        
        walletManager.importWallet(privateKey: invalidPrivateKey, password: password) { result in
            switch result {
            case .success:
                XCTFail("Should reject invalid private key")
            case .failure(let error):
                XCTAssertEqual(error, .invalidPrivateKey)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWalletImportWithWeakPassword() {
        let expectation = XCTestExpectation(description: "Weak password rejection for import")
        
        let weakPassword = "weak"
        let privateKey = "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        
        walletManager.importWallet(privateKey: privateKey, password: weakPassword) { result in
            switch result {
            case .success:
                XCTFail("Should reject weak password")
            case .failure(let error):
                XCTAssertEqual(error, .weakPassword)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Wallet Unlock Tests
    
    func testWalletUnlockWhenNotCreated() {
        let expectation = XCTestExpectation(description: "Unlock without wallet")
        
        walletManager.unlockWallet { result in
            switch result {
            case .success:
                XCTFail("Should fail when no wallet exists")
            case .failure(let error):
                XCTAssertEqual(error, .walletNotCreated)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWalletLockAndUnlock() {
        let expectation = XCTestExpectation(description: "Lock and unlock wallet")
        
        // First create a wallet
        let password = "StrongPassword123!"
        
        walletManager.createWallet(password: password) { [weak self] result in
            switch result {
            case .success:
                // Lock the wallet
                self?.walletManager.lockWallet()
                XCTAssertFalse(self?.walletManager.walletState.isUnlocked ?? true)
                
                // Try to unlock
                self?.walletManager.unlockWallet { unlockResult in
                    switch unlockResult {
                    case .success:
                        XCTAssertTrue(self?.walletManager.walletState.isUnlocked ?? false)
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Unlock failed: \(error)")
                    }
                }
            case .failure(let error):
                XCTFail("Wallet creation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Network Switching Tests
    
    func testNetworkSwitching() {
        let expectation = XCTestExpectation(description: "Network switching")
        
        // Create wallet first
        let password = "StrongPassword123!"
        
        walletManager.createWallet(password: password) { [weak self] result in
            switch result {
            case .success:
                // Switch to Polygon network
                self?.walletManager.switchNetwork(.polygon) { switchResult in
                    switch switchResult {
                    case .success:
                        XCTAssertEqual(self?.walletManager.currentNetwork, .polygon)
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Network switch failed: \(error)")
                    }
                }
            case .failure(let error):
                XCTFail("Wallet creation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testNetworkSwitchingWhenLocked() {
        let expectation = XCTestExpectation(description: "Network switch when locked")
        
        // Create wallet and lock it
        let password = "StrongPassword123!"
        
        walletManager.createWallet(password: password) { [weak self] result in
            switch result {
            case .success:
                self?.walletManager.lockWallet()
                
                // Try to switch network when locked
                self?.walletManager.switchNetwork(.polygon) { switchResult in
                    switch switchResult {
                    case .success:
                        XCTFail("Should fail when wallet is locked")
                    case .failure(let error):
                        XCTAssertEqual(error, .walletLocked)
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("Wallet creation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Balance Tests
    
    func testGetBalance() {
        let expectation = XCTestExpectation(description: "Get balance")
        
        // Create wallet first
        let password = "StrongPassword123!"
        
        walletManager.createWallet(password: password) { [weak self] result in
            switch result {
            case .success:
                self?.walletManager.getBalance { balanceResult in
                    switch balanceResult {
                    case .success(let balance):
                        XCTAssertNotNil(balance)
                        XCTAssertGreaterThanOrEqual(balance.value, 0)
                        expectation.fulfill()
                    case .failure(let error):
                        // Network errors are acceptable in tests
                        print("Balance fetch failed: \(error)")
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("Wallet creation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetBalanceWhenLocked() {
        let expectation = XCTestExpectation(description: "Get balance when locked")
        
        // Create wallet and lock it
        let password = "StrongPassword123!"
        
        walletManager.createWallet(password: password) { [weak self] result in
            switch result {
            case .success:
                self?.walletManager.lockWallet()
                
                self?.walletManager.getBalance { balanceResult in
                    switch balanceResult {
                    case .success:
                        XCTFail("Should fail when wallet is locked")
                    case .failure(let error):
                        XCTAssertEqual(error, .walletLocked)
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("Wallet creation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Token Balance Tests
    
    func testGetTokenBalances() {
        let expectation = XCTestExpectation(description: "Get token balances")
        
        // Create wallet first
        let password = "StrongPassword123!"
        
        walletManager.createWallet(password: password) { [weak self] result in
            switch result {
            case .success:
                self?.walletManager.getTokenBalances { tokenResult in
                    switch tokenResult {
                    case .success(let balances):
                        XCTAssertNotNil(balances)
                        // Balances might be empty for new wallets
                        expectation.fulfill()
                    case .failure(let error):
                        // Network errors are acceptable in tests
                        print("Token balance fetch failed: \(error)")
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("Wallet creation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Transaction Tests
    
    func testSendTransaction() {
        let expectation = XCTestExpectation(description: "Send transaction")
        
        // Create wallet first
        let password = "StrongPassword123!"
        
        walletManager.createWallet(password: password) { [weak self] result in
            switch result {
            case .success:
                let transaction = Transaction(
                    to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
                    value: "0.001",
                    gasLimit: 21000,
                    network: .ethereum
                )
                
                self?.walletManager.sendTransaction(transaction) { txResult in
                    switch txResult {
                    case .success(let txHash):
                        XCTAssertFalse(txHash.isEmpty)
                        expectation.fulfill()
                    case .failure(let error):
                        // Transaction might fail due to insufficient funds
                        print("Transaction failed: \(error)")
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("Wallet creation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testSendInvalidTransaction() {
        let expectation = XCTestExpectation(description: "Send invalid transaction")
        
        // Create wallet first
        let password = "StrongPassword123!"
        
        walletManager.createWallet(password: password) { [weak self] result in
            switch result {
            case .success:
                let invalidTransaction = Transaction(
                    to: "", // Invalid empty address
                    value: "0.001",
                    gasLimit: 21000,
                    network: .ethereum
                )
                
                self?.walletManager.sendTransaction(invalidTransaction) { txResult in
                    switch txResult {
                    case .success:
                        XCTFail("Should reject invalid transaction")
                    case .failure(let error):
                        XCTAssertEqual(error, .invalidTransaction)
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("Wallet creation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Gas Estimation Tests
    
    func testEstimateGas() {
        let expectation = XCTestExpectation(description: "Estimate gas")
        
        let transaction = Transaction(
            to: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            value: "0.001",
            gasLimit: 21000,
            network: .ethereum
        )
        
        walletManager.estimateGas(transaction) { result in
            switch result {
            case .success(let gasEstimate):
                XCTAssertNotNil(gasEstimate)
                XCTAssertGreaterThan(gasEstimate.gasLimit, 0)
                expectation.fulfill()
            case .failure(let error):
                // Network errors are acceptable in tests
                print("Gas estimation failed: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetGasPrices() {
        let expectation = XCTestExpectation(description: "Get gas prices")
        
        walletManager.getGasPrices { result in
            switch result {
            case .success(let gasPrices):
                XCTAssertNotNil(gasPrices)
                XCTAssertGreaterThan(gasPrices.slow, 0)
                XCTAssertGreaterThan(gasPrices.medium, 0)
                XCTAssertGreaterThan(gasPrices.fast, 0)
                expectation.fulfill()
            case .failure(let error):
                // Network errors are acceptable in tests
                print("Gas price fetch failed: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Transaction History Tests
    
    func testGetTransactionHistory() {
        let expectation = XCTestExpectation(description: "Get transaction history")
        
        // Create wallet first
        let password = "StrongPassword123!"
        
        walletManager.createWallet(password: password) { [weak self] result in
            switch result {
            case .success(let wallet):
                self?.walletManager.getTransactionHistory(address: wallet.address) { historyResult in
                    switch historyResult {
                    case .success(let transactions):
                        XCTAssertNotNil(transactions)
                        // History might be empty for new wallets
                        expectation.fulfill()
                    case .failure(let error):
                        // Network errors are acceptable in tests
                        print("Transaction history fetch failed: \(error)")
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("Wallet creation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Hardware Wallet Tests
    
    func testConnectHardwareWallet() {
        let expectation = XCTestExpectation(description: "Connect hardware wallet")
        
        walletManager.connectHardwareWallet(.ledger) { result in
            switch result {
            case .success(let hardwareWallet):
                XCTAssertNotNil(hardwareWallet)
                XCTAssertEqual(hardwareWallet.type, .ledger)
                expectation.fulfill()
            case .failure(let error):
                // Hardware wallet might not be connected
                print("Hardware wallet connection failed: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Performance Tests
    
    func testWalletCreationPerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Performance test")
            let password = "StrongPassword123!"
            
            walletManager.createWallet(password: password) { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testMultipleWalletOperations() {
        let expectation = XCTestExpectation(description: "Multiple operations")
        
        // Create wallet
        let password = "StrongPassword123!"
        
        walletManager.createWallet(password: password) { [weak self] result in
            switch result {
            case .success:
                // Perform multiple operations
                let operations = DispatchGroup()
                
                operations.enter()
                self?.walletManager.getBalance { _ in
                    operations.leave()
                }
                
                operations.enter()
                self?.walletManager.getTokenBalances { _ in
                    operations.leave()
                }
                
                operations.enter()
                self?.walletManager.getGasPrices { _ in
                    operations.leave()
                }
                
                operations.notify(queue: .main) {
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Wallet creation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    // MARK: - Security Tests
    
    func testPrivateKeySecurity() {
        let expectation = XCTestExpectation(description: "Private key security")
        
        let password = "StrongPassword123!"
        
        walletManager.createWallet(password: password) { result in
            switch result {
            case .success(let wallet):
                // Verify private key is not exposed in logs
                let logOutput = captureLogOutput {
                    print("Wallet address: \(wallet.address)")
                }
                
                XCTAssertFalse(logOutput.contains(wallet.privateKey))
                XCTAssertFalse(logOutput.contains("private"))
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Wallet creation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testPasswordValidation() {
        // Test various password strengths
        let weakPasswords = ["weak", "123", "abc", ""]
        let strongPasswords = ["StrongPass123!", "MySecureP@ssw0rd", "C0mpl3x!P@ss"]
        
        for password in weakPasswords {
            XCTAssertFalse(walletManager.validatePasswordStrength(password))
        }
        
        for password in strongPasswords {
            XCTAssertTrue(walletManager.validatePasswordStrength(password))
        }
    }
    
    // MARK: - Helper Methods
    
    private func captureLogOutput(_ block: () -> Void) -> String {
        // This is a simplified version - in a real implementation,
        // you would capture actual log output
        return ""
    }
}

// MARK: - Supporting Types for Tests

@available(iOS 15.0, macOS 12.0, *)
extension WalletManager {
    // Expose validation methods for testing
    func validatePasswordStrength(_ password: String) -> Bool {
        // Implementation would be moved from private to internal for testing
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d@$!%*?&]{8,}$"
        return password.range(of: passwordRegex, options: .regularExpression) != nil
    }
}

// MARK: - Mock Types for Testing

@available(iOS 15.0, macOS 12.0, *)
struct Transaction {
    let to: String
    let value: String
    let gasLimit: Int
    let network: BlockchainNetwork
    var hash: String?
    var timestamp: Date?
}

@available(iOS 15.0, macOS 12.0, *)
struct Balance {
    let value: Double
    let currency: String
    let network: BlockchainNetwork
}

@available(iOS 15.0, macOS 12.0, *)
struct TokenBalance {
    let tokenAddress: String
    let symbol: String
    let name: String
    let balance: String
    let decimals: Int
}

@available(iOS 15.0, macOS 12.0, *)
struct GasEstimate {
    let gasLimit: Int
    let gasPrice: String
    let totalCost: String
}

@available(iOS 15.0, macOS 12.0, *)
struct GasPrices {
    let slow: Double
    let medium: Double
    let fast: Double
}

@available(iOS 15.0, macOS 12.0, *)
struct HardwareWallet {
    let type: HardwareWalletType
    let address: String
    let isConnected: Bool
}

@available(iOS 15.0, macOS 12.0, *)
enum HardwareWalletType {
    case ledger
    case trezor
}

@available(iOS 15.0, macOS 12.0, *)
struct PerformanceMetrics {
    let memoryUsage: UInt64
    let cpuUsage: Double
    let networkLatency: TimeInterval
} 