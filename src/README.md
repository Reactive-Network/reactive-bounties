# Cover Letter: Reactive Smart Contract Bounty Application

Dear Bounty Program Organizers,

I am excited to submit my application for the Reactive Smart Contract bounty. I have developed a CryptoInsurance system that leverages the power of Reactive Smart Contracts to enable efficient cross-chain interactions for automated price checking and claim processing.

## Bounty Application Details

- *Bounty*: Reactive Smart Contract Implementation
- *Contact Information*:
  - Name: Harsh kasana
  - Email: harshkasana05@gmail.com

## Project Overview

My implementation focuses on creating a crypto insurance platform where users can insure against price fluctuations of various crypto assets. The system uses a Reactive Smart Contract to automate price checking and potential claim processing across chains. This setup demonstrates the power of Reactive in facilitating cross-chain operations and automating complex workflows in the DeFi insurance space.

## Key Features

1. Fully functional crypto insurance platform on Sepolia testnet
2. Automated price checking triggered by Reactive Smart Contract
3. Cross-chain interaction emulation between Sepolia and Reactive testnets
4. Support for multiple insurance types: Loan, Threshold, and Sudden Drop

## Technical Implementation

The project consists of two main contracts:

1. CryptoInsurance.sol: Deployed on Sepolia, handles the core insurance functionality.
2. InsuranceReactive.sol: Deployed on Reactive, listens for events from Sepolia and triggers callbacks.

The Reactive contract subscribes to the TriggerPriceCheck event from the Sepolia contract. When a price check is triggered, it automatically initiates a callback to check all price changes, showcasing the power of Reactive in automating cross-chain processes.

## Compliance with Requirements

I have ensured that my application meets all the specified requirements, including:

- Proper implementation of the use case
- Inclusion of all necessary contracts, deploy scripts, and instructions
- Deployment of contracts on both Sepolia and Reactive testnets
- Detailed workflow description and transaction hashes for each step
- Emulation of cross-chain functionality as specified

Thank you for considering my application. I look forward to your feedback and the opportunity to contribute to the Reactive ecosystem.

Sincerely,
Harsh Kasana

