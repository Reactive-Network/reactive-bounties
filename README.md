# Reactive Bounty Program Documentation

## Introduction

This repository contains the implementation of Reactive Smart Contracts for the Reactive Bounty Program. The project includes automated governance mechanisms, cross-chain governance contracts, and a cross-chain oracle system. These smart contracts address several issues in the smart contract environment, such as cross-chain interoperability and secure automated governance.

## Project Overview

The project consists of the following components:
1. **Automated Governance Mechanisms**: Implemented in the `OriginGovernance` contract, allowing for proposal creation, voting, and automatic execution.
2. **Cross-Chain Governance Contracts**: Includes `OriginGovernance` and `DestinationGovernance` contracts to handle cross-chain interactions.
3. **Cross-Chain Oracle System**: Consists of `OriginOracle` and `DestinationOracle` contracts to facilitate data transfer between chains.

## Getting Started

### Prerequisites

To run this project, you need to have the following software installed:

- Node.js
- npm
- Foundry
- MetaMask wallet

### Repository Structure

```
reactive-bounties-main/
├── contracts/
│   ├── OriginGovernance.sol
│   ├── DestinationGovernance.sol
│   ├── OriginOracle.sol
│   ├── DestinationOracle.sol
├── scripts/
│   ├── deploy.s.sol
├── test/
│   ├── OriginGovernanceTest.sol
│   ├── OracleTest.sol
├── foundry.toml
├── README.md
```

### Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/your-username/reactive-bounties.git
    cd reactive-bounties
    ```

2. Install dependencies:
    ```sh
    npm install
    ```

3. Set up Foundry:
    ```sh
    curl -L https://foundry.paradigm.xyz | bash
    foundryup
    ```

4. Set up the required environment variables:
    ```sh
    export SEPOLIA_PRIVATE_KEY=your-private-key
    export SEPOLIA_RPC=https://rpc.sepolia.org
    ```

### Adding `forge-std` Library

1. Initialize Git in your project if you haven't already:
    ```sh
    git init
    ```

2. Add `forge-std` as a submodule:
    ```sh
    git submodule add https://github.com/foundry-rs/forge-std lib/forge-std
    ```

3. Commit the changes:
    ```sh
    git add .
    git commit -m "Added forge-std submodule"
    ```

## Smart Contracts Overview

### OriginGovernance

Handles proposal creation, voting, and execution on the origin chain. It mitigates common smart contract issues such as unauthorized access and replay attacks by using OpenZeppelin's `Ownable` for ownership management.

### DestinationGovernance

Receives cross-chain events and executes proposals accordingly. Ensures that only the owner can trigger cross-chain events.

### OriginOracle

Handles the sending of data from the origin chain to the destination chain. Ensures that only authorized addresses can send data.

### DestinationOracle

Handles the receiving of data on the destination chain. Ensures that only the owner can trigger data reception.

## Testing

### Running Tests

To run the tests, use the following command:
```sh
forge test
```

This command will compile the contracts and run the tests defined in the `test` directory.

### Unit Tests Overview

- `OriginGovernanceTest.sol`: Tests for proposal creation, voting, and execution in the `OriginGovernance` contract.
- `OracleTest.sol`: Tests for data sending and receiving in the `OriginOracle` and `DestinationOracle` contracts.

## Deployment

### Deployment Script

The deployment script is located at `scripts/deploy.s.sol`. This script deploys the `OriginGovernance`, `DestinationGovernance`, `OriginOracle`, and `DestinationOracle` contracts.

### Deployment Steps

1. Ensure you have the required environment variables set:
    ```sh
    export SEPOLIA_PRIVATE_KEY=your-private-key
    export SEPOLIA_RPC=https://rpc.sepolia.org
    ```

2. Run the deployment script for Sepolia:
    ```sh
    forge script scripts/deploy.s.sol --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY --broadcast
    ```

3. For deploying on the Reactive Network:
    ```sh
    forge script scripts/deploy.s.sol --rpc-url https://kopli-rpc.reactive.network --private-key $REACTIVE_PRIVATE_KEY --broadcast
    ```

### Example Deployment Output for Sepolia

```
==========================

Chain 11155111

Estimated gas price: 1.00000057 gwei

Estimated total gas used for script: 2376822

Estimated amount required: 0.00237682335478854 ETH

==========================

##### sepolia
✅  [Success]Hash: 0x8d26dec0feaa340ed6f1b5b9763ce227dd5778fb0d6f1142e9de5a3128012111
Contract Address: 0x5618815F75D35e247E45a9F504e95cA477Ed4577
Block: 6358235
Paid: 0.000264109069724776 ETH (264109 gas * 1.000000264 gwei)

...

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Transactions saved to: /home/shki/reactive-bounties-main/broadcast/deploy.s.sol/11155111/run-latest.json
```

### Example Deployment Output for Reactive Network

```
==========================

Chain 5318008

Estimated gas price: 0.000000015 gwei

Estimated total gas used for script: 2376822

Estimated amount required: 0.00000000003565233 ETH

==========================

##### 5318008
✅  [Success]Hash: 0x973075b3ad1cbe5e634b1f2eaea2925a7286150dff1ccc1138ec1745b2cfdd7c
Contract Address: 0xef413f5db0871262CDdF8Fd1dD10ACB60D0BEd27
Block: 2941
Paid: 0.000000000002112872 ETH (264109 gas * 0.000000008 gwei)

...

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Transactions saved to: /home/shki/reactive-bounties-main/broadcast/deploy.s.sol/5318008/run-latest.json
```

## Enhancing the Contracts

### Adding Edge Case Handling

To ensure robustness, consider adding additional checks and balances in your smart contracts, such as:
- **Reentrancy Guards**: Prevent reentrancy attacks by using OpenZeppelin's `ReentrancyGuard`.
- **Input Validation**: Ensure all input parameters are validated.
- **Event Emission**: Emit events for all state-changing actions to facilitate easier tracking and debugging.

### Improving Cross-Chain Functionality

To enhance cross-chain interoperability:
- **Use of Oracles**: Integrate with oracle services like Chainlink to fetch and verify off-chain data.
- **Implement Message Passing**: Ensure secure and reliable message passing between chains using protocols like Polkadot or Cosmos.

## Conclusion

By following the above steps, you can set up, test, and deploy the Reactive Smart Contracts for the Reactive Bounty Program. These contracts address several issues in the smart contract environment, providing a robust solution for automated governance and cross-chain interoperability.

For any further assistance, feel free to open an issue in this repository.