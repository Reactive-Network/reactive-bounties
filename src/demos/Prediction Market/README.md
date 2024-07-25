
# Automated Prediction Market with Reactive Listener

## Overview

This project demonstrates an automated prediction market that rewards users based on the Fear and Greed Index (FGI). The system leverages an oracle to fetch the FGI and utilizes a reactive network for event monitoring and automated payouts.

### Key Concepts

- Users place bets on the Fear and Greed Index (FGI) through the `PredictionMarket` contract.
- The `ReactiveListener` contract monitors events and initiates payouts based on the market outcome.

### Origin Chain and Destination Chain Contracts

- The `PredictionMarket` contract handles bet placement, FGI updates, and payout distribution.
- The `ReactiveListener` contract listens for events and triggers the payout process.

## Deployment

### Prerequisites

Ensure you have the following environment variables set up:

```
export SEPOLIA_RPC="<YOUR_SEPOLIA_RPC_URL>"
export SEPOLIA_PRIVATE_KEY="<YOUR_SEPOLIA_PRIVATE_KEY>"
export REACTIVE_RPC="<YOUR_REACTIVE_RPC_URL>"
export REACTIVE_PRIVATE_KEY="<YOUR_REACTIVE_PRIVATE_KEY>"
export SYSTEM_CONTRACT_ADDR="<YOUR_SYSTEM_CONTRACT_ADDR>"
```
### Deploy the Contracts

1. Deploy the `PredictionMarket` contract to Sepolia:

   ```
   forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/demos/PredictionMarket/PredictionMarket.sol:PredictionMarket  # deployed on <0x5052DEE738Fd127fD75719Ff53D0797FCCA8b3f9>
   ```

2. Assign the deployment address to the environment variable `ORACLE_ADDR`.

3. Deploy the `ReactiveListener` contract, configuring it to send callbacks to the `PredictionMarket` contract:

   ```
   forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/demos/PredictionMarket/ReactiveListener.sol:ReactiveListener --constructor-args $SYSTEM_CONTRACT_ADDR $ORACLE_ADDR # deployed to <0xAeAd482f1a974B6b59D268b141d173Faf488FE93>
   ```

## Testing the Workflow

Test the whole setup by placing a bet and updating the FGI:

1. Place a bet on the `PredictionMarket` contract:

   ```
   // Sample transaction for placing a bet
   predictionMarket.placeBet(<marketId>, BetOption.Fear, { value: web3.utils.toWei('1', 'ether') });
   ```
2. Run oracle to update the fgi or you can custom send the tx 
3. Wait for Updating the FGI to close the market and trigger payouts:

   ```
   // Sample transaction for updating the FGI
   predictionMarket.setFGI(<marketId>, 60); // Assuming 60 indicates Greed
   ```

After a few moments, the transaction is picked up by the Reactive Network, and it calls the contract on the destination chain to distribute the payouts. The Reactive and Sepolia transaction hashes are provided below:

```https://kopli.reactscan.net/rvm/0x032e6aefe42d2baa57ee1198cbc04090fa17a639/45
https://sepolia.etherscan.io/tx/0x5c595858abf4545d516703a0bf23eed8fe70d1dbc33edff3de4e7974e3743353
```

This project demonstrates a seamless prediction market mechanism that rewards users based on an unbiased oracle fetched from an api, ensuring transparency and fairness.
