# Uniswap V2 Stop Order Demo

## Overview

This is the implementation for the Reactive Smart Contract Bounty "Automated Token Buyback and Burn". This setup buys example tokens (Bounty, BNT) for tesnet artificial USDT whenever the price of BNT falls below the predefined threshold.

It's based on the [UniswapStopOrderDemo](https://github.com/Reactive-Network/reactive-smart-contract-demos/tree/main/src/demos/uniswap-v2-stop-order). The build precedure is basically the same.

The differences is what happens when the threshold is reached. The tokens are bought back and burned. Also, the completion functionality is removed, for we don't need it in this use case: we need to buyback and burn as long as we have tokens in the treasury. Also, the amount of the swap is determined not based on the allowance, but based on how much we need to move the exchange rate.

## Origin Chain Contract

The Origin Chain Contract is the Uniswap V2 pair where the BNT is traded versus USDT.

## Reactive Contract

The `ReactiveContract` contract is an example of a reactive contract designed for use with the Uniswap V2 protocol and the Reactive Network. This contract subscribes to events from both a Uniswap V2 pair contract and a treasury contract on Sepolia. When an event matching specific conditions occurs, it triggers a callback to execute buyback and burn.

The `react` function is the core of the contract, which processes events from the reactive network. When a sync event is received from the Uniswap V2 pair, it checks if the reserves are below the specified threshold. If so, it triggers buyback and burn. The function `below_threshold` determines if the reserves meet the conditions for triggering buyback and burn based on the predefined coefficient and threshold.

## Destination Chain Contract

The `TreasuryContact` is designed to facilitate buyback and burn functionality on Uniswap V2 pairs through reactive callbacks. It includes a constructor to initialize the callback sender and the Uniswap V2 Router address. The contract uses the `onlyReactive` modifier to restrict function access to authorized callers, ensuring security.

The `buybackAndBurn` function is invoked upon receiving a trigger from the Reactive Network. It processes parameters including the Uniswap V2 pair address (`pair`), client address (`client`), a boolean (`is_token0`) indicating the token type being sold, and specific thresholds (`coefficient` and `threshold`) defining buyback and burn conditions.

Internally, the `below_threshold` function evaluates whether current Uniswap V2 pair reserves meet predefined criteria for executing buyback and burn. Depending on the boolean `token0`, it calculates the rate based on reserves and checks if it falls below the defined threshold, ensuring accurate decision-making for order execution.

Transaction execution involves verifying the client's token allowance and balance for the sell token, followed by executing a precise token swap using the Uniswap V2 Router (`router`).

Throughout, constants like `DEADLINE` set a timestamp for transaction validity, ensuring timely execution and reliability in processing token swaps. The callback contract is stateless and may be used by any number of reactive buyback and burn contracts as long as they use the same router contract.

## Deployment & Testing

This script guides you through deploying and testing the Uniswap V2 buyback and burn demo on the Sepolia Testnet. Ensure the following environment variables are configured appropriately before proceeding with this script:

* `SEPOLIA_RPC`
* `SEPOLIA_PRIVATE_KEY`
* `REACTIVE_RPC`
* `REACTIVE_PRIVATE_KEY`
* `SYSTEM_CONTRACT_ADDRESS`
* `CALLBACK_SENDER_ADDRESS` on Sepolia

### Step 1

Deploy two ERC-20 tokens. The constructor arguments are the token name and token symbol. Upon creation, the token mints and transfers 100 units to the deployer.

```bash
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/bounties/token-buyback-and-burn/BurnableToken.sol:BurnableToken --constructor-args USDT USDT
```

Repeat the above command for the second token with a different name and symbol:

```bash
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/bounties/token-buyback-and-burn/BurnableToken.sol:BurnableToken --constructor-args Bounty BNT
```

### Step 2

