import SwiftUI
import Web3Wallet

@main
struct WalletExampleApp: App {
    
    // MARK: - Properties
    
    @StateObject private var walletManager = Web3WalletManager()
    @StateObject private var appState = AppState()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(walletManager)
                .environmentObject(appState)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupApp() {
        // Configure app settings
        appState.configureApp()
        
        // Setup wallet manager
        setupWalletManager()
    }
    
    private func setupWalletManager() {
        // Configure networks
        let networks: [Blockchain: NetworkConfig] = [
            .ethereum: NetworkConfig(
                chainId: 1,
                rpcUrl: "https://mainnet.infura.io/v3/YOUR_PROJECT_ID",
                explorerUrl: "https://etherscan.io",
                name: "Ethereum Mainnet"
            ),
            .polygon: NetworkConfig(
                chainId: 137,
                rpcUrl: "https://polygon-rpc.com",
                explorerUrl: "https://polygonscan.com",
                name: "Polygon Mainnet"
            ),
            .bsc: NetworkConfig(
                chainId: 56,
                rpcUrl: "https://bsc-dataseed.binance.org",
                explorerUrl: "https://bscscan.com",
                name: "Binance Smart Chain"
            )
        ]
        
        walletManager.configureNetworks(networks)
    }
}

// MARK: - App State

class AppState: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isOnboarding = true
    @Published var hasWallet = false
    @Published var currentTab = 0
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Properties
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Initialization
    
    init() {
        loadAppState()
    }
    
    // MARK: - Public Methods
    
    func configureApp() {
        // Check if user has completed onboarding
        isOnboarding = !userDefaults.bool(forKey: "hasCompletedOnboarding")
        
        // Check if user has a wallet
        hasWallet = userDefaults.bool(forKey: "hasWallet")
    }
    
    func completeOnboarding() {
        isOnboarding = false
        userDefaults.set(true, forKey: "hasCompletedOnboarding")
    }
    
    func setHasWallet(_ hasWallet: Bool) {
        self.hasWallet = hasWallet
        userDefaults.set(hasWallet, forKey: "hasWallet")
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    // MARK: - Private Methods
    
    private func loadAppState() {
        // Load any saved app state
    }
}

// MARK: - Content View

struct ContentView: View {
    
    // MARK: - Environment Objects
    
    @EnvironmentObject var walletManager: Web3WalletManager
    @EnvironmentObject var appState: AppState
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if appState.isOnboarding {
                OnboardingView()
            } else if !appState.hasWallet {
                CreateWalletView()
            } else {
                MainTabView()
            }
        }
        .alert("Error", isPresented: $appState.showError) {
            Button("OK") { }
        } message: {
            Text(appState.errorMessage)
        }
    }
}

// MARK: - Onboarding View

struct OnboardingView: View {
    
    // MARK: - Environment Objects
    
    @EnvironmentObject var appState: AppState
    
    // MARK: - State
    
    @State private var currentPage = 0
    
