# Payment Splitted To Multiple Wallets On Arriving Without Charging A Penny Extra From The Sender. 

## Overview

# Key concepts:

- Monitoring of payments received by l1 contract through events emitted on Sepolia Network 
- Calls from Reactive Network to L1 contract to split the balance equally.

### Origin Chain & Dest Chain Contract

This contract emits logs on eth received for Reactive Network and it also contains the function for the callback contract to split payment.


## Reactive Contract

Reactive contracts implement the logic of event monitoring and initiating calls back to destination chain. 


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

First, deploy the PaymentSplitter contract to Sepolia:

```
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/demos/PaymentSplitter/L1.sol:PaymentSplitter  # deployed on 0xc56Ba0Ad041eb1d5F54d33A062f82a1D0f091F92
```

Grab the PaymentSplitter contract address and put it in this environment variable: $ORIGIN__ADDR.

Assign the deployment address to the environment variable ORIGIN_ADDR.

Now deploy the contract to REACTIVE NETWORK. Here 
finally deploy the reactive contract, configuring it to send callbacks
to `ORIGIN_ADDR`.

```
forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/demos/PaymentSplitter/ListenerReactive.sol:ListenerReactive --constructor-args $SYSTEM_CONTRACT_ADDR $ORIGIN_ADDR # deployed to 0x0063b71A346a4fDd5a7DbFa443eDBfcC09740Cd2
```

## Testing the workflow

Test the whole setup by sending ETH on contract address:

```
sample tx: https://sepolia.etherscan.io/tx/0xa559b75666810ce04c592f883303211f21e585b46a27eb2d400615b50d0865cc

```

After a few moments its picked up by the ReactVM and it calls the contract on dest chain, and the funds are distributed through the callback. Reactive and Sepolia transaction hashes are below.


```
https://kopli.reactscan.net/rvm/0x032e6aefe42d2baa57ee1198cbc04090fa17a639/27;
https://sepolia.etherscan.io/tx/0xbbfb7d110b27f8000c8721dea28ece9e710b1835fe3e91baabb8da385a3c1ca8
```

