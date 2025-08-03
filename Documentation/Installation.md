# Installation Guide

## Prerequisites

Before installing the iOS Web3 Wallet Framework, ensure you have the following:

- **Xcode 15.0+** (Latest version recommended)
- **iOS 15.0+** deployment target
- **Swift 5.9+**
- **macOS 12.0+** (for development)

## Installation Methods

### Swift Package Manager (Recommended)

The Swift Package Manager is the recommended way to install the framework.

#### 1. Add Package Dependency

In Xcode:
1. Go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework.git`
3. Click **Add Package**
4. Select the target where you want to add the framework

#### 2. Add to Package.swift

If you're using a Package.swift file:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YourApp",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: [
                "Web3Wallet",
                "Web3WalletCore",
                "Web3WalletDeFi",
                "Web3WalletSecurity",
                "Web3WalletUI"
            ]
        )
    ]
)
```

### CocoaPods

#### 1. Install CocoaPods

If you haven't installed CocoaPods yet:

```bash
sudo gem install cocoapods
```

#### 2. Create Podfile

Create a `Podfile` in your project directory:

```ruby
platform :ios, '15.0'
use_frameworks!

target 'YourApp' do
  pod 'iOSWeb3WalletFramework', '~> 1.0.0'
end
```

#### 3. Install Dependencies

```bash
pod install
```

#### 4. Open Workspace

Always open the `.xcworkspace` file instead of the `.xcodeproj` file:

```bash
open YourApp.xcworkspace
```

### Carthage

#### 1. Install Carthage

If you haven't installed Carthage yet:

```bash
brew install carthage
```

#### 2. Create Cartfile

Create a `Cartfile` in your project directory:

```ruby
github "muhittincamdali/iOS-Web3-Wallet-Framework" ~> 1.0.0
```

#### 3. Install Dependencies

```bash
carthage update
```

#### 4. Link Frameworks

1. Drag the built frameworks from `Carthage/Build/iOS/` to your project
2. Add them to your target's "Frameworks, Libraries, and Embedded Content"
3. Set "Embed & Sign" for each framework

## Configuration

### 1. Import the Framework

```swift
import Web3Wallet
import Web3WalletCore
import Web3WalletDeFi
import Web3WalletSecurity
import Web3WalletUI
```

### 2. Initialize the Framework

```swift
import Web3Wallet

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure the framework
        Web3WalletConfig.shared.configure(
            environment: .development,
            apiKey: "your_api_key_here",
            networkTimeout: 30.0
        )
        
        return true
    }
}
```

### 3. Configure Networks

```swift
import Web3Wallet

class NetworkConfiguration {
    
    static func configureNetworks() {
        let networkManager = NetworkManager.shared
        
        // Ethereum Mainnet
        let ethereumConfig = NetworkConfig(
            chainId: 1,
            name: "Ethereum Mainnet",
            rpcUrl: "https://mainnet.infura.io/v3/YOUR_PROJECT_ID",
            explorerUrl: "https://etherscan.io"
        )
        
        // Polygon Mainnet
        let polygonConfig = NetworkConfig(
            chainId: 137,
            name: "Polygon Mainnet",
            rpcUrl: "https://polygon-rpc.com",
            explorerUrl: "https://polygonscan.com"
        )
        
        // Binance Smart Chain
        let bscConfig = NetworkConfig(
            chainId: 56,
            name: "Binance Smart Chain",
            rpcUrl: "https://bsc-dataseed.binance.org",
            explorerUrl: "https://bscscan.com"
        )
        
        networkManager.configureNetworks([ethereumConfig, polygonConfig, bscConfig])
    }
}
```

### 4. Setup Security

```swift
import Web3Wallet

class SecuritySetup {
    
    static func configureSecurity() {
        let securityManager = SecurityManager.shared
        
        // Enable biometric authentication
        securityManager.enableBiometricAuthentication()
        
        // Configure secure storage
        securityManager.configureSecureStorage()
        
        // Setup hardware wallet support
        securityManager.enableHardwareWalletSupport()
    }
}
```

## Permissions

### 1. Add Required Permissions

Add the following to your `Info.plist`:

```xml
<!-- Biometric Authentication -->
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID to securely access your wallet</string>

<!-- Camera (for QR code scanning) -->
<key>NSCameraUsageDescription</key>
<string>This app uses the camera to scan QR codes for wallet addresses</string>

<!-- Photo Library (for importing wallet files) -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app accesses your photo library to import wallet files</string>

<!-- Network Access -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 2. Add Capabilities

In Xcode:
1. Select your target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add the following capabilities:
   - **Keychain Sharing**
   - **Background Modes** (if needed for background sync)

## Basic Setup Example

Here's a complete setup example:

```swift
import UIKit
import Web3Wallet

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 1. Configure the framework
        Web3WalletConfig.shared.configure(
            environment: .development,
            apiKey: "your_api_key_here",
            networkTimeout: 30.0
        )
        
        // 2. Configure networks
        NetworkConfiguration.configureNetworks()
        
        // 3. Setup security
        SecuritySetup.configureSecurity()
        
        // 4. Initialize storage
        StorageManager.shared.initialize()
        
        return true
    }
}
```

## Verification

### 1. Test Installation

Create a simple test to verify the installation:

```swift
import XCTest
import Web3Wallet

