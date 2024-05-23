# Reactive Bounties

This is the template repository for the participants to use for Reactive Bounty Program.

## Application Criteria

Two types of bounties are available:

- Reactive Smart Contract
- Reactive dApp

### Reactive Smart Contract Application

A successful Reactive Smart Contract bounty application MUST:

- Consist of an open GitHub repository and a cover letter. The cover letter must contain contact information and specify the bounty that the participant is applying for.
- The code MUST implement one of the use cases below with all the functionality that is mentioned in the bounty description.
- The GitHub repository MUST be a copy of the template repository.
- It MUST contain the Reactive Smart Contract, the deploy script, and the instructions for it.
- If the application uses its own Origin and Destination Sepolia smart contracts, the repository MUST also include these contracts, along with their deploy scripts and instructions.
- It MUST contain the address of the Reactive Smart Contract deployed by the participant.
- It MUST contain the addresses of the Origin and Destination Sepolia smart contracts.
- It MUST contain the workflow description for each step, both on Sepolia and Reactive.
- The participant MUST have run this workflow on Sepolia Testnet and Reactive Testnet. The application MUST include the transaction hashes for every step of the workflow.
- If the application implements “cross-chain” functionality, it MUST be emulated by working with two separate (Origin and Destination) smart contracts on Sepolia testnet that only communicate through the RSC.

The following will increase the score of the application:

- A detailed explanation of the problem RSCs solve in that use case and why it is more difficult or even impossible to achieve without them.
- Clear and concise documentation (what it does exactly and how to run it).
- Additional meaningful functionality (by the jury’s opinion). A workflow description with transaction hashes for the additional functionality is required.

### Reactive dApp Application

A successful Reactive dApp bounty application MUST:

- Implement the frontend (web interface), smart contracts, and reactive smart contracts for any of the use cases below.
- Fulfill all the requirements for the Reactive Smart Contract application described above. If you’re only specialized in frontend, consider teaming up with a smart contract developer.
- The repository MUST contain the code for the front end of the dApp, as well as the deploy scripts and instructions.
- The cover letter should include a video of the participant running the intended workflow in their dApp.

## Judging Criteria

The best application in each Reactive Smart Contract bounty will be awarded with the specified reward. Each number is USDT worth of PRQ tokens.

The best application in Reactive dApp will be awarded with the 1200 USDT worth of PRQ tokens. One can win this bounty without winning the Reactive Smart Contract bounty, as well as win both.

The best submission will be determined by the jury of the PARSIQ team members subjectively. We will explain the decision in the winner announcement.

The bounties are deliberately described briefly and generally to encourage the participants to come up with their own features and solutions.

## Reactive Smart Contract Bounties

- **Cross Chain Oracle - 400**
  - Implement a cross-chain oracle system that trustlessly brings data from an oracle on one chain to an oracle on another.

- **Automated Token Buyback and Burn - 400**
  - Implement contracts that automatically buy and burn a portion of the token supply when certain on-chain metrics are met, such as protocol revenue reaching a predefined threshold (come up with a metric that would make sense).

- **Cross-Chain Governance - 400**
  - Implement cross-chain governance contracts to automate governance processes. The RSC will automatically trigger voting events, fund allocations, and other decision-making on the Destination Governance contract based on actions taken on the Origin Governance contract.

- **Automated Governance - 400**
  - Implement automated governance mechanisms where voting results are executed automatically upon meeting a threshold of collected votes or when a time limit expires.

- **Automated Insurance Payouts - 600**
  - Implement automated insurance payouts whenever an insurance event occurs on the relevant oracle.

- **IoT Payouts - 600**
  - Implement automatic payouts based on data from IoT sensors, such as triggering payouts when the temperature falls below a certain threshold.

- **Automated Prediction Market - 600**
  - Implement a prediction market with automated payouts using RSCs.

- **Automated Funds Distribution - 400**
  - Implement a multi-party smart contract wallet that distributes incoming funds among shareholders proportionally to their shares whenever funds arrive, without charging the entity sending the funds for gas fees (memecoins?).

## Development & Deployment Instructions

### Environment Setup

To set up `foundry` environment, run:

```
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
```

Install dependencies:

```
forge install
```

### Development & Testing

To compile artifacts:

```
forge compile
```

### Additional Documentation & Demos

Refer to `TECH.md` for additional information on implementing reactive contracts and callbacks.

The `src/demos` directory contains several elaborate demos, accompanied by `README.md` files for each one.

### Environment variable configuration for running demos

The following environment variables are used in the instructions for running the demos, and should be configured ahead of time.

#### `SEPOLIA_RPC`

RPC address for Sepolia testnet, `https://rpc2.sepolia.org` unless you want to use your own.

#### `SEPOLIA_PRIVATE_KEY`

Private key to your Sepolia wallet.

#### `REACTIVE_RPC`

RPC address for Reactive testnet, should be set to `https://kopli-rpc.reactive.network/`.

#### `REACTIVE_PRIVATE_KEY`

Private key to your Reactive wallet.

#### `DEPLOYER_ADDR`

The address of your Reactive wallet.

#### `SYSTEM_CONTRACT_ADDR`

System contract address for Reactive testnet, should be set to `0x0000000000000000000000000000000000FFFFFF`.

#### `CALLBACK_SENDER_ADDR`

Refer to the documentation for addresses used by Reactive testnet for callbacks on supported networks.
