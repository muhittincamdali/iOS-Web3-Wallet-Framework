# Contributing to iOS Web3 Wallet Framework

Thank you for your interest in contributing to the iOS Web3 Wallet Framework! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

We welcome contributions from the community! Here are the main ways you can contribute:

### 🐛 Bug Reports

If you find a bug, please create an issue with the following information:

- **Bug Description**: Clear and concise description
- **Steps to Reproduce**: Detailed steps to reproduce the issue
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Environment**: iOS version, device, framework version
- **Screenshots**: If applicable, include screenshots
- **Logs**: Include relevant logs or error messages

### 💡 Feature Requests

For new features, please:

- Describe the feature in detail
- Explain the use case and benefits
- Provide examples of how it would work
- Consider implementation complexity
- Check if similar features already exist

### 🔧 Code Contributions

We follow these guidelines for code contributions:

#### Development Setup

1. **Fork the repository**
   ```bash
   git clone https://github.com/your-username/iOS-Web3-Wallet-Framework.git
   cd iOS-Web3-Wallet-Framework
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Install dependencies**
   ```bash
   swift package resolve
   ```

4. **Open in Xcode**
   ```bash
   open Package.swift
   ```

5. **Run tests**
   ```bash
   swift test
   ```

#### Code Style Guidelines

We follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) and use [SwiftLint](https://github.com/realm/SwiftLint) for code style enforcement.

**Naming Conventions:**
- Use `camelCase` for variables and functions
- Use `PascalCase` for types and protocols
- Use `UPPER_CASE` for constants
- Prefix private properties with `_`

**Code Organization:**
```swift
// MARK: - Properties
private let walletManager: Web3WalletManager
private let securityManager: SecurityManager

// MARK: - Initialization
init(walletManager: Web3WalletManager, securityManager: SecurityManager) {
    self.walletManager = walletManager
    self.securityManager = securityManager
}

// MARK: - Public Methods
func createWallet(name: String, password: String) async throws -> Wallet {
    // Implementation
}

// MARK: - Private Methods
private func validateInputs(name: String, password: String) throws {
    // Implementation
}
```

**Documentation:**
```swift
/// Creates a new wallet with the specified name and password.
/// - Parameters:
///   - name: The name for the wallet
///   - password: The password for wallet encryption
/// - Returns: A new wallet instance
/// - Throws: `WalletError.invalidName` if name is empty
/// - Throws: `WalletError.weakPassword` if password is too weak
func createWallet(name: String, password: String) async throws -> Wallet {
    // Implementation
}
```

#### Testing Requirements

All code contributions must include tests:

**Unit Tests:**
```swift
import XCTest
import Web3Wallet

class WalletManagerTests: XCTestCase {
    var walletManager: Web3WalletManager!
    
    override func setUp() {
        super.setUp()
        walletManager = Web3WalletManager()
    }
    
    func testWalletCreation() async throws {
        let wallet = try await walletManager.createWallet(
            name: "Test Wallet",
            password: "testPassword"
        )
        
        XCTAssertNotNil(wallet)
        XCTAssertEqual(wallet.name, "Test Wallet")
        XCTAssertTrue(wallet.isValid)
    }
}
```

**Integration Tests:**
```swift
import XCTest
import Web3Wallet

class DeFiIntegrationTests: XCTestCase {
    func testUniswapIntegration() async throws {
        let defiManager = DeFiManager()
        let swapRequest = SwapRequest(
            fromToken: "ETH",
            toToken: "USDC",
            amount: "0.1",
            slippage: 0.5
        )
        
        let transaction = try await defiManager.createSwapTransaction(swapRequest)
        XCTAssertNotNil(transaction)
    }
}
```

#### Performance Requirements

- **Wallet Creation**: < 500ms
- **Transaction Signing**: < 200ms
- **Balance Fetching**: < 300ms
- **Memory Usage**: < 100MB

#### Security Requirements

- All private keys must be stored securely
- Input validation for all user inputs
- SSL/TLS for all network communications
- Rate limiting for API calls
- Proper error handling without exposing sensitive information

### 📝 Documentation

We value good documentation:

#### Code Documentation
- Document all public APIs
- Include parameter descriptions
- Document possible errors
- Provide usage examples

#### README Updates
- Update README.md for new features
- Add installation instructions
- Include usage examples
- Update compatibility information

#### API Documentation
- Generate documentation using DocC
- Include code examples
- Provide migration guides
- Document breaking changes

### 🧪 Testing

#### Test Coverage Requirements
- **Unit Tests**: 90%+ coverage
- **Integration Tests**: All major features
- **UI Tests**: Critical user flows
- **Performance Tests**: Benchmark critical operations

#### Running Tests
```bash
# Run all tests
swift test

# Run specific test target
swift test --filter Web3WalletTests

# Run with coverage
swift test --enable-code-coverage
```

### 🔍 Code Review Process

1. **Create Pull Request**
   - Use descriptive title
   - Include detailed description
   - Link related issues
   - Add screenshots if UI changes

2. **Review Checklist**
   - [ ] Code follows style guidelines
   - [ ] Tests pass
   - [ ] Documentation updated
   - [ ] Performance requirements met
   - [ ] Security requirements met
   - [ ] No breaking changes (unless documented)

3. **Review Process**
   - At least one maintainer review required
   - Address all review comments
   - Update code as requested
   - Re-request review when ready

### 🚀 Release Process

#### Versioning
We follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

#### Release Checklist
- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version tagged
- [ ] Release notes written
- [ ] Dependencies updated

### 📋 Issue Templates

#### Bug Report Template
```markdown
## Bug Description
[Clear description of the bug]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Expected Behavior
[What you expected to happen]

## Actual Behavior
[What actually happened]

## Environment
- iOS Version: [e.g., 15.0]
- Device: [e.g., iPhone 13]
- Framework Version: [e.g., 1.0.0]

## Additional Information
[Screenshots, logs, etc.]
```

#### Feature Request Template
```markdown
## Feature Description
[Clear description of the feature]

## Use Case
[How this feature would be used]

## Benefits
[Why this feature is valuable]

## Implementation Ideas
[Optional: ideas for implementation]

## Additional Information
[Any other relevant information]
```

### 🏷️ Labels

We use the following labels for issues and PRs:

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements or additions to documentation
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention is needed
- `high priority`: Urgent issues
- `security`: Security-related issues
- `performance`: Performance improvements
- `testing`: Testing-related changes

### 📞 Communication

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Pull Requests**: For code contributions
- **Email**: support@web3wallet.com for urgent matters

### 🎯 Contribution Areas

We're particularly interested in contributions to:

- **Security**: Security audits, vulnerability fixes
- **Performance**: Performance optimizations
- **Testing**: Test coverage improvements
- **Documentation**: Documentation improvements
- **UI/UX**: User interface improvements
- **DeFi Integration**: New DeFi protocol support
- **Blockchain Support**: New blockchain networks

### 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation
- GitHub contributors page

### 📄 License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to the iOS Web3 Wallet Framework! 🚀 