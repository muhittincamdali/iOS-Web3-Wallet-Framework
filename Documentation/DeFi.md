# DeFi Integration Guide

## Overview

The iOS Web3 Wallet Framework provides comprehensive DeFi (Decentralized Finance) integration capabilities, supporting major protocols and platforms in the Web3 ecosystem.

## Table of Contents

1. [Supported Protocols](#supported-protocols)
2. [DEX Integration](#dex-integration)
3. [Lending Protocols](#lending-protocols)
4. [Yield Farming](#yield-farming)
5. [Liquidity Provision](#liquidity-provision)
6. [Portfolio Management](#portfolio-management)
7. [Price Feeds](#price-feeds)
8. [Best Practices](#best-practices)

## Supported Protocols

### DEX (Decentralized Exchanges)

- **Uniswap V2/V3**: Automated market maker with concentrated liquidity
- **SushiSwap**: Multi-chain DEX with yield farming
- **PancakeSwap**: BSC-based DEX
- **Curve Finance**: Stablecoin-focused DEX

### Lending Protocols

- **Aave**: Multi-chain lending and borrowing
- **Compound**: Interest-bearing tokens
- **Yearn Finance**: Automated yield optimization

### Yield Farming

- **Yearn Finance**: Automated yield strategies
- **SushiSwap**: Liquidity mining rewards
- **Curve Finance**: CRV token rewards

## DEX Integration

### Uniswap Integration

```swift
import Web3Wallet

class UniswapManager {
    private let defiManager = DeFiManager()
    
    func swapTokens(
        fromToken: String,
        toToken: String,
        amount: String,
        slippage: Double
    ) async throws -> SwapResult {
        
        let swapRequest = SwapRequest(
            fromToken: fromToken,
            toToken: toToken,
            amount: amount,
            slippage: slippage
        )
        
        // Create swap transaction
        let transaction = try await defiManager.createUniswapSwapTransaction(swapRequest)
        
        // Sign transaction
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        
        // Send transaction
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return SwapResult(
            transactionHash: txHash,
            fromToken: fromToken,
            toToken: toToken,
            amount: amount,
            expectedOutput: calculateExpectedOutput(swapRequest)
        )
    }
    
    func addLiquidity(
        tokenA: String,
        tokenB: String,
        amountA: String,
        amountB: String
    ) async throws -> LiquidityResult {
        
        let liquidityRequest = LiquidityRequest(
            tokenA: tokenA,
            tokenB: tokenB,
            amountA: amountA,
            amountB: amountB
        )
        
        let transaction = try await defiManager.createUniswapLiquidityTransaction(liquidityRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return LiquidityResult(
            transactionHash: txHash,
            tokenA: tokenA,
            tokenB: tokenB,
            liquidityTokens: calculateLiquidityTokens(amountA, amountB)
        )
    }
    
    func removeLiquidity(
        pairAddress: String,
        liquidityTokens: String
    ) async throws -> RemoveLiquidityResult {
        
        let removeRequest = RemoveLiquidityRequest(
            pairAddress: pairAddress,
            liquidityTokens: liquidityTokens
        )
        
        let transaction = try await defiManager.createUniswapRemoveLiquidityTransaction(removeRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return RemoveLiquidityResult(
            transactionHash: txHash,
            tokenAReceived: calculateTokenAReceived(liquidityTokens),
            tokenBReceived: calculateTokenBReceived(liquidityTokens)
        )
    }
}
```

### SushiSwap Integration

```swift
import Web3Wallet

class SushiSwapManager {
    private let defiManager = DeFiManager()
    
    func swapOnSushiSwap(
        fromToken: String,
        toToken: String,
        amount: String,
        slippage: Double
    ) async throws -> SwapResult {
        
        let swapRequest = SwapRequest(
            fromToken: fromToken,
            toToken: toToken,
            amount: amount,
            slippage: slippage,
            protocol: .sushiSwap
        )
        
        let transaction = try await defiManager.createSushiSwapTransaction(swapRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return SwapResult(
            transactionHash: txHash,
            fromToken: fromToken,
            toToken: toToken,
            amount: amount,
            expectedOutput: calculateExpectedOutput(swapRequest)
        )
    }
    
    func stakeSushiTokens(
        amount: String
    ) async throws -> StakingResult {
        
        let stakingRequest = StakingRequest(
            token: "SUSHI",
            amount: amount,
            protocol: .sushiSwap
        )
        
        let transaction = try await defiManager.createStakingTransaction(stakingRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return StakingResult(
            transactionHash: txHash,
            stakedAmount: amount,
            rewards: calculateStakingRewards(amount)
        )
    }
}
```

## Lending Protocols

### Aave Integration

```swift
import Web3Wallet

class AaveManager {
    private let defiManager = DeFiManager()
    
    func deposit(
        asset: String,
        amount: String
    ) async throws -> DepositResult {
        
        let depositRequest = DepositRequest(
            asset: asset,
            amount: amount,
            protocol: .aave
        )
        
        let transaction = try await defiManager.createDepositTransaction(depositRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return DepositResult(
            transactionHash: txHash,
            asset: asset,
            amount: amount,
            aTokens: calculateATokens(amount)
        )
    }
    
    func borrow(
        asset: String,
        amount: String,
        interestRateMode: InterestRateMode
    ) async throws -> BorrowResult {
        
        let borrowRequest = BorrowRequest(
            asset: asset,
            amount: amount,
            interestRateMode: interestRateMode,
            protocol: .aave
        )
        
        let transaction = try await defiManager.createBorrowTransaction(borrowRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return BorrowResult(
            transactionHash: txHash,
            asset: asset,
            amount: amount,
            interestRate: calculateInterestRate(asset, mode: interestRateMode)
        )
    }
    
    func repay(
        asset: String,
        amount: String,
        interestRateMode: InterestRateMode
    ) async throws -> RepayResult {
        
        let repayRequest = RepayRequest(
            asset: asset,
            amount: amount,
            interestRateMode: interestRateMode,
            protocol: .aave
        )
        
        let transaction = try await defiManager.createRepayTransaction(repayRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return RepayResult(
            transactionHash: txHash,
            asset: asset,
            amount: amount,
            remainingDebt: calculateRemainingDebt(asset, amount)
        )
    }
    
    func withdraw(
        asset: String,
        amount: String
    ) async throws -> WithdrawResult {
        
        let withdrawRequest = WithdrawRequest(
            asset: asset,
            amount: amount,
            protocol: .aave
        )
        
        let transaction = try await defiManager.createWithdrawTransaction(withdrawRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return WithdrawResult(
            transactionHash: txHash,
            asset: asset,
            amount: amount
        )
    }
}
```

### Compound Integration

```swift
import Web3Wallet

class CompoundManager {
    private let defiManager = DeFiManager()
    
    func supply(
        asset: String,
        amount: String
    ) async throws -> SupplyResult {
        
        let supplyRequest = SupplyRequest(
            asset: asset,
            amount: amount,
            protocol: .compound
        )
        
        let transaction = try await defiManager.createSupplyTransaction(supplyRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return SupplyResult(
            transactionHash: txHash,
            asset: asset,
            amount: amount,
            cTokens: calculateCTokens(amount)
        )
    }
    
    func borrow(
        asset: String,
        amount: String
    ) async throws -> BorrowResult {
        
        let borrowRequest = BorrowRequest(
            asset: asset,
            amount: amount,
            protocol: .compound
        )
        
        let transaction = try await defiManager.createBorrowTransaction(borrowRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return BorrowResult(
            transactionHash: txHash,
            asset: asset,
            amount: amount,
            interestRate: calculateCompoundInterestRate(asset)
        )
    }
}
```

## Yield Farming

### Yearn Finance Integration

```swift
import Web3Wallet

class YearnManager {
    private let defiManager = DeFiManager()
    
    func depositToVault(
        vaultAddress: String,
        amount: String
    ) async throws -> VaultDepositResult {
        
        let vaultRequest = VaultDepositRequest(
            vaultAddress: vaultAddress,
            amount: amount,
            protocol: .yearn
        )
        
        let transaction = try await defiManager.createVaultDepositTransaction(vaultRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return VaultDepositResult(
            transactionHash: txHash,
            vaultAddress: vaultAddress,
            amount: amount,
            yTokens: calculateYTokens(amount)
        )
    }
    
    func withdrawFromVault(
        vaultAddress: String,
        amount: String
    ) async throws -> VaultWithdrawResult {
        
        let withdrawRequest = VaultWithdrawRequest(
            vaultAddress: vaultAddress,
            amount: amount,
            protocol: .yearn
        )
        
        let transaction = try await defiManager.createVaultWithdrawTransaction(withdrawRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return VaultWithdrawResult(
            transactionHash: txHash,
            vaultAddress: vaultAddress,
            amount: amount
        )
    }
    
    func getVaultAPY(
        vaultAddress: String
    ) async throws -> Double {
        return try await defiManager.getVaultAPY(vaultAddress: vaultAddress)
    }
}
```

## Liquidity Provision

### Curve Finance Integration

```swift
import Web3Wallet

class CurveManager {
    private let defiManager = DeFiManager()
    
    func addLiquidityToPool(
        poolAddress: String,
        amounts: [String]
    ) async throws -> CurveLiquidityResult {
        
        let liquidityRequest = CurveLiquidityRequest(
            poolAddress: poolAddress,
            amounts: amounts,
            protocol: .curve
        )
        
        let transaction = try await defiManager.createCurveLiquidityTransaction(liquidityRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return CurveLiquidityResult(
            transactionHash: txHash,
            poolAddress: poolAddress,
            lpTokens: calculateLPTokens(amounts)
        )
    }
    
    func removeLiquidityFromPool(
        poolAddress: String,
        lpTokens: String
    ) async throws -> CurveRemoveLiquidityResult {
        
        let removeRequest = CurveRemoveLiquidityRequest(
            poolAddress: poolAddress,
            lpTokens: lpTokens,
            protocol: .curve
        )
        
        let transaction = try await defiManager.createCurveRemoveLiquidityTransaction(removeRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return CurveRemoveLiquidityResult(
            transactionHash: txHash,
            poolAddress: poolAddress,
            tokensReceived: calculateTokensReceived(lpTokens)
        )
    }
    
    func swapOnCurve(
        poolAddress: String,
        fromToken: String,
        toToken: String,
        amount: String
    ) async throws -> CurveSwapResult {
        
        let swapRequest = CurveSwapRequest(
            poolAddress: poolAddress,
            fromToken: fromToken,
            toToken: toToken,
            amount: amount,
            protocol: .curve
        )
        
        let transaction = try await defiManager.createCurveSwapTransaction(swapRequest)
        let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
        let txHash = try await walletManager.sendTransaction(signedTx)
        
        return CurveSwapResult(
            transactionHash: txHash,
            fromToken: fromToken,
            toToken: toToken,
            amount: amount
        )
    }
}
```

## Portfolio Management

### Portfolio Tracking

```swift
import Web3Wallet

class PortfolioManager {
    private let defiManager = DeFiManager()
    
    func getPortfolioValue(
        wallet: Wallet
    ) async throws -> PortfolioValue {
        
        let balances = try await defiManager.getAllTokenBalances(wallet: wallet)
        let prices = try await defiManager.getTokenPrices(tokens: balances.map { $0.token })
        
        var totalValue: Double = 0
        var portfolioItems: [PortfolioItem] = []
        
        for balance in balances {
            let price = prices[balance.token] ?? 0
            let value = balance.amount * price
            
            portfolioItems.append(PortfolioItem(
                token: balance.token,
                amount: balance.amount,
                price: price,
                value: value
            ))
            
            totalValue += value
        }
        
        return PortfolioValue(
            totalValue: totalValue,
            items: portfolioItems,
            lastUpdated: Date()
        )
    }
    
    func getDeFiPositions(
        wallet: Wallet
    ) async throws -> [DeFiPosition] {
        
        var positions: [DeFiPosition] = []
        
        // Get Aave positions
        let aavePositions = try await defiManager.getAavePositions(wallet: wallet)
        positions.append(contentsOf: aavePositions)
        
        // Get Compound positions
        let compoundPositions = try await defiManager.getCompoundPositions(wallet: wallet)
        positions.append(contentsOf: compoundPositions)
        
        // Get Yearn positions
        let yearnPositions = try await defiManager.getYearnPositions(wallet: wallet)
        positions.append(contentsOf: yearnPositions)
        
        // Get liquidity positions
        let liquidityPositions = try await defiManager.getLiquidityPositions(wallet: wallet)
        positions.append(contentsOf: liquidityPositions)
        
        return positions
    }
    
    func getYieldFarmingRewards(
        wallet: Wallet
    ) async throws -> [FarmingReward] {
        
        var rewards: [FarmingReward] = []
        
        // Get SushiSwap rewards
        let sushiRewards = try await defiManager.getSushiSwapRewards(wallet: wallet)
        rewards.append(contentsOf: sushiRewards)
        
        // Get Curve rewards
        let curveRewards = try await defiManager.getCurveRewards(wallet: wallet)
        rewards.append(contentsOf: curveRewards)
        
        // Get Yearn rewards
        let yearnRewards = try await defiManager.getYearnRewards(wallet: wallet)
        rewards.append(contentsOf: yearnRewards)
        
        return rewards
    }
}
```

## Price Feeds

### Real-time Price Updates

```swift
import Web3Wallet

class PriceFeedManager {
    private let defiManager = DeFiManager()
    
    func getTokenPrice(
        token: String
    ) async throws -> TokenPrice {
        
        let price = try await defiManager.getTokenPrice(token: token)
        let change24h = try await defiManager.getTokenPriceChange24h(token: token)
        let volume24h = try await defiManager.getTokenVolume24h(token: token)
        
        return TokenPrice(
            token: token,
            price: price,
            change24h: change24h,
            volume24h: volume24h,
            lastUpdated: Date()
        )
    }
    
    func getMultipleTokenPrices(
        tokens: [String]
    ) async throws -> [String: TokenPrice] {
        
        var prices: [String: TokenPrice] = [:]
        
        for token in tokens {
            let price = try await getTokenPrice(token: token)
            prices[token] = price
        }
        
        return prices
    }
    
    func subscribeToPriceUpdates(
        tokens: [String],
        callback: @escaping ([String: TokenPrice]) -> Void
    ) {
        defiManager.subscribeToPriceUpdates(tokens: tokens) { prices in
            callback(prices)
        }
    }
}
```

## Best Practices

### 1. Slippage Protection

```swift
class SlippageProtection {
    
    func calculateOptimalSlippage(
        tokenPair: String,
        amount: String
    ) -> Double {
        // Calculate optimal slippage based on:
        // - Token pair volatility
        // - Transaction amount
        // - Market conditions
        // - Historical slippage data
        
        let baseSlippage = 0.5 // 0.5%
        let volatilityMultiplier = getVolatilityMultiplier(tokenPair)
        let amountMultiplier = getAmountMultiplier(amount)
        
        return baseSlippage * volatilityMultiplier * amountMultiplier
    }
    
    func validateSlippage(
        expectedPrice: Double,
        actualPrice: Double,
        maxSlippage: Double
    ) -> Bool {
        let slippage = abs(actualPrice - expectedPrice) / expectedPrice * 100
        return slippage <= maxSlippage
    }
}
```

### 2. Gas Optimization

```swift
class GasOptimization {
    
    func estimateOptimalGas(
        transaction: Transaction
    ) async throws -> UInt64 {
        
        // Get current gas price
        let currentGasPrice = try await defiManager.getGasPrice(for: transaction.chain)
        
        // Calculate optimal gas limit
        let estimatedGas = try await defiManager.estimateGas(transaction: transaction)
        
        // Add buffer for safety
        let gasWithBuffer = estimatedGas + (estimatedGas / 10) // 10% buffer
        
        return gasWithBuffer
    }
    
    func batchTransactions(
        transactions: [Transaction]
    ) async throws -> [Transaction] {
        
        // Group transactions by type
        let swapTransactions = transactions.filter { $0.type == .swap }
        let depositTransactions = transactions.filter { $0.type == .deposit }
        
        // Optimize gas for each group
        let optimizedSwaps = try await optimizeGasForSwaps(swapTransactions)
        let optimizedDeposits = try await optimizeGasForDeposits(depositTransactions)
        
        return optimizedSwaps + optimizedDeposits
    }
}
```

### 3. Error Handling

```swift
class DeFiErrorHandler {
    
    func handleDeFiError(_ error: Error) -> DeFiError {
        switch error {
        case DeFiError.insufficientLiquidity:
            return .insufficientLiquidity("Not enough liquidity for this trade")
        case DeFiError.slippageExceeded:
            return .slippageExceeded("Price moved too much, try again")
        case DeFiError.insufficientBalance:
            return .insufficientBalance("Insufficient balance for transaction")
        case DeFiError.transactionFailed:
            return .transactionFailed("Transaction failed, check gas settings")
        default:
            return .unknown("An unknown error occurred")
        }
    }
    
    func retryTransaction(
        transaction: Transaction,
        maxRetries: Int = 3
    ) async throws -> String {
        
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                let signedTx = try await walletManager.signTransaction(transaction, wallet: wallet)
                let txHash = try await walletManager.sendTransaction(signedTx)
                return txHash
            } catch {
                lastError = error
                
                if attempt < maxRetries {
                    // Wait before retry
                    try await Task.sleep(nanoseconds: UInt64(attempt * 1000_000_000))
                }
            }
        }
        
        throw lastError ?? DeFiError.transactionFailed
    }
}
```

### 4. Security Considerations

```swift
class DeFiSecurityManager {
    
    func validateDeFiTransaction(
        transaction: Transaction
    ) throws -> Bool {
        
        // Validate transaction parameters
        guard transaction.value > 0 else {
            throw DeFiError.invalidAmount
        }
        
        // Check for suspicious activity
        guard !isSuspiciousTransaction(transaction) else {
            throw DeFiError.suspiciousActivity
        }
        
        // Validate contract addresses
        guard isValidContractAddress(transaction.to) else {
            throw DeFiError.invalidContractAddress
        }
        
        return true
    }
    
    func isSuspiciousTransaction(_ transaction: Transaction) -> Bool {
        // Check for:
        // - Unusually large amounts
        // - Unknown contract addresses
        // - Rapid successive transactions
        // - Known scam addresses
        
        let largeAmountThreshold = 1000.0 // 1000 ETH
        let amount = Double(transaction.value) ?? 0
        
        if amount > largeAmountThreshold {
            return true
        }
        
        return false
    }
}
```

## Support

For DeFi integration questions:

- **Documentation**: [Full Documentation](Documentation/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework/discussions)
- **Email**: defi-support@web3wallet.com

---

*This DeFi integration guide is regularly updated. For the latest version, please check the [GitHub repository](https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework).* 