# 🎨 UI/UX Guide

<!-- TOC START -->
## Table of Contents
- [🎨 UI/UX Guide](#-uiux-guide)
- [🎯 Design System](#-design-system)
  - [Color Palette](#color-palette)
  - [Typography](#typography)
  - [Spacing](#spacing)
- [🎬 Custom Animations](#-custom-animations)
  - [Transaction Animation](#transaction-animation)
- [📱 UI Components](#-ui-components)
  - [Wallet Card](#wallet-card)
  - [Transaction List](#transaction-list)
  - [Send Transaction View](#send-transaction-view)
- [🎨 Custom Themes](#-custom-themes)
  - [Dark Theme](#dark-theme)
  - [Light Theme](#light-theme)
- [🔄 State Management](#-state-management)
  - [Wallet State](#wallet-state)
  - [Transaction State](#transaction-state)
- [📊 Data Visualization](#-data-visualization)
  - [Balance Chart](#balance-chart)
  - [Portfolio Distribution](#portfolio-distribution)
- [🎯 User Experience](#-user-experience)
  - [Onboarding Flow](#onboarding-flow)
  - [Error Handling](#error-handling)
- [📚 Related Documentation](#-related-documentation)
<!-- TOC END -->


## 🎯 Design System

### Color Palette

```swift
let designSystem = WalletDesignSystem()

// Color palette
designSystem.colors = ColorPalette(
    primary: Color(red: 0/255, green: 122/255, blue: 255/255),
    secondary: Color(red: 64/255, green: 156/255, blue: 255/255),
    accent: Color(red: 128/255, green: 190/255, blue: 255/255)
)
```

### Typography

```swift
// Typography
designSystem.typography = Typography(
    title: Font.system(size: 34, weight: .bold),
    headline: Font.system(size: 22, weight: .semibold),
    body: Font.system(size: 17, weight: .regular),
    caption: Font.system(size: 12, weight: .medium)
)
```

### Spacing

```swift
// Spacing
designSystem.spacing = Spacing(
    xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 48
)
```

## 🎬 Custom Animations

### Transaction Animation

```swift
let animations = WalletAnimations()

// Transaction animation
animations.transactionAnimation = Animation.spring(
    response: 0.6,
    dampingFraction: 0.8
)

// Balance update animation
animations.balanceUpdateAnimation = Animation.easeInOut(duration: 0.3)

// Loading animation
animations.loadingAnimation = Animation.linear(duration: 1.0).repeatForever()
```

## 📱 UI Components

### Wallet Card

```swift
struct WalletCard: View {
    let wallet: Wallet
    @State private var balance: String = "0"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(wallet.name)
                    .font(.headline)
                Spacer()
                Text("$\(balance)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text(wallet.address)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
```

### Transaction List

```swift
struct TransactionList: View {
    @State private var transactions: [Transaction] = []
    
    var body: some View {
        List(transactions) { transaction in
            TransactionRow(transaction: transaction)
        }
        .refreshable {
            await loadTransactions()
        }
    }
    
    private func loadTransactions() async {
        // Load transactions
    }
}
```

### Send Transaction View

```swift
struct SendTransactionView: View {
    @State private var recipientAddress = ""
    @State private var amount = ""
    @State private var gasPrice = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Recipient") {
                    TextField("Address", text: $recipientAddress)
                }
                
                Section("Amount") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section("Gas") {
                    TextField("Gas Price (Gwei)", text: $gasPrice)
                        .keyboardType(.numberPad)
                }
                
                Button("Send Transaction") {
                    sendTransaction()
                }
                .disabled(recipientAddress.isEmpty || amount.isEmpty)
            }
            .navigationTitle("Send")
        }
    }
    
    private func sendTransaction() {
        // Send transaction logic
    }
}
```

## 🎨 Custom Themes

### Dark Theme

```swift
let darkTheme = WalletTheme(
    name: "Dark",
    colors: ColorScheme(
        primary: Color(red: 0/255, green: 122/255, blue: 255/255),
        background: Color.black,
        surface: Color(red: 28/255, green: 28/255, blue: 30/255),
        text: Color.white,
        textSecondary: Color.gray
    )
)
```

### Light Theme

```swift
let lightTheme = WalletTheme(
    name: "Light",
    colors: ColorScheme(
        primary: Color(red: 0/255, green: 122/255, blue: 255/255),
        background: Color.white,
        surface: Color(red: 242/255, green: 242/255, blue: 247/255),
        text: Color.black,
        textSecondary: Color.gray
    )
)
```

## 🔄 State Management

### Wallet State

```swift
class WalletState: ObservableObject {
    @Published var wallet: Wallet?
    @Published var balance: String = "0"
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    
    func loadWallet() async {
        isLoading = true
        defer { isLoading = false }
        
        // Load wallet data
        wallet = try? await WalletManager.shared.getCurrentWallet()
        balance = try? await wallet?.getBalance() ?? "0"
        transactions = try? await wallet?.getTransactions() ?? []
    }
}
```

### Transaction State

```swift
class TransactionState: ObservableObject {
    @Published var pendingTransactions: [Transaction] = []
    @Published var confirmedTransactions: [Transaction] = []
    
    func addTransaction(_ transaction: Transaction) {
        pendingTransactions.append(transaction)
        
        // Monitor transaction
        Task {
            await monitorTransaction(transaction)
        }
    }
    
    private func monitorTransaction(_ transaction: Transaction) async {
        // Monitor transaction status
    }
}
```

## 📊 Data Visualization

### Balance Chart

```swift
struct BalanceChart: View {
    let balanceHistory: [BalancePoint]
    
    var body: some View {
        Chart(balanceHistory) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Balance", point.balance)
            )
            .foregroundStyle(.blue)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}
```

### Portfolio Distribution

```swift
struct PortfolioDistribution: View {
    let tokens: [TokenBalance]
    
    var body: some View {
        Chart(tokens) { token in
            SectorMark(
                angle: .value("Value", token.value),
                innerRadius: .ratio(0.6)
            )
            .foregroundStyle(by: .value("Token", token.symbol))
        }
    }
}
```

## 🎯 User Experience

### Onboarding Flow

```swift
struct OnboardingView: View {
    @State private var currentStep = 0
    let steps = ["Welcome", "Create Wallet", "Security", "Complete"]
    
    var body: some View {
        VStack {
            // Progress indicator
            ProgressView(value: Double(currentStep), total: Double(steps.count - 1))
            
            // Step content
            switch currentStep {
            case 0:
                WelcomeStep()
            case 1:
                CreateWalletStep()
            case 2:
                SecurityStep()
            case 3:
                CompleteStep()
            default:
                EmptyView()
            }
            
            // Navigation buttons
            HStack {
                if currentStep > 0 {
                    Button("Back") {
                        currentStep -= 1
                    }
                }
                
                Spacer()
                
                Button(currentStep == steps.count - 1 ? "Finish" : "Next") {
                    if currentStep < steps.count - 1 {
                        currentStep += 1
                    } else {
                        completeOnboarding()
                    }
                }
            }
        }
        .padding()
    }
    
    private func completeOnboarding() {
        // Complete onboarding
    }
}
```

### Error Handling

```swift
struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Try Again") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

## 📚 Related Documentation

- [Getting Started Guide](GettingStarted.md)
- [Wallet Setup Guide](WalletSetup.md)
- [UI/UX API](UIUXAPI.md)
- [Performance Guide](PerformanceGuide.md)
