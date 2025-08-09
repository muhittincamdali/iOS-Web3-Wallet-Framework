# 🎪 iOS Web3 Wallet Framework Examples

<!-- TOC START -->
## Table of Contents
- [🎪 iOS Web3 Wallet Framework Examples](#-ios-web3-wallet-framework-examples)
- [📱 Available Examples](#-available-examples)
  - [🔐 Basic Wallet](#-basic-wallet)
  - [💰 DeFi App](#-defi-app)
  - [🖼️ NFT Gallery](#-nft-gallery)
- [🚀 Getting Started with Examples](#-getting-started-with-examples)
  - [Prerequisites](#prerequisites)
  - [Quick Start](#quick-start)
  - [Example Structure](#example-structure)
- [🎯 Example Features](#-example-features)
  - [🔐 Basic Wallet Example](#-basic-wallet-example)
  - [💰 DeFi App Example](#-defi-app-example)
  - [🖼️ NFT Gallery Example](#-nft-gallery-example)
- [🛠️ Customizing Examples](#-customizing-examples)
  - [Adding New Features](#adding-new-features)
  - [Styling and Theming](#styling-and-theming)
- [📚 Learning Path](#-learning-path)
  - [🥇 Beginner Level](#-beginner-level)
  - [🥈 Intermediate Level](#-intermediate-level)
  - [🥉 Advanced Level](#-advanced-level)
- [🔧 Configuration](#-configuration)
  - [Environment Setup](#environment-setup)
  - [Network Configuration](#network-configuration)
- [🧪 Testing Examples](#-testing-examples)
  - [Running Tests](#running-tests)
- [Run all tests](#run-all-tests)
- [Run specific example tests](#run-specific-example-tests)
  - [Test Coverage](#test-coverage)
- [📱 Deployment](#-deployment)
  - [App Store Deployment](#app-store-deployment)
  - [TestFlight Distribution](#testflight-distribution)
- [🤝 Contributing Examples](#-contributing-examples)
  - [Creating a New Example](#creating-a-new-example)
  - [Example Guidelines](#example-guidelines)
- [📄 License](#-license)
- [🆘 Support](#-support)
  - [Getting Help](#getting-help)
  - [Common Issues](#common-issues)
<!-- TOC END -->


This directory contains comprehensive examples demonstrating how to use the iOS Web3 Wallet Framework in real-world applications.

## 📱 Available Examples

### 🔐 Basic Wallet
**Location**: `BasicWallet/`

A simple wallet application demonstrating core wallet functionality:
- ✅ Wallet creation and import
- ✅ Multi-chain support
- ✅ Transaction sending
- ✅ Balance checking
- ✅ Network switching

**Key Features**:
- Clean, modern UI with SwiftUI
- Real-time balance updates
- Transaction history
- Network selection
- Address validation

**Perfect for**: Beginners learning Web3 wallet development

### 💰 DeFi App
**Location**: `DeFiApp/`

A comprehensive DeFi application showcasing advanced features:
- ✅ Uniswap token swaps
- ✅ Liquidity pool management
- ✅ Yield farming
- ✅ Portfolio tracking
- ✅ Price charts

**Key Features**:
- Token swap interface
- Liquidity pool operations
- Yield farming strategies
- Portfolio management
- Real-time price feeds

**Perfect for**: Developers building DeFi applications

### 🖼️ NFT Gallery
**Location**: `NFTGallery/`

An NFT management application with advanced features:
- ✅ NFT viewing and management
- ✅ Marketplace integration
- ✅ Collection organization
- ✅ Metadata handling
- ✅ Transfer functionality

**Key Features**:
- NFT gallery interface
- Collection management
- Marketplace integration
- Metadata display
- Transfer operations

**Perfect for**: NFT-focused applications

## 🚀 Getting Started with Examples

### Prerequisites
- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+
- iOS Web3 Wallet Framework installed

### Quick Start

1. **Clone the repository**:
```bash
git clone https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework.git
cd iOS-Web3-Wallet-Framework
```

2. **Open in Xcode**:
```bash
open Package.swift
```

3. **Run an example**:
- Select your target device
- Choose an example from the scheme selector
- Build and run

### Example Structure

Each example follows this structure:
```
ExampleName/
├── ExampleName.swift          # Main example view
├── Components/                # Reusable components
│   ├── Component1.swift
│   └── Component2.swift
├── Models/                    # Data models
│   └── ExampleModel.swift
├── Services/                  # Business logic
│   └── ExampleService.swift
└── README.md                 # Example-specific documentation
```

## 🎯 Example Features

### 🔐 Basic Wallet Example

```swift
import SwiftUI
import iOSWeb3WalletFramework

struct BasicWalletExample: View {
    @StateObject private var walletManager = WalletManager()
    @StateObject private var transactionManager = TransactionManager()
    
    var body: some View {
        // Wallet interface
    }
}
```

**Key Components**:
- `WalletManager`: Core wallet operations
- `TransactionManager`: Transaction handling
- Network switching
- Balance display
- Transaction history

### 💰 DeFi App Example

```swift
import SwiftUI
import iOSWeb3WalletFramework

struct DeFiAppExample: View {
    @StateObject private var uniswapManager = UniswapManager()
    @StateObject private var walletManager = WalletManager()
    
    var body: some View {
        // DeFi interface
    }
}
```

**Key Components**:
- `UniswapManager`: Token swaps and liquidity
- `WalletManager`: Wallet integration
- Price charts
- Portfolio tracking
- Yield farming

### 🖼️ NFT Gallery Example

```swift
import SwiftUI
import iOSWeb3WalletFramework

struct NFTGalleryExample: View {
    @StateObject private var nftManager = NFTManager()
    @StateObject private var walletManager = WalletManager()
    
    var body: some View {
        // NFT gallery interface
    }
}
```

**Key Components**:
- `NFTManager`: NFT operations
- `WalletManager`: Wallet integration
- Gallery interface
- Collection management
- Marketplace integration

## 🛠️ Customizing Examples

### Adding New Features

1. **Create a new component**:
```swift
struct CustomComponent: View {
    var body: some View {
        // Your custom UI
    }
}
```

2. **Integrate with framework**:
```swift
@StateObject private var frameworkManager = FrameworkManager()
```

3. **Add to your example**:
```swift
struct YourExample: View {
    var body: some View {
        CustomComponent()
    }
}
```

### Styling and Theming

All examples support:
- **Dark/Light Mode**: Automatic theme switching
- **Custom Colors**: Brand-specific theming
- **Accessibility**: VoiceOver and Dynamic Type support
- **Responsive Design**: Adapts to different screen sizes

## 📚 Learning Path

### 🥇 Beginner Level
1. Start with **Basic Wallet Example**
2. Understand wallet creation and management
3. Learn transaction sending
4. Explore network switching

### 🥈 Intermediate Level
1. Study **DeFi App Example**
2. Learn token swapping
3. Understand liquidity pools
4. Explore yield farming

### 🥉 Advanced Level
1. Master **NFT Gallery Example**
2. Implement custom DeFi features
3. Create advanced UI components
4. Optimize performance

## 🔧 Configuration

### Environment Setup

Each example can be configured for different environments:

```swift
// Development
let config = FrameworkConfig(
    network: .ethereum,
    environment: .development,
    rpcUrl: "https://mainnet.infura.io/v3/YOUR_KEY"
)

// Production
let config = FrameworkConfig(
    network: .ethereum,
    environment: .production,
    rpcUrl: "https://mainnet.infura.io/v3/PROD_KEY"
)
```

### Network Configuration

Examples support multiple networks:

```swift
enum SupportedNetwork: String, CaseIterable {
    case ethereum = "Ethereum"
    case polygon = "Polygon"
    case binanceSmartChain = "BSC"
    case arbitrum = "Arbitrum"
    case optimism = "Optimism"
}
```

## 🧪 Testing Examples

### Running Tests

```bash
# Run all tests
swift test

# Run specific example tests
swift test --filter BasicWalletExampleTests
```

### Test Coverage

Each example includes:
- ✅ Unit tests
- ✅ Integration tests
- ✅ UI tests
- ✅ Performance tests

## 📱 Deployment

### App Store Deployment

1. **Configure signing**:
   - Add your development team
   - Configure bundle identifier
   - Set up provisioning profiles

2. **Update configuration**:
   - Set production environment
   - Configure production RPC endpoints
   - Update app metadata

3. **Build and archive**:
   - Select "Any iOS Device"
   - Archive the project
   - Upload to App Store Connect

### TestFlight Distribution

1. **Create build**:
   - Archive the project
   - Upload to TestFlight
   - Configure testing groups

2. **Distribute**:
   - Add testers
   - Configure build notes
   - Monitor feedback

## 🤝 Contributing Examples

We welcome new examples! Here's how to contribute:

### Creating a New Example

1. **Create directory structure**:
```
Examples/YourExample/
├── YourExample.swift
├── Components/
├── Models/
├── Services/
└── README.md
```

2. **Follow naming conventions**:
- Use descriptive names
- Follow Swift naming guidelines
- Include proper documentation

3. **Add tests**:
- Unit tests for logic
- UI tests for interface
- Integration tests for framework

4. **Document your example**:
- Clear README
- Code comments
- Usage instructions

### Example Guidelines

- **Simplicity**: Keep examples focused and clear
- **Completeness**: Include all necessary code
- **Best Practices**: Follow iOS development guidelines
- **Accessibility**: Support VoiceOver and Dynamic Type
- **Performance**: Optimize for smooth operation

## 📄 License

Examples are licensed under the MIT License. See the [LICENSE](../../LICENSE) file for details.

## 🆘 Support

### Getting Help

- **Documentation**: Check the main [README](../../README.md)
- **Issues**: Create an [Issue](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/issues)
- **Discussions**: Join [GitHub Discussions](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/discussions)

### Common Issues

1. **Build Errors**: Check Swift and iOS version requirements
2. **Runtime Errors**: Verify network configuration
3. **UI Issues**: Ensure proper SwiftUI setup
4. **Performance**: Monitor memory usage and optimize

---

**Ready to build amazing Web3 apps?** Start with our examples and create something incredible! 🚀 