Create a Uniswap V2 pair (pool) using the token addresses created in Step 1. Use the `PAIR_FACTORY_CONTRACT` address `0x7E0987E5b3a30e3f2828572Bb659A548460a3003`. You should get the newly created pair address from the transaction logs on [Sepolia scan](https://sepolia.etherscan.io/) where the `PairCreated` event is emitted.

**Note:** When determining which token is `token0` and which is `token1` in a Uniswap pair, the token with the smaller hexadecimal address value is designated as `token0`, and the other token is `token1`. This means you compare the two token contract addresses in their hexadecimal form, and the one that comes first alphabetically (or numerically since hexadecimal includes both numbers and letters) is `token0`.

```bash
cast send $PAIR_FACTORY_CONTRACT 'createPair(address,address)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY $TOKEN0_ADDR $TOKEN1_ADDR
```

### Step 3

Deploy the destination chain `TreasuryContact` to Sepolia. Use the Uniswap V2 router at `0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008`, which is associated with the factory contract at `0x7E0987E5b3a30e3f2828572Bb659A548460a3003`.

The `CALLBACK_SENDER_ADDRESS` parameter should be set to `0x356bc9241f9b004323fE0Fe75C3d75DD946cF15c`.

Assign the `Deployed to` address from the response to `CALLBACK_CONTRACT_ADDRESS`.

```bash
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/bounties/token-buyback-and-burn/TreasuryContract.sol:TreasuryContract --constructor-args $CALLBACK_SENDER_ADDRESS $UNISWAP_V2_ROUTER_ADDRESS 10 $SEPOLIA_ADDRESS
```

Save the address to which the contract was deployed as `CALLBACK_CONTRACT_ADDRESS` environment variable.

### Step 4

Transfer some liquidity into the created pool:

```bash
cast send $TOKEN0_ADDR 'transfer(address,uint256)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY $CREATED_PAIR_ADDR 10000000000000000000
```

```bash
cast send $TOKEN1_ADDR 'transfer(address,uint256)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY $CREATED_PAIR_ADDR 10000000000000000000
```

```bash
cast send $CREATED_PAIR_ADDR 'mint(address)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY $SEPOLIA_ADDRESS
```

### Step 5

Deploy the reactive buyback and burn contract to the Reactive Network, specifying the following:

`SYSTEM_CONTRACT_ADDRESS`: The system contract that handles event subscriptions.

`CREATED_PAIR_ADDR`: The Uniswap pair address from Step 2.

`CALLBACK_CONTRACT_ADDRESS`: The contract address from Step 3.

`SEPOLIA_ADDRESS`: The client's address deploying the contracts.

`DIRECTION_BOOLEAN`: `true` to sell `token0` and buy `token1`; `false` for the opposite.

`EXCHANGE_RATE_DENOMINATOR` and `EXCHANGE_RATE_NUMERATOR`: Integer representation of the exchange rate threshold below which buyback and burn is executed. These variables are set this way because the EVM works only with integers. As an example, to set the threshold at 1.234, the numerator should be 1234 and the denominator should be 1000.

```bash
forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/bounties/token-buyback-and-burn/ReactiveContract.sol:ReactiveContract --constructor-args $SYSTEM_CONTRACT_ADDR $CREATED_PAIR_ADDR $CALLBACK_CONTRACT_ADDRESS $SEPOLIA_ADDRESS $DIRECTION_BOOLEAN $EXCHANGE_RATE_DENOMINATOR $EXCHANGE_RATE_NUMERATOR
```

### Step 6

To initiate a stop order, authorize the destination chain contract to spend your tokens. The last parameter is the raw amount you intend to authorize. For tokens with 18 decimal places, the above example allows the callback to spend one token.

```bash
cast send $TOKEN_ADDRESS 'approve(address,uint256)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY $CALLBACK_CONTRACT_ADDRESS 1000000000000000000
```

### Step 7

After creating the pair and adding liquidity, we have to make the reactive smart contract work by adjusting the exchange rate directly through the pair, not the periphery.

Liquidity pools are rather simple and primitive contracts. They do not offer much functionality or protect the user from mistakes, making their deployment cheaper. That's why most users perform swaps through so-called peripheral contracts. These contracts are deployed once and can interact with any pair created by a single contract. They offer features to limit slippage, maximize swap efficiency, and more.

However, since our goal is to change the exchange rate, these sophisticated features are a hindrance. Instead of swapping through the periphery, we perform an inefficient swap directly through the pair, achieving the desired rate shift.

```bash
cast send $TOKEN0_ADDR 'transfer(address,uint256)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY $CREATED_PAIR_ADDR 20000000000000000
```

The following command executes a swap at a highly unfavorable rate, causing an immediate and significant shift in the exchange rate:

```bash
cast send $CREATED_PAIR_ADDR 'swap(uint,uint,address,bytes calldata)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY 0 5000000000000000 $SEPOLIA_ADDRESS "0x"
```

After that, the stop order will be executed and visible on [Sepolia scan](https://sepolia.etherscan.io/).