class InstallationTests: XCTestCase {
    
    func testFrameworkInstallation() {
        // Test that we can create a wallet manager
        let walletManager = Web3WalletManager()
        XCTAssertNotNil(walletManager)
        
        // Test that we can create a DeFi manager
        let defiManager = DeFiManager()
        XCTAssertNotNil(defiManager)
        
        // Test that we can create a security manager
        let securityManager = SecurityManager.shared
        XCTAssertNotNil(securityManager)
    }
}
```

### 2. Test Basic Functionality

```swift
import Web3Wallet

class BasicFunctionalityTest {
    
    static func testBasicFunctionality() async {
        let walletManager = Web3WalletManager()
        
        do {
            // Test wallet creation
            let wallet = try await walletManager.createWallet(
                name: "Test Wallet",
                password: "testPassword"
            )
            
            print("✅ Wallet created successfully: \(wallet.address)")
            
            // Test getting wallets
            let wallets = try await walletManager.getWallets()
            print("✅ Retrieved \(wallets.count) wallets")
            
            // Test network configuration
            let networkManager = NetworkManager.shared
            let ethereumConfig = networkManager.getNetworkConfig(for: .ethereum)
            print("✅ Network configuration: \(ethereumConfig?.name ?? "Not configured")")
            
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
```

## Troubleshooting

### Common Installation Issues

#### 1. Build Errors

**Error**: `No such module 'Web3Wallet'`

**Solution**:
- Clean build folder: **Product** → **Clean Build Folder**
- Reset package caches: **File** → **Packages** → **Reset Package Caches**
- Close Xcode and reopen the project

#### 2. Swift Version Issues

**Error**: `Swift version mismatch`

**Solution**:
- Ensure you're using Swift 5.9+
- Update Xcode to the latest version
- Check the deployment target is iOS 15.0+

#### 3. Dependency Conflicts

**Error**: `Multiple targets produce the same output`

**Solution**:
- Remove duplicate dependencies
- Check for conflicting versions
- Use the latest compatible versions

#### 4. Permission Issues

**Error**: `Keychain access denied`

**Solution**:
- Add Keychain Sharing capability
- Check app entitlements
- Verify code signing

### Debug Mode

Enable debug mode for troubleshooting:

```swift
// Enable debug logging
Web3WalletConfig.shared.enableDebugMode()

// Check configuration
print("Environment: \(Web3WalletConfig.shared.environment)")
print("API Key: \(Web3WalletConfig.shared.apiKey)")
print("Network Timeout: \(Web3WalletConfig.shared.networkTimeout)")
```

### Network Connectivity

Test network connectivity:

```swift
import Web3Wallet

class NetworkTest {
    
    static func testNetworkConnectivity() async {
        let networkManager = NetworkManager.shared
        
        do {
            let gasPrice = try await networkManager.getGasPrice(for: .ethereum)
            print("✅ Network connectivity: Gas price = \(gasPrice)")
        } catch {
            print("❌ Network error: \(error)")
        }
    }
}
```

## Migration from Previous Versions

### From v0.9.0 to v1.0.0

1. **Update Package Dependencies**:
   ```swift
   // Old
   .package(url: "...", from: "0.9.0")
   
   // New
   .package(url: "...", from: "1.0.0")
   ```

2. **Update Import Statements**:
   ```swift
   // Old
   import Web3Wallet
   
   // New (same, but with additional modules)
   import Web3Wallet
   import Web3WalletCore
   import Web3WalletDeFi
   import Web3WalletSecurity
   import Web3WalletUI
   ```

3. **Update API Calls**:
   ```swift
   // Old (synchronous)
   let wallet = walletManager.createWalletSync(name: "Wallet", password: "password")
   
   // New (asynchronous)
   let wallet = try await walletManager.createWallet(name: "Wallet", password: "password")
   ```

### From v0.8.0 to v0.9.0

1. **Update Transaction Creation**:
   ```swift
   // Old
   let transaction = Transaction(from: from, to: to, value: value)
   
   // New
   let transaction = Transaction(
       from: from,
       to: to,
       value: value,
       gasLimit: 21000,
       chain: .ethereum
   )
   ```

## Support

If you encounter any issues during installation:

1. **Check the [Documentation](Documentation/)**
2. **Search [GitHub Issues](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/issues)**
3. **Ask in [GitHub Discussions](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/discussions)**
4. **Contact support**: support@web3wallet.com

## Next Steps

After successful installation:

1. **Read the [API Documentation](API.md)**
2. **Check out the [Examples](Examples/)**
3. **Review [Security Best Practices](Security.md)**
4. **Explore [DeFi Integration](DeFi.md)**

---

*For the latest updates and breaking changes, please check the [CHANGELOG.md](../CHANGELOG.md).* 