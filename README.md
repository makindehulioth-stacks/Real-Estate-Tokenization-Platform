# 🏢 Real Estate Tokenization Platform

A Clarity smart contract for tokenizing real estate properties on the Stacks blockchain, enabling fractional ownership and seamless trading of property tokens.

## ✨ Features

- 🏗️ **Property Creation**: Create tokenized real estate properties with customizable token supplies and pricing
- 💰 **Token Purchases**: Buy property tokens directly from the property owner
- 📝 **Marketplace Listings**: Create secondary market listings to sell your property tokens
- 🔄 **Peer-to-Peer Trading**: Buy tokens from other holders via active listings
- 📤 **Token Transfers**: Transfer property tokens to other users
- 🔧 **Admin Controls**: Property owners can toggle status and update pricing

## 📋 Contract Overview

The platform manages three core data structures:
- **Properties**: Real estate assets with token supply, pricing, and metadata
- **Token Balances**: Tracks ownership of property tokens by holders
- **Property Listings**: Secondary market listings for token sales

## 🚀 Usage

### Creating a Property

Only the contract owner can create new properties:

```clarity
(contract-call? .Real-Estate-Tokenization-Platform create-property 
    "Luxury Penthouse" 
    "Manhattan, NY" 
    u1000 
    u50000)
```

### Purchasing Tokens

Buy tokens directly from the property owner:

```clarity
(contract-call? .Real-Estate-Tokenization-Platform purchase-tokens u1 u10)
```

### Creating a Listing

List your tokens for sale on the secondary market:

```clarity
(contract-call? .Real-Estate-Tokenization-Platform create-listing u1 u10 u55000)
```

### Buying from a Listing

Purchase tokens from another holder's listing:

```clarity
(contract-call? .Real-Estate-Tokenization-Platform buy-from-listing u1 u5)
```

### Transferring Tokens

Send tokens directly to another user:

```clarity
(contract-call? .Real-Estate-Tokenization-Platform transfer-tokens u1 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC u10)
```

### Canceling a Listing

Remove your active listing:

```clarity
(contract-call? .Real-Estate-Tokenization-Platform cancel-listing u1)
```

## 🔍 Read-Only Functions

### Get Property Details

```clarity
(contract-call? .Real-Estate-Tokenization-Platform get-property u1)
```

### Get Token Balance

```clarity
(contract-call? .Real-Estate-Tokenization-Platform get-token-balance u1 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC)
```

### Get Listing Details

```clarity
(contract-call? .Real-Estate-Tokenization-Platform get-listing u1)
```

### Get Counters

```clarity
(contract-call? .Real-Estate-Tokenization-Platform get-property-nonce)
(contract-call? .Real-Estate-Tokenization-Platform get-listing-nonce)
```

## 🛡️ Admin Functions

### Toggle Property Status

Enable or disable token purchases for a property:

```clarity
(contract-call? .Real-Estate-Tokenization-Platform toggle-property-status u1)
```

### Update Property Price

Change the price per token for a property:

```clarity
(contract-call? .Real-Estate-Tokenization-Platform update-property-price u1 u60000)
```

## ⚠️ Error Codes

- `u100` - Owner only operation
- `u101` - Property/listing not found
- `u102` - Unauthorized action
- `u103` - Already exists
- `u104` - Insufficient balance
- `u105` - Invalid amount
- `u106` - Property not active
- `u107` - Sale not active
- `u108` - Insufficient tokens
- `u109` - Transfer failed

## 🧪 Testing

Run the contract checks:

```bash
clarinet check
```

Run tests (if test files are created):

```bash
clarinet test
```

## 📦 Installation

1. Install [Clarinet](https://github.com/hirosystems/clarinet)
2. Clone this repository
3. Navigate to the project directory
4. Run `clarinet check` to verify the contract

## 🔐 Security Considerations

- Only the contract owner can create new properties
- All token transfers require sufficient balance
- STX payments are handled atomically with token transfers
- Listings can only be canceled by their creators

## 📄 License

MIT License - feel free to use this contract for your projects!

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

---

Built with ❤️ on the Stacks blockchain
