# Contributing to iOS Web3 Wallet Framework

Thank you for your interest in contributing to iOS Web3 Wallet Framework! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Security Guidelines](#security-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Release Process](#release-process)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Security Issues

- **DO NOT** create public issues for security vulnerabilities
- Email security issues to: security@web3wallet.com
- Include detailed reproduction steps
- Provide device and iOS version information
- Include crash logs if applicable

### Reporting Bugs

- Use the GitHub issue tracker
- Include detailed reproduction steps
- Provide device and iOS version information
- Include crash logs if applicable
- Specify blockchain network and transaction details

### Suggesting Enhancements

- Use the GitHub issue tracker
- Describe the enhancement clearly
- Explain the use case and benefits
- Provide mockups or examples if possible
- Consider security implications

### Pull Requests

- Fork the repository
- Create a feature branch
- Make your changes
- Add tests for new functionality
- Update documentation
- Submit a pull request

## Development Setup

### Prerequisites

- Xcode 15.0 or later
- iOS 15.0+ deployment target
- Swift 5.9 or later
- CocoaPods or Swift Package Manager
- Git

### Getting Started

1. Clone the repository:
```bash
git clone https://github.com/muhittincamdali/iOS-Web3-Wallet-Framework.git
cd iOS-Web3-Wallet-Framework
```

2. Open the project in Xcode:
```bash
open Package.swift
```

3. Build the project:
```bash
swift build
```

4. Run tests:
```bash
swift test
```

### Blockchain Network Setup

For development and testing:

1. **Ethereum Testnet**: Use Sepolia or Goerli
2. **Polygon Testnet**: Use Mumbai
3. **BSC Testnet**: Use BSC Testnet
4. **Local Development**: Use Hardhat or Ganache

## Coding Standards

### Swift Style Guide

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 4-space indentation
- Maximum line length: 120 characters
- Use meaningful variable and function names
- Add documentation comments for public APIs

### Security Guidelines

- **NEVER** log private keys or sensitive data
- Use secure random number generation
- Implement proper key derivation functions
- Validate all user inputs
- Use HTTPS for all network requests
- Implement proper error handling without exposing sensitive information

### Blockchain Guidelines

- Always validate transaction parameters
- Implement proper gas estimation
- Handle network failures gracefully
- Use appropriate RPC endpoints
- Implement retry mechanisms for failed transactions

### Code Organization

- Keep files focused and single-purpose
- Use appropriate access control levels
- Group related functionality together
- Follow the existing project structure
- Separate UI, business logic, and data layers

## Security Guidelines

### Private Key Management

- Use iOS Keychain for secure storage
- Implement proper key derivation
- Never store keys in plain text
- Use hardware wallet integration when available
- Implement proper backup and recovery

### Transaction Security

- Validate all transaction parameters
- Implement proper signature verification
- Use secure random number generation
- Handle transaction failures gracefully
- Implement proper error handling

### Network Security

- Use HTTPS for all API calls
- Implement certificate pinning
- Validate server responses
- Handle network timeouts properly
- Implement retry mechanisms

## Testing

### Test Requirements

- All new features must include tests
- Maintain 90%+ code coverage
- Test on multiple iOS versions
- Include security tests for wallet functionality
- Test on different network conditions

### Running Tests

```bash
# Run all tests
swift test

# Run specific test
swift test --filter TestWalletSecurity

# Run with coverage
swift test --enable-code-coverage
```

### Test Structure

- Unit tests for individual components
- Integration tests for blockchain interactions
- Security tests for wallet functionality
- UI tests for user interactions
- Performance tests for large transactions

### Security Testing

- Test private key generation
- Test transaction signing
- Test network communication
- Test error handling
- Test edge cases

## Pull Request Process

### Before Submitting

1. Ensure all tests pass
2. Update documentation if needed
3. Add examples for new features
4. Check code coverage
5. Review for security implications
6. Test on multiple devices and networks

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Security enhancement
- [ ] Documentation update

## Security Considerations
- [ ] No sensitive data exposed
- [ ] Proper error handling implemented
- [ ] Input validation added
- [ ] Security tests included

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Security tests added/updated
- [ ] Manual testing completed
- [ ] Multiple network testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Security guidelines followed
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Examples added/updated
```

## Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):
- MAJOR version for incompatible API changes
- MINOR version for backwards-compatible functionality
- PATCH version for backwards-compatible bug fixes

### Release Checklist

- [ ] All tests passing
- [ ] Security audit completed
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version tags created
- [ ] Release notes prepared
- [ ] Examples tested
- [ ] Multiple network testing completed

### Security Release Process

1. **Immediate Response**: Address critical security issues immediately
2. **Disclosure**: Follow responsible disclosure guidelines
3. **Testing**: Thorough testing before release
4. **Communication**: Clear communication to users
5. **Documentation**: Update security documentation

## Getting Help

- Create an issue for bugs or feature requests
- Join our discussions for questions
- Review existing issues and pull requests
- Check the documentation for common solutions
- Contact security team for security issues

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation
- Security acknowledgments

Thank you for contributing to iOS Web3 Wallet Framework! 