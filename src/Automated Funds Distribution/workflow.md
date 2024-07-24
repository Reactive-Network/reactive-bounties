# Multi-Party Wallet Reactive Smart Contract Workflow

## Set up environment

To deploy and test the contracts, follow these steps. Ensure the following environment variables are configured appropriately:

- SEPOLIA_RPC
- SEPOLIA_PRIVATE_KEY
- REACTIVE_RPC
- REACTIVE_PRIVATE_KEY
- SYSTEM_CONTRACT_ADDR

You can use the recommended Sepolia RPC URL: https://rpc2.sepolia.org.

## Step 1: Deploy MemeCoin contract on Sepolia

- Deploy the MemeCoin contract with an initial supply
- Initial supply: 1,000,000 BananaCoin (BobBanana)
- Transaction hash: [TRANSACTION_HASH_1]

```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/Automated_Funds_Distribution/MemeCoin.sol:MemeCoin
```

## Step 2: Deploy MultiPartyWallet contract on Sepolia

- Deploy the MultiPartyWallet contract with the following parameters:
  - Minimum contribution: 0.1 ETH
  - Closure time: 7 days from now
  - MemeCoin address: [ADDRESS_FROM_STEP_1]
  - MemeCoinsPerEth: 1000 (1 ETH = 1000 BananaCoin)
- Transaction hash: [TRANSACTION_HASH_2]

```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/Automated_Funds_Distribution/MultiPartyWallet.sol:MultiPartyWallet

```

## Step 3: Deploy MultiPartyWalletReactive contract on Reactive Network

- Deploy the MultiPartyWalletReactive contract, passing in:
  - Subscription Service address: [SUBSCRIPTION_SERVICE_ADDRESS]
  - MultiPartyWallet address: [ADDRESS_FROM_STEP_2]
- Transaction hash: [TRANSACTION_HASH_3]

```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/Automated_Funds_Distribution/MultiPratyWalletReactive.sol:MultiPratyWalletReactive
```

## Step 4: Contribute to the wallet

- Multiple users contribute ETH to become shareholders
- Minimum contribution: 0.1 ETH
- Transaction hashes:
  - User 1 contributes 0.5 ETH: [TRANSACTION_HASH_4a]
  - User 2 contributes 1 ETH: [TRANSACTION_HASH_4b]
  - User 3 contributes 0.75 ETH: [TRANSACTION_HASH_4c]
- Each contribution emits a ContributionReceived event

## Step 5: Close the wallet

- After the closure time (7 days), call the closeWallet function
- This function distributes 1000 BananaCoin to the caller as a reward
- Transaction hash: [TRANSACTION_HASH_5]
- This emits a WalletClosed event, triggering the Reactive contract

## Step 6: Reactive contract calls updateShares

- The Reactive contract detects the WalletClosed event and calls updateShares
- This calculates each shareholders share based on their contribution
- Transaction hash: [TRANSACTION_HASH_6]
- Emits ShareCalculated events for each shareholder

## Step 7: Distribute additional funds(Additional Feature)

- Send additional funds to the wallet using the receive function
- Transaction hash: [TRANSACTION_HASH_7]
- This emits a FundsReceived event, triggering the Reactive contract

## Step 8: Reactive contract calls distributeAllFunds

- The Reactive contract detects the FundsReceived event and calls distributeAllFunds
- This distributes the additional funds to shareholders based on their shares
- It also distributes BananaCoin to shareholders based on their received ETH
- Transaction hash: [TRANSACTION_HASH_8]
- Emits FundsDistributedDirectly and MemeCoinsDistributed events

## Step 9: Shareholder leaves(Additional Feature)

- A shareholder calls the leaveShareholding function
- This function:
  1. Calculates the shareholders share
  2. Applies a 5% penalty fee
  3. Transfers the remaining funds to the shareholder
  4. Marks the shareholder as inactive
- Transaction hash: [TRANSACTION_HASH_9]
- Emits a ShareholderLeft event, triggering the Reactive contract

## Step 10: Reactive contract calls updateShares again

- The Reactive contract detects the ShareholderLeft event and calls updateShares
- This recalculates shares for remaining active shareholders
- Transaction hash: [TRANSACTION_HASH_10]
- Emits ShareCalculated events for each remaining shareholder
