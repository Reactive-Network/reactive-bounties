# Reactive Bounties

This is the template repository for the participants to use for Reactive Bounty Program.

## Application Criteria

Two types of bounties are available:

- Reactive Smart Contract - 400-600 USDT worth of PRQ bounties
- Reactive dApp - 1200 USDT worth of PRQ bounty

### Reactive Smart Contract Application

A successful Reactive Smart Contract bounty application MUST:

- Consist of a pull request to this GitHub repository and a cover letter. The cover letter MUST contain contact information and specify the bounty that the participant is applying for.
- The code MUST implement one of the use cases below with all the functionality that is mentioned in the bounty description.
- The GitHub repository MUST be a copy of the template repository.
- It MUST contain the Reactive Smart Contract, the deploy script, and the instructions for it.
- If the application uses its own Origin and Destination Sepolia smart contracts, the repository MUST also include these contracts, along with their deploy scripts and instructions.
- It MUST contain the address of the Reactive Smart Contract deployed by the participant.
- It MUST contain the addresses of the Origin and Destination Sepolia smart contracts.
- It MUST contain the workflow description for each step, both on Sepolia and Reactive.
- The participant MUST run this workflow on Sepolia and Reactive Testnets. The application MUST include the transaction hashes for every step of the workflow.
- If the application implements “cross-chain” functionality, it MUST be emulated by working with two separate (Origin and Destination) smart contracts on Sepolia testnet that only communicate through the Reactive Smart Contract.

The following will increase the score of the application:

- A detailed explanation of the problem Reactive Smart Contracts solve in that use case and why it is more difficult or even impossible to achieve without them.
- Clear and concise documentation (what it does exactly and how to run it).
- Additional meaningful functionality (by the jury’s opinion). A workflow description with transaction hashes for the additional functionality is required.

### Reactive dApp Application

A successful Reactive dApp bounty application MUST:

- Implement the front end (web interface), smart contracts, and reactive smart contracts for any of the use cases below.
- Fulfill all the requirements for the Reactive Smart Contract application described above. If you’re only specialized in the front end, consider teaming up with a smart contract developer.
- The repository MUST contain the code for the front end of the dApp, as well as the deploy scripts and instructions.
- The cover letter should include a video of the participant running the intended workflow in their dApp.

## Judging Criteria

- The best application in each Reactive Smart Contract bounty will be awarded a specified amount of PRQ tokens equivalent to 400 or 600 USDT, depending on the bounty type you pick. One participant / team (authentified by an email and an Ethereum address) is only eligible for 2 Reactive Smart Contract bounties.
- The best application in the Reactive dApp category will be awarded the amount of PRQ tokens equivalent to 1200 USDT. Participants can win the Reactive dApp bounty without winning the Reactive Smart Contract bounty, and it is possible to win the dApp bounty and up to 2 RSC bounties for one participant / team.
- A jury of PARSIQ team members will subjectively determine the best submission. The decision will be explained in the winner announcement.
- The bounties are intentionally described in a brief and general manner, aiming to encourage participants to develop their own original features and solutions.

## Where to Start and Get Support

- Start by forking [this repository](https://github.com/Reactive-Network/reactive-bounties) and running the code.
- See the information on Reactive Testnet and Faucet [here](https://dev.reactive.network/docs/kopli-testnet).
- Take a look at the [Documentation](https://dev.reactive.network/docs/getting-started) and the [Educational Course](https://dev.reactive.network/education/introduction).
- For any additional technical or organizational information, please join our [Telegram Developer Community](https://t.me/reactivedevs/9).

## Reactive Smart Contract Bounties

- **Cross Chain Oracle — 400**
  - Implement a cross-chain oracle system that trustlessly brings data from an oracle on one chain to an oracle on another.

- **Automated Token Buyback and Burn — 400**
  - Implement contracts that automatically buy and burn a portion of the token supply when certain on-chain metrics are met, such as protocol revenue reaching a predefined threshold (come up with a metric that would make sense).

- **Cross-Chain Governance — 400**
  - Implement cross-chain governance contracts to automate governance processes. The Reactive Smart Contract will automatically trigger voting events, fund allocations, and other decision-making on the Destination Governance contract based on actions taken on the Origin Governance contract.

- **Automated Governance — 400**
  - Implement automated governance mechanisms where voting results are executed automatically upon meeting a threshold of collected votes or when a time limit expires.

- **Automated One-Step Swap — 400**
  - On DEXes, users typically need to approve funds with one transaction and then execute the swap with another. Use Reactive Smart Contracts to reduce this process to a single step for the user.

- **Automated Insurance Payouts — 600**
  - Implement automated insurance payouts whenever an insurance event occurs on the relevant oracle.

- **IoT Payouts — 600**
  - Implement automatic payouts based on data from IoT sensors, such as triggering payouts when the temperature falls below a certain threshold.

- **Automated Prediction Market — 600**
  - Implement a prediction market with automated payouts using Reactive Smart Contracts.

- **Automated Funds Distribution — 400**
  - Implement a multi-party smart contract wallet that distributes incoming funds among shareholders proportionally to their shares whenever funds arrive, without charging the entity sending the funds for gas fees. Applying this for a memecoin distribution is a plus.

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

The Sepolia Testnet RPC address; `https://rpc2.sepolia.org` unless you want to use your own.

#### `SEPOLIA_PRIVATE_KEY`

The private key to your Sepolia wallet.

#### `REACTIVE_RPC`

For the Reactive Testnet RPC address, refer to the [docs](https://dev.reactive.network/docs/kopli-testnet).

#### `REACTIVE_PRIVATE_KEY`

The private key to your Reactive wallet.

#### `DEPLOYER_ADDR`

The address of your Reactive wallet.

#### `SYSTEM_CONTRACT_ADDR`

For the system contract address on the Reactive testnet, refer to the [docs](https://dev.reactive.network/docs/kopli-testnet).

#### `CALLBACK_SENDER_ADDR`

For the callback sender address, refer to the [docs](https://dev.reactive.network/docs/kopli-testnet).