    // MARK: - Properties
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to Web3 Wallet",
            subtitle: "Your gateway to the decentralized world",
            image: "wallet.fill",
            description: "Create, manage, and interact with blockchain networks securely."
        ),
        OnboardingPage(
            title: "DeFi Integration",
            subtitle: "Access DeFi protocols seamlessly",
            image: "chart.line.uptrend.xyaxis",
            description: "Swap tokens, provide liquidity, and earn yields with integrated DeFi protocols."
        ),
        OnboardingPage(
            title: "Multi-Chain Support",
            subtitle: "Connect to multiple blockchains",
            image: "network",
            description: "Support for Ethereum, Polygon, BSC, and more blockchain networks."
        ),
        OnboardingPage(
            title: "Security First",
            subtitle: "Bank-level security for your assets",
            image: "lock.shield",
            description: "Hardware wallet support, biometric authentication, and encrypted storage."
        )
    ]
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Page indicator
            HStack {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 20)
            
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Navigation buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                if currentPage < pages.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .foregroundColor(.blue)
                } else {
                    Button("Get Started") {
                        appState.completeOnboarding()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(25)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Onboarding Page

struct OnboardingPage {
    let title: String
    let subtitle: String
    let image: String
    let description: String
}

struct OnboardingPageView: View {
    
    // MARK: - Properties
    
    let page: OnboardingPage
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Image(systemName: page.image)
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            // Title
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Subtitle
            Text(page.subtitle)
                .font(.title2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Description
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Create Wallet View

struct CreateWalletView: View {
    
    // MARK: - Environment Objects
    
    @EnvironmentObject var walletManager: Web3WalletManager
    @EnvironmentObject var appState: AppState
    
    // MARK: - State
    
    @State private var walletName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isCreating = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "wallet.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Create Your Wallet")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Secure your digital assets with a new wallet")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 20) {
                    // Wallet Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Wallet Name")
                            .font(.headline)
                        
                        TextField("Enter wallet name", text: $walletName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                        
                        HStack {
                            if showPassword {
                                TextField("Enter password", text: $password)
                            } else {
                                SecureField("Enter password", text: $password)
                            }
                            
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("Must be at least 8 characters with uppercase, lowercase, number, and special character")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Confirm Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.headline)
                        
                        HStack {
                            if showConfirmPassword {
                                TextField("Confirm password", text: $confirmPassword)
                            } else {
                                SecureField("Confirm password", text: $confirmPassword)
                            }
                            
                            Button(action: {
                                showConfirmPassword.toggle()
                            }) {
                                Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Create Button
                Button(action: createWallet) {
                    HStack {
                        if isCreating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        
                        Text(isCreating ? "Creating..." : "Create Wallet")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!isFormValid || isCreating)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !walletName.isEmpty &&
        password.count >= 8 &&
        password == confirmPassword &&
        password.rangeOfCharacter(from: .uppercaseLetters) != nil &&
        password.rangeOfCharacter(from: .lowercaseLetters) != nil &&
        password.rangeOfCharacter(from: .decimalDigits) != nil &&
        password.rangeOfCharacter(from: .punctuationCharacters) != nil
    }
    
    // MARK: - Private Methods
    
    private func createWallet() {
        guard isFormValid else { return }
        
        isCreating = true
        
        Task {
            do {
                let wallet = try await walletManager.createWallet(
                    name: walletName,
                    password: password
                )
                
                await MainActor.run {
                    appState.setHasWallet(true)
                    isCreating = false
                }
            } catch {
                await MainActor.run {
                    appState.showError(error.localizedDescription)
                    isCreating = false
                }
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    
    // MARK: - Environment Objects
    
    @EnvironmentObject var walletManager: Web3WalletManager
    @EnvironmentObject var appState: AppState
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $appState.currentTab) {
            WalletView()
                .tabItem {
                    Image(systemName: "wallet.fill")
                    Text("Wallet")
                }
                .tag(0)
            
            DeFiView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("DeFi")
                }
                .tag(1)
            
            TransactionsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Transactions")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
    }
}

// MARK: - Wallet View

struct WalletView: View {
    
    // MARK: - Environment Objects
    
    @EnvironmentObject var walletManager: Web3WalletManager
    
    // MARK: - State
    
    @State private var balance = "0"
    @State private var isLoading = true
    @State private var selectedNetwork: Blockchain = .ethereum
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Balance Card
                    VStack(spacing: 15) {
                        Text("Balance")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(balance) ETH")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("≈ $0.00 USD")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Network Selector
                    Picker("Network", selection: $selectedNetwork) {
                        ForEach(Blockchain.allCases, id: \.self) { network in
                            Text(network.displayName).tag(network)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedNetwork) { _ in
                        loadBalance()
                    }
                    
                    // Quick Actions
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                        QuickActionButton(
                            title: "Send",
                            icon: "arrow.up.circle.fill",
                            color: .blue
                        ) {
                            // Handle send action
                        }
                        
                        QuickActionButton(
                            title: "Receive",
                            icon: "arrow.down.circle.fill",
                            color: .green
                        ) {
                            // Handle receive action
                        }
                        
                        QuickActionButton(
                            title: "Swap",
                            icon: "arrow.triangle.2.circlepath",
                            color: .orange
                        ) {
                            // Handle swap action
                        }
                        
                        QuickActionButton(
                            title: "Stake",
                            icon: "percent",
                            color: .purple
                        ) {
                            // Handle stake action
                        }
                    }
                    
                    // Wallet Info
                    if let wallet = walletManager.currentWallet {
                        WalletInfoCard(wallet: wallet)
                    }
                }
                .padding()
            }
            .navigationTitle("Wallet")
            .refreshable {
                loadBalance()
            }
            .onAppear {
                loadBalance()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadBalance() {
        guard let wallet = walletManager.currentWallet else { return }
        
        isLoading = true
        
        Task {
            do {
                let balance = try await walletManager.getBalance(on: selectedNetwork)
                await MainActor.run {
                    self.balance = balance
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.balance = "0"
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct QuickActionButton: View {
    
    // MARK: - Properties
    
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WalletInfoCard: View {
    
    // MARK: - Properties
    
    let wallet: Wallet
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wallet Information")
                .font(.headline)
            
            HStack {
                Text("Address:")
                    .fontWeight(.medium)
                Spacer()
                Text(wallet.shortAddress)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Type:")
                    .fontWeight(.medium)
                Spacer()
                Text(wallet.walletType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Security:")
                    .fontWeight(.medium)
                Spacer()
                Text(wallet.securityLevel.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Created:")
                    .fontWeight(.medium)
                Spacer()
                Text(wallet.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Placeholder Views

struct DeFiView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("DeFi Coming Soon")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("DeFi")
        }
    }
}

struct TransactionsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Transactions Coming Soon")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Transactions")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings Coming Soon")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Settings")
        }
    }
} 