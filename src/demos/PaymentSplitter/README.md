
# Payment Splitter: Splitting Payments Across Multiple Wallets

## Overview

This project demonstrates a payment splitting mechanism that distributes incoming payments to multiple wallets without charging the sender any additional fees.

### Key Concepts

- Monitoring of payments received by the `PaymentSplitter` contract through events emitted on the Sepolia Network.
- Calls from the Reactive Network to the `PaymentSplitter` contract to split the balance equally.

### Origin Chain and Destination Chain Contracts

The `PaymentSplitter` contract emits logs on ETH received for the Reactive Network and also contains the function for the callback contract to split the payment.

## Reactive Contract

The Reactive contracts implement the logic of event monitoring and initiating calls back to the destination chain.

## Deployment

### Prerequisites

Ensure you have the following environment variables set up:

```
export SEPOLIA_RPC="<YOUR_SEPOLIA_RPC_URL>"
export SEPOLIA_PRIVATE_KEY="<YOUR_SEPOLIA_PRIVATE_KEY>"
export REACTIVE_RPC="<YOUR_REACTIVE_RPC_URL>"
export REACTIVE_PRIVATE_KEY="<YOUR_REACTIVE_PRIVATE_KEY>"
export SYSTEM_CONTRACT_ADDR="<YOUR_SYSTEM_CONTRACT_ADDR>"
export ORIGIN_ADDR="<YOUR_ORIGIN_ADDR>"
```

### Deploy the Contracts

1. Deploy the `PaymentSplitter` contract to Sepolia:

   ```
   forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/demos/PaymentSplitter/PaymentSplitter.sol:PaymentSplitter  # deployed on 0xc56Ba0Ad041eb1d5F54d33A062f82a1D0f091F92
   ```

2. Assign the deployment address to the environment variable `ORIGIN_ADDR`.

3. Deploy the Reactive contract, configuring it to send callbacks to `ORIGIN_ADDR`:

   ```
   forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/demos/PaymentSplitter/ListenerReactive.sol:ListenerReactive --constructor-args $SYSTEM_CONTRACT_ADDR $ORIGIN_ADDR # deployed to 0x0063b71A346a4fDd5a7DbFa443eDBfcC09740Cd2
   ```

## Testing the Workflow

Test the whole setup by sending ETH to the contract address:

```
sample tx: https://sepolia.etherscan.io/tx/0xa559b75666810ce04c592f883303211f21e585b46a27eb2d400615b50d0865cc
```

After a few moments, the transaction is picked up by the ReactVM, and it calls the contract on the destination chain. The funds are then distributed through the callback. The Reactive and Sepolia transaction hashes are provided below:

```
https://kopli.reactscan.net/rvm/0x032e6aefe42d2baa57ee1198cbc04090fa17a639/27;
https://sepolia.etherscan.io/tx/0xbbfb7d110b27f8000c8721dea28ece9e710b1835fe3e91baabb8da385a3c1ca8
```

This project demonstrates a seamless payment splitting mechanism that can be used in various decentralized applications without incurring additional costs for the sender.
