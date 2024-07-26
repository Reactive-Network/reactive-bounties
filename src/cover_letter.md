# Cover Letter: Reactive Smart Contract Bounty Application

Dear Bounty Program Organizers,

I am excited to submit my application for the Reactive Smart Contract bounty. I have developed an Automated Prediction Market system that leverages the power of Reactive Smart Contracts to enable efficient cross-chain interactions.

## Bounty Application Details

- **Bounty**: Reactive Smart Contract Implementation
- **GitHub Profile**: [\[Prakhar-30\]](https://github.com/Prakhar-30)
- **Contact Information**:
  - Name: Prakhar Srivastava
  - Email: srivastavaprakhar3010@gmail.com
  - Telegram: @abhi_here_3010

## Project Overview

My implementation focuses on creating a prediction market where users can bet on various outcomes. The system uses a Reactive Smart Contract to automate the distribution of winnings once a prediction is resolved. This setup demonstrates the power of Reactive in facilitating cross-chain operations and automating complex workflows.

## Key Features

1. Fully functional prediction market on Sepolia testnet
2. Automated winnings distribution triggered by Reactive Smart Contract
3. Cross-chain interaction emulation between Sepolia and Reactive testnets
4. MultiSig wallet integration for secure resolution of predictions
5. Referral System to get more reach
6. Governance Tokens to make contract more adaptable to be open to votings via normal users and promoting decentralization

## Technical Implementation

The project consists of two main contracts:

1. `PredictionMarket.sol`: Deployed on Sepolia, handles the core prediction market functionality.
2. `AutomatedPredictionReactive.sol`: Deployed on Reactive, listens for events from Sepolia and triggers callbacks.

The Reactive contract subscribes to the `PredictionResolved` event from the Sepolia contract. When a prediction is resolved, it automatically triggers the distribution of winnings, showcasing the power of Reactive in automating cross-chain processes.

## Compliance with Requirements

I have ensured that my application meets all the specified requirements, including:

- Proper implementation of the use case
- Inclusion of all necessary contracts, deploy scripts, and instructions
- Deployment of contracts on both Sepolia and Reactive testnets
- Detailed workflow description and transaction hashes for each step
- Emulation of cross-chain functionality as specified

## Need of Reactive Contract

-A typical prediction market can have several users and distributing winning and then claiming the wins would require a lot of mannual work but in this contract once the predictions are resolved with the help of reactive smart contracts which lestens to event emitted on being resoveld and automatically calls the function to distribute winnings to the participants

Thank you for considering my application. I look forward to your feedback and the opportunity to contribute to the Reactive ecosystem.

Sincerely,
Prakhar Srivastava
