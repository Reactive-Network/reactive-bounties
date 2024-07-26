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
- Transaction hash:0x8986a2114729018a29e1307fbd30e6895491a6ca026eab9ce8a419983d5e7c72
- Contract address =>0x96822a0b0227f639eb63b39819cb38efb8eefc9f

```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/Automated_Funds_Distribution/MemeCoin.sol:MemeCoin --constructor-args 1000000000000000000000000
```

## Step 2: Deploy MultiPartyWallet contract on Sepolia

- Deploy the MultiPartyWallet contract:

  - Transaction hash:0xe838d9c2413f554a7ef75f06fb6d1faa9ea6a6714cfc38e20daa4e3a8aa4d58b
  - Contract addr=>0xf7bf412f11c79422a16efcaac6b6a3c7524edf58

```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/Automated_Funds_Distribution/MultiPartyWallet.sol:MultiPartyWallet

```

## Step 3: Deploy MultiPartyWalletReactive contract on Reactive Network

- Deploy the MultiPartyWalletReactive contract, passing in:
  - MultiPartyWallet address: 0xf7bf412f11c79422a16efcaac6b6a3c7524edf58
- Transaction hash: 0xbe34d7a71c7881e00798a1cb3efd04e69d55c0219b5e639c8d8066df33c5a4fd
- Contract addr=>0xc0dc57ebe1647b386b623be699595ffd87e35c2c

```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/Automated_Funds_Distribution/MultiPratyWalletReactive.sol:MultiPratyWalletReactive
```

## Step a:Approve and transfer the MEMECOINS from MemeCoin_Contract to the Wallet Contract Addrress

-txn hash=>0x9cd1e89cbc753a067560b047dc79f76277fd19a6fbbfc8b58086e03e8d47ea35
[approve]

-0xd8d170d88fb43ab166d2913fadc6d024881fd9da412a4d6da57a63f8ceb42138 txn hash
[transfer]

## Step b:Initialize the wallet

- Minimum contribution: 0.01 ETH
- Closure time: 15 minutes from now
- MemeCoin address: 0x96822a0b0227f639eb63b39819cb38efb8eefc9f
- MemeCoinsPerEth: 1000 (1 ETH = 1000 BananaCoin)

-txn hash=>0x25facb5f4fc33bcb719be5b075fba1ed6ef52ccb59ee1e81d567b12c684c18ac txn hash

## Step 4: Contribute to the wallet

- Multiple users contribute ETH to become shareholders
- Minimum contribution: 0.1 ETH
- Transaction hashes:
  - User 1 contributes:
    [TRANSACTION_HASH=>0x71b5cd4d46f1cfd66d4ef7107d3c57235851595a0171178132348d5a609ae687]
  - User 2 contributes:
    [TRANSACTION_HASH=>0x2dc139ed74e2c096eccb9ed15c5aa520a6f3b97a101774e78a380b730a631be0]
- Each contribution emits a ContributionReceived event

## Step c:Additional Feature:Allowig owner to change the closing time(setClosureTime(uint256:new_time))

-reducing the closure time and updating it to end in the next 2 minutes
-TRANSACTION_HASH=>0x2b06e01f7e3acf8009b2913f01fec0bfdc7dd51b59a059d40b250b26276eb47b

## Step 5: Close the wallet

- After the closure time, call the closeWallet function
- This function distributes 1000 BananaCoin to the caller as a reward
- Transaction hash: [TRANSACTION_HASH=>0x0cca7cc9d1ccef94310b51fd38582775d87107684cb8842eb00ab7bf0221d3ef]
- This emits a WalletClosed event, triggering the Reactive contract

## Step 6: Reactive contract calls updateShares

- The Reactive contract detects the WalletClosed event and calls updateShares
- This calculates each shareholders share based on their contribution
- Transaction hash:
  [Transaction_Hash=>0x843b1d5d424d3d7e6456396ccfbb3ae179825a6d7f7cf970cf5b7bf866138958]
  :reactive listening close Wallet
  [TRANSACTION_HASH=>0x120756a75ef645114488286586ff76ef0905a076f0cf3f7a0dfb02b1e0750fb8]
  :update share by reactive
- Emits ShareCalculated events for each shareholder

## Step 7: Distribute additional funds(Additional Feature)

- Send additional funds to the wallet using the receive function
- Transaction hash: [TRANSACTION_HASH=>0xe7d623826730a7b9a520fe5c79df7994c325e8e0a3a76b1716a7381817bbfc05]
- This emits a FundsReceived event, triggering the Reactive contract

## Step 8: Reactive contract calls distributeAllFunds

- The Reactive contract detects the FundsReceived event and calls distributeAllFunds
- This distributes the additional funds to shareholders based on their shares
- It also distributes BananaCoin to shareholders based on their received ETH
- Transaction hash: [0xfcb35aaaa2e5656c855a918405aec40e5e9b3f62394d4796cc676ce6e12dff61]
  -by reactive distribute
- Emits FundsDistributedDirectly and MemeCoinsDistributed events

## Step 9: Shareholder leaves(Additional Feature)

- A shareholder calls the leaveShareholding function
- This function:
  1. Calculates the shareholders share
  2. Applies a 5% penalty fee
  3. Transfers the remaining funds to the shareholder
  4. Marks the shareholder as inactive
- Transaction hash: [TRANSACTION_HASH=>0x039e261c921c8dfc7696776637bbdc4357fc7f7ff78127299bf904f4b1f847fe]
- Emits a ShareholderLeft event, triggering the Reactive contract

## Step 10: Reactive contract calls updateShares again

[leave_TRANSACTION_HASH=>0x53e3c105fa98e5763c488bf37f55b625c68a4cf9088d8604b09aa19b6fd1b223]
-of reactive listening

- The Reactive contract detects the ShareholderLeft event and calls updateShares
- This recalculates shares for remaining active shareholders
- Transaction hash: [0x4f0355296d85515041339804c7ad683bd259a7c16c206302c11554772d2360d3]
- Emits ShareCalculated events for each remaining shareholder

## Repeating

-Sending funds once more
-Transaction hash: [0xf2610d344ce3beeb4a491e1f8e243d05e733fad7c23985e6e3279424489f1cdd]

-Transaction hash: [0x6895161339b95838e1cdda67bf86b53cb8810d65c01e537783bba18ce7ee2d83]
-distribute after second receive
