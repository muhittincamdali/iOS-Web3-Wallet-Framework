import SwiftUI
import iOSWeb3WalletFramework

/// Basic wallet example demonstrating core wallet functionality
struct BasicWalletExample: View {
    @StateObject private var walletManager = WalletManager()
    @StateObject private var transactionManager = TransactionManager()
    
    @State private var walletAddress = ""
    @State private var balance = ""
    @State private var isCreatingWallet = false
    @State private var isImportingWallet = false
    @State private var privateKey = ""
    @State private var recipientAddress = ""
    @State private var amount = ""
    @State private var isSendingTransaction = false
    @State private var selectedNetwork: BlockchainNetwork = .ethereum
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "wallet.pass")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Basic Wallet Example")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Demonstrates core wallet functionality")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    if walletManager.isWalletCreated {
                        // Wallet Dashboard
                        walletDashboardView
                    } else {
                        // Wallet Creation
                        walletCreationView
                    }
                }
                .padding()
            }
            .navigationTitle("Basic Wallet")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Wallet Creation View
    
    private var walletCreationView: some View {
        VStack(spacing: 20) {
            // Create New Wallet
            VStack(spacing: 15) {
                Text("Create New Wallet")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Button(action: createWallet) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create New Wallet")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isCreatingWallet)
                
                if isCreatingWallet {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)
            
            // Import Existing Wallet
            VStack(spacing: 15) {
                Text("Import Existing Wallet")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                TextField("Private Key", text: $privateKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Button(action: importWallet) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Import Wallet")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isImportingWallet || privateKey.isEmpty)
                
                if isImportingWallet {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)
        }
    }
    
    // MARK: - Wallet Dashboard View
    
    private var walletDashboardView: some View {
        VStack(spacing: 20) {
            // Wallet Info
            VStack(spacing: 15) {
                Text("Wallet Information")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Address:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(walletAddress)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Balance:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(balance.isEmpty ? "Loading..." : "\(balance) ETH")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Network:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(selectedNetwork.name)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 2)
            
            // Network Selection
            VStack(spacing: 15) {
                Text("Select Network")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Picker("Network", selection: $selectedNetwork) {
                    ForEach(BlockchainNetwork.allCases, id: \.self) { network in
                        Text(network.name).tag(network)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedNetwork) { newNetwork in
                    switchNetwork(newNetwork)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 2)
            
            // Send Transaction
            VStack(spacing: 15) {
                Text("Send Transaction")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 10) {
                    TextField("Recipient Address", text: $recipientAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("Amount (ETH)", text: $amount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                Button(action: sendTransaction) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Send Transaction")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSendTransaction ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!canSendTransaction || isSendingTransaction)
                
                if isSendingTransaction {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 2)
            
            // Transaction History
            VStack(spacing: 15) {
                Text("Recent Transactions")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if transactionManager.transactionHistory.isEmpty {
                    Text("No transactions yet")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(transactionManager.transactionHistory.prefix(5)) { transaction in
                            TransactionRowView(transaction: transaction)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 2)
        }
        .onAppear {
            loadWalletInfo()
        }
    }
    
    // MARK: - Computed Properties
    
    private var canSendTransaction: Bool {
        !recipientAddress.isEmpty && !amount.isEmpty && isValidAddress(recipientAddress)
    }
    
    // MARK: - Actions
    
    private func createWallet() {
        isCreatingWallet = true
        
        walletManager.createWallet { result in
            DispatchQueue.main.async {
                isCreatingWallet = false
                
                switch result {
                case .success(let wallet):
                    walletAddress = wallet.address
                    loadWalletInfo()
                case .failure(let error):
                    showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func importWallet() {
        isImportingWallet = true
        
        walletManager.importWallet(privateKey: privateKey) { result in
            DispatchQueue.main.async {
                isImportingWallet = false
                
                switch result {
                case .success(let wallet):
                    walletAddress = wallet.address
                    privateKey = ""
                    loadWalletInfo()
                case .failure(let error):
                    showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func loadWalletInfo() {
        guard !walletAddress.isEmpty else { return }
        
        // Load balance
        Task {
            do {
                let balance = try await getWalletBalance()
                await MainActor.run {
                    self.balance = balance
                }
            } catch {
                await MainActor.run {
                    self.balance = "Error loading balance"
                }
            }
        }
    }
    
    private func switchNetwork(_ network: BlockchainNetwork) {
        Task {
            do {
                try await transactionManager.switchNetwork(network)
                await MainActor.run {
                    selectedNetwork = network
                    loadWalletInfo()
                }
            } catch {
                await MainActor.run {
                    showAlert(title: "Network Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func sendTransaction() {
        guard canSendTransaction else { return }
        
        isSendingTransaction = true
        
        let transaction = Transaction(
            to: recipientAddress,
            value: amount,
            network: selectedNetwork
        )
        
        transactionManager.sendTransaction(transaction) { result in
            DispatchQueue.main.async {
                isSendingTransaction = false
                
                switch result {
                case .success(let txHash):
                    showAlert(title: "Success", message: "Transaction sent: \(txHash)")
                    recipientAddress = ""
                    amount = ""
                    loadWalletInfo()
                case .failure(let error):
                    showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getWalletBalance() async throws -> String {
        // Simulate balance loading
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "1.23456789"
    }
    
    private func isValidAddress(_ address: String) -> Bool {
        let pattern = "^0x[a-fA-F0-9]{40}$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: address.utf16.count)
        return regex.firstMatch(in: address, range: range) != nil
    }
    
    private func showAlert(title: String, message: String) {
        // In a real app, you would use an alert or toast notification
        print("Alert: \(title) - \(message)")
    }
}

// MARK: - Transaction Row View

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("To: \(String(transaction.to.prefix(10)))...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(transaction.value) ETH")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text(transaction.network.name)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text(transaction.id.uuidString.prefix(8))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Preview

struct BasicWalletExample_Previews: PreviewProvider {
    static var previews: some View {
        BasicWalletExample()
    }
} 