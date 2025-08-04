# 💰 DeFi Protocols

The DeFi Protocols API provides comprehensive integration with popular DeFi protocols including Uniswap, Aave, and Compound.

## 📋 Overview

The framework includes dedicated managers for each DeFi protocol:

- ✅ **UniswapManager**: Token swaps and liquidity management
- ✅ **AaveManager**: Lending and borrowing protocols
- ✅ **CompoundManager**: Interest-bearing protocols
- ✅ **YieldFarmingManager**: Automated yield optimization

## 🚀 Quick Start

### Uniswap Token Swap

```swift
import iOSWeb3WalletFramework

// Create Uniswap manager
let uniswapManager = UniswapManager()

// Perform a token swap
let swap = UniswapSwap(
    tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", // WETH
    tokenOut: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8", // USDC
    amountIn: "1.0",
    slippageTolerance: 0.5,
    recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
    deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
)

uniswapManager.swap(swap) { result in
    switch result {
    case .success(let txHash):
        print("Swap completed: \(txHash)")
    case .failure(let error):
        print("Swap failed: \(error)")
    }
}
```

### Aave Lending

```swift
// Create Aave manager
let aaveManager = AaveManager()

// Supply assets
let supply = AaveSupply(
    asset: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8", // USDC
    amount: "1000",
    onBehalfOf: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
)

aaveManager.supply(supply) { result in
    switch result {
    case .success(let txHash):
        print("Supply completed: \(txHash)")
    case .failure(let error):
        print("Supply failed: \(error)")
    }
}
```

## 📚 API Reference

### UniswapManager

The main class for Uniswap operations.

#### Initialization

```swift
// Default initialization
let uniswapManager = UniswapManager()

// Custom configuration
let uniswapManager = UniswapManager(
    version: .v4,
    network: .ethereum,
    customRPC: "https://mainnet.infura.io/v3/YOUR_KEY"
)
```

#### Methods

##### swap

Performs a token swap on Uniswap.

```swift
func swap(_ swap: UniswapSwap, completion: @escaping (Result<String, SwapError>) -> Void)
```

**Example:**
```swift
let swap = UniswapSwap(
    tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
    tokenOut: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
    amountIn: "1.0",
    slippageTolerance: 0.5,
    recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
    deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
)

uniswapManager.swap(swap) { result in
    switch result {
    case .success(let txHash):
        print("Swap completed: \(txHash)")
    case .failure(let error):
        print("Swap failed: \(error)")
    }
}
```

##### addLiquidity

Adds liquidity to a Uniswap pool.

```swift
func addLiquidity(_ liquidity: AddLiquidityParams, completion: @escaping (Result<String, LiquidityError>) -> Void)
```

**Example:**
```swift
let liquidity = AddLiquidityParams(
    tokenA: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
    tokenB: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
    amountA: "1.0",
    amountB: "1000",
    fee: 3000,
    recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
    deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
)

uniswapManager.addLiquidity(liquidity) { result in
    switch result {
    case .success(let txHash):
        print("Liquidity added: \(txHash)")
    case .failure(let error):
        print("Add liquidity failed: \(error)")
    }
}
```

##### getSwapQuote

Gets a quote for a token swap.

```swift
func getSwapQuote(_ swap: UniswapSwap) async throws -> SwapQuote
```

**Example:**
```swift
let swap = UniswapSwap(
    tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
    tokenOut: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
    amountIn: "1.0",
    slippageTolerance: 0.5,
    recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
    deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
)

do {
    let quote = try await uniswapManager.getSwapQuote(swap)
    print("Amount out: \(quote.amountOut)")
    print("Price impact: \(quote.priceImpact)")
    print("Fee: \(quote.fee)")
} catch {
    print("Failed to get quote: \(error)")
}
```

### AaveManager

The main class for Aave operations.

#### Methods

##### supply

Supplies assets to Aave for lending.

```swift
func supply(_ supply: AaveSupply, completion: @escaping (Result<String, AaveError>) -> Void)
```

**Example:**
```swift
let supply = AaveSupply(
    asset: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
    amount: "1000",
    onBehalfOf: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
)

aaveManager.supply(supply) { result in
    switch result {
    case .success(let txHash):
        print("Supply completed: \(txHash)")
    case .failure(let error):
        print("Supply failed: \(error)")
    }
}
```

##### borrow

Borrows assets from Aave.

```swift
func borrow(_ borrow: AaveBorrow, completion: @escaping (Result<String, AaveError>) -> Void)
```

**Example:**
```swift
let borrow = AaveBorrow(
    asset: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
    amount: "100",
    interestRateMode: .stable,
    onBehalfOf: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6"
)

aaveManager.borrow(borrow) { result in
    switch result {
    case .success(let txHash):
        print("Borrow completed: \(txHash)")
    case .failure(let error):
        print("Borrow failed: \(error)")
    }
}
```

### CompoundManager

The main class for Compound operations.

#### Methods

##### supply

Supplies assets to Compound.

```swift
func supply(_ supply: CompoundSupply, completion: @escaping (Result<String, CompoundError>) -> Void)
```

**Example:**
```swift
let supply = CompoundSupply(
    asset: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
    amount: "1000"
)

compoundManager.supply(supply) { result in
    switch result {
    case .success(let txHash):
        print("Supply completed: \(txHash)")
    case .failure(let error):
        print("Supply failed: \(error)")
    }
}
```

## 🏗️ Data Models

### UniswapSwap

Represents a Uniswap token swap.

```swift
public struct UniswapSwap {
    public let tokenIn: String
    public let tokenOut: String
    public let amountIn: String
    public let slippageTolerance: Double
    public let recipient: String
    public let deadline: BigUInt
}
```

### AddLiquidityParams

Parameters for adding liquidity to Uniswap.

```swift
public struct AddLiquidityParams {
    public let tokenA: String
    public let tokenB: String
    public let amountA: String
    public let amountB: String
    public let fee: Int
    public let recipient: String
    public let deadline: BigUInt
}
```

### SwapQuote

Quote information for a token swap.

```swift
public struct SwapQuote {
    public let tokenIn: String
    public let tokenOut: String
    public let amountIn: String
    public let amountOut: String
    public let priceImpact: Decimal
    public let fee: String
    public let route: SwapRoute
}
```

### AaveSupply

Parameters for supplying assets to Aave.

```swift
public struct AaveSupply {
    public let asset: String
    public let amount: String
    public let onBehalfOf: String
}
```

### AaveBorrow

Parameters for borrowing assets from Aave.

```swift
public struct AaveBorrow {
    public let asset: String
    public let amount: String
    public let interestRateMode: InterestRateMode
    public let onBehalfOf: String
}
```

## 🔧 Protocol Configuration

### Uniswap Configuration

```swift
// Uniswap V3
let uniswapV3 = UniswapManager(version: .v3, network: .ethereum)

// Uniswap V4
let uniswapV4 = UniswapManager(version: .v4, network: .ethereum)

// Custom RPC
let uniswapCustom = UniswapManager(
    version: .v4,
    network: .ethereum,
    customRPC: "https://mainnet.infura.io/v3/YOUR_KEY"
)
```

### Aave Configuration

```swift
// Aave V3
let aaveV3 = AaveManager(version: .v3, network: .ethereum)

// Aave V2
let aaveV2 = AaveManager(version: .v2, network: .ethereum)
```

### Compound Configuration

```swift
// Compound V3
let compoundV3 = CompoundManager(version: .v3, network: .ethereum)

// Compound V2
let compoundV2 = CompoundManager(version: .v2, network: .ethereum)
```

## 📱 UI Integration

### SwiftUI Integration

```swift
struct DeFiView: View {
    @StateObject private var uniswapManager = UniswapManager()
    @StateObject private var aaveManager = AaveManager()
    @State private var selectedProtocol: DeFiProtocol = .uniswap
    
    var body: some View {
        VStack {
            Picker("Protocol", selection: $selectedProtocol) {
                Text("Uniswap").tag(DeFiProtocol.uniswap)
                Text("Aave").tag(DeFiProtocol.aave)
                Text("Compound").tag(DeFiProtocol.compound)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            switch selectedProtocol {
            case .uniswap:
                UniswapView()
            case .aave:
                AaveView()
            case .compound:
                CompoundView()
            }
        }
    }
}

struct UniswapView: View {
    @StateObject private var uniswapManager = UniswapManager()
    @State private var tokenIn = ""
    @State private var tokenOut = ""
    @State private var amountIn = ""
    @State private var isSwapping = false
    
    var body: some View {
        VStack {
            TextField("Token In", text: $tokenIn)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Token Out", text: $tokenOut)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Amount", text: $amountIn)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            
            Button("Swap") {
                performSwap()
            }
            .disabled(isSwapping || tokenIn.isEmpty || tokenOut.isEmpty || amountIn.isEmpty)
            
            if isSwapping {
                ProgressView()
            }
        }
        .padding()
    }
    
    private func performSwap() {
        isSwapping = true
        
        let swap = UniswapSwap(
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            amountIn: amountIn,
            slippageTolerance: 0.5,
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
        )
        
        uniswapManager.swap(swap) { result in
            DispatchQueue.main.async {
                isSwapping = false
                
                switch result {
                case .success(let txHash):
                    print("Swap completed: \(txHash)")
                case .failure(let error):
                    print("Swap failed: \(error)")
                }
            }
        }
    }
}
```

## 🧪 Testing

### Unit Tests

```swift
import XCTest
@testable import iOSWeb3WalletFramework

class UniswapManagerTests: XCTestCase {
    var uniswapManager: UniswapManager!
    
    override func setUp() {
        super.setUp()
        uniswapManager = UniswapManager()
    }
    
    func testSwapQuote() async throws {
        let swap = UniswapSwap(
            tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            tokenOut: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            amountIn: "1.0",
            slippageTolerance: 0.5,
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
        )
        
        let quote = try await uniswapManager.getSwapQuote(swap)
        XCTAssertNotNil(quote)
        XCTAssertFalse(quote.amountOut.isEmpty)
    }
    
    func testAddLiquidity() {
        let expectation = XCTestExpectation(description: "Add liquidity")
        
        let liquidity = AddLiquidityParams(
            tokenA: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            tokenB: "0xA0b86a33E6441b8C4C8C0C8C0C8C0C8C0C8C0C8",
            amountA: "1.0",
            amountB: "1000",
            fee: 3000,
            recipient: "0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6",
            deadline: BigUInt(Date().timeIntervalSince1970 + 3600)
        )
        
        uniswapManager.addLiquidity(liquidity) { result in
            switch result {
            case .success(let txHash):
                XCTAssertFalse(txHash.isEmpty)
            case .failure(let error):
                XCTFail("Add liquidity failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
```

## 🚀 Best Practices

### Security Guidelines

1. **Validate all token addresses**
2. **Use appropriate slippage tolerance**
3. **Handle transaction failures gracefully**
4. **Implement proper error handling**
5. **Use secure RPC endpoints**

### Performance Optimization

1. **Cache quotes appropriately**
2. **Use background tasks for operations**
3. **Implement proper retry logic**
4. **Optimize for gas usage**

### Error Handling

```swift
uniswapManager.swap(swap) { result in
    switch result {
    case .success(let txHash):
        print("Swap completed: \(txHash)")
    case .failure(let error):
        switch error {
        case .invalidTokenAddress(let address):
            print("Invalid token address: \(address)")
        case .invalidAmount(let amount):
            print("Invalid amount: \(amount)")
        case .insufficientLiquidity:
            print("Insufficient liquidity")
        case .slippageExceeded:
            print("Slippage exceeded")
        default:
            print("Unknown error: \(error)")
        }
    }
}
```

## 📚 Related Documentation

- [Wallet Management](WalletManagement.md)
- [Blockchain Integration](BlockchainIntegration.md)
- [Security Features](SecurityFeatures.md)
- [Yield Farming](YieldFarming.md)

---

**Need help?** Check our [Support Guide](../../README.md#support) or create an [Issue](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/issues). 