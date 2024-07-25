# Automated Crypto Insurance System

## Overview

The Automated Crypto Insurance System consists of two main contracts: CryptoInsurance (the Origin Contract) and InsuranceReactive (the Reactive Contract). This system provides decentralized insurance for cryptocurrency assets, allowing users to create policies, file claims, and receive payouts based on price fluctuations.

### Key Features:

1. **Multiple Insurance Types**: Supports loan, threshold, and sudden drop insurance policies.
2. **Automated Price Checking**: Uses Chainlink price feeds to monitor asset prices.
3. **Claim Processing**: Automatically processes claims when conditions are met.
4. **Meme Coin Rewards**: Distributes meme coins to users who trigger price checks.
5. **Cross-Chain Automation**: Uses a reactive contract to automate price checks across different chains.

## Workflow

```mermaid
flowchart LR
    User([User])
    subgraph OC[Origin Contract - CryptoInsurance]
        CreatePolicy[createPolicy]
        TriggerCheck[triggerPriceCheck]
        ProcessClaim[_processClaim]
    end
    subgraph RC[Reactive Contract - InsuranceReactive]
        React[react]
        EmitCallback[Emit Callback]
    end

    User -->|1. Creates policy| CreatePolicy
    User -->|2. Triggers price check| TriggerCheck
    TriggerCheck -->|3. Emits event| RC
    React -->|4. Detects event| RC
    EmitCallback -->|5. Calls checkAllPriceChanges| OC
    ProcessClaim -->|6. Processes valid claims| OC
```

## Origin Contract (CryptoInsurance)

The CryptoInsurance contract is the main insurance contract deployed on the primary chain. It manages policy creation, price checking, and claim processing.

### Key Features:

1. **Policy Management**: Create and manage different types of insurance policies.
2. **Price Monitoring**: Use Chainlink price feeds to track asset prices.
3. **Automated Claim Processing**: Process claims when conditions are met.
4. **Meme Coin Rewards**: Distribute meme coins for triggering price checks.

### Core Functions:

1. `createPolicy(address asset, InsuranceType insuranceType, uint256 coverageAmount, uint256 triggerPrice)`: Creates a new insurance policy.
2. `triggerPriceCheck()`: Allows users to trigger a price check and earn meme coin rewards.
3. `checkAllPriceChanges(address sender)`: Checks price changes for all supported assets.
4. `_processClaim(address asset, address holder, InsuranceType insuranceType)`: Processes a valid claim.

### Key Events:

1. `PolicyCreated(address indexed holder, address indexed asset, InsuranceType insuranceType, uint256 coverageAmount)`: Emitted when a new policy is created.
2. `ClaimFiled(address indexed holder, address indexed asset, InsuranceType insuranceType, uint256 amount)`: Emitted when a claim is filed.
3. `PriceChanged(address indexed asset, uint256 oldPrice, uint256 newPrice)`: Emitted when an asset's price changes.
4. `TriggerPriceCheck()`: Emitted when a price check is triggered.

## Reactive Contract (InsuranceReactive)

The InsuranceReactive contract is deployed on a separate chain and listens for events from the Origin Contract to trigger automated price checks.

### Key Features:

1. **Event Listening**: Monitors TriggerPriceCheck events from the Origin Contract.
2. **Automated Price Checks**: Triggers price checks on the Origin Contract based on events.

### Core Functions:

1. `react(uint256 chain_id, address _contract, uint256 topic_0, ...)`: Called when a TriggerPriceCheck event is detected.

### Workflow:

1. Listens for TriggerPriceCheck events from the Origin Contract.
2. When detected, emits a Callback event to trigger checkAllPriceChanges on the Origin Contract.

This setup allows for automated and timely price checks across different blockchain networks, ensuring that the insurance system remains up-to-date with current asset prices.


## Set up environment
To deploy and test the contracts, follow these steps. Ensure the following environment variables are configured appropriately:

* `SEPOLIA_RPC`
* `SEPOLIA_PRIVATE_KEY`
* `REACTIVE_RPC`
* `REACTIVE_PRIVATE_KEY`
* `SYSTEM_CONTRACT_ADDR`

You can use the recommended Sepolia RPC URL: `https://rpc2.sepolia.org`.



## Deployment and Interaction Steps

### Step 1: Deploy CryptoInsurance contract on Sepolia
- Deploy the CryptoInsurance contract
```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/CryptoInsurance.sol:CryptoInsurance
```
* Save the returned address in `INSURANCE_CONTRACT_ADDR`
* Transaction hash: [Insert actual transaction hash here]

### Step 2: Deploy InsuranceReactive contract on Reactive Network
-  Deploy the InsuranceReactive contract, passing in the Subscription Service address and the CryptoInsurance contract address

```sh
forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/InsuranceReactive.sol:InsuranceReactive --constructor-args $SYSTEM_CONTRACT_ADDR $INSURANCE_CONTRACT_ADDR
```

- Transaction hash: 

### Step 3: Add a supported asset

-  Call addSupportedAsset function on the CryptoInsurance contract
```sh
cast send $INSURANCE_CONTRACT_ADDR "addSupportedAsset(address,address,uint256)" $ASSET_ADDRESS $PRICE_FEED_ADDRESS $MAX_COVERAGE --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY
```
- This creates a new insurance policy for the specified asset
- Transaction hash: 

### Step 4: Create an insurance policy

- Call createPolicy function on the CryptoInsurance contract

```sh
Copycast send $INSURANCE_CONTRACT_ADDR "createPolicy(address,uint8,uint256,uint256)" $ASSET_ADDRESS 0 $COVERAGE_AMOUNT $TRIGGER_PRICE --value $PREMIUM_AMOUNT --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY
```
- This creates a new insurance policy for the specified asset
- Transaction hash: [Insert actual transaction hash here]

### Step 5: Trigger a price check

- Call triggerPriceCheck function on the CryptoInsurance contract
```sh
cast send $INSURANCE_CONTRACT_ADDR "triggerPriceCheck()" --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY
```
- This emits a TriggerPriceCheck event
- Transaction hashes: 

### Step 6: Automated price check and claim processing

The InsuranceReactive contract detects the TriggerPriceCheck event
It automatically calls checkAllPriceChanges on the CryptoInsurance contract
If any claims are valid, they are automatically processed

### Step 7: Claim meme coin rewards (if applicable)

- Call claimMemeReward function on the CryptoInsurance contract
```sh
cast send $INSURANCE_CONTRACT_ADDR "claimMemeReward()" --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY
```
- This claims any accumulated meme coin rewards for the caller
- Transaction hash: [Insert actual transaction hash here]


## Notes

- The "cross-chain" functionality is emulated using the Sepolia testnet for both Origin (CryptoInsurance) and Destination contracts, with communication facilitated through the Reactive Smart Contract.
- All interactions with the Reactive network are automatic and don't produce traditional transaction hashes.