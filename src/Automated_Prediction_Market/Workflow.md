# Detailed Workflow Description for Automated Prediction Market

## Sepolia Testnet Steps

1. Deploy the PredictionMarket contract on Sepolia testnet.

```
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/Automated_Prediction_Market/AutomatedPredictionMarket.sol:AutomatedPredictionMarket
```

- Transaction Hash:0xe504627579511324b98c49651e9f3ded62818aa1d3bd1827cd03601f04447094
- Record deployed contract address: `0x19c1965cF2Fa36b8d7c0Dc8A25cA4541d946b1e7`

  1.a. Function call: `initialize(string name, string symbol, uint256 minBet, uint256 feePercentage, uint256 governanceThreshold, uint256 referralRewardPercentage, address[] multiSigWallet, uint256 requiredSignatures)`

- Transaction Hash:0x1f23ed9c25d96521c8885895094b6f2f1cefc5365167b9ad2012f52607afdd2b

2. Create a prediction using the `createPrediction` function.

   - Function call: `createPrediction(string _description, uint256 _duration, uint256[] _options, uint256 _bettingDuration, uint256 _resolutionDuration)`
   - Note the `predictionId` from the `PredictionCreated` event: `0`

-Transaction Hash:0xebf0ca0edb0e93c315a41f3f58feecda3f791e29dbaefa6ac300353a7e0105b2

3. Users purchase shares using the `purchaseShares` function.

- Function call: `purchaseShares(uint256 _predictionId, uint256 _option)`
  - Transaction hash:0x651993839b1737d654bccbc949c6ce48e82caeb4162fbcb51db0ea55459e3118
    [bet1]

-Function call:`setReferral(address _referrer:)` - Transaction hash:0xd5b4c1c78e78f600f96edd0d65441f885e70f668f2502092a4c0de56e57dd86b

- Function call: `purchaseShares(uint256 _predictionId, uint256 _option)`
  -Transaction hash:0x435e626270be43ee160400a34bdd6fcd5089d8fcc958805fd1bb4c6a4f2c2135

4. After the betting period ends, propose a resolution using the `proposeResolution` function.

   - Function call: `proposeResolution(uint256 _predictionId, bool _outcome)`
   - Multiple resolutions can be proposed
   - Transaction Hash:0xc2b0d0942a431790249241c68432be0d8ac8cb36484d28e70a6ed7aa37c94053

5. MultiSig wallet members vote on resolutions using the `voteOnResolution` function.

   - Function call: `voteOnResolution(uint256 _predictionId, uint256 _resolutionIndex, bool _support)`
   - Repeat for each MultiSig member until required signatures are met
     -Transaction Hash:0x358d1cdfc8712fdd273b808510cf23242c5a88bb64b3a39a4ea31ad7b2504655

6. Once enough votes are collected, the resolution is finalized automatically.
   - This emits a `PredictionResolved` event with `topic_0 = 0xe0d11dcca65d89777e74a05aabfc99281a4c018644b33af1b397a7dbf5e2911b`
     -0xdf1b59fbd08386de0f8aceb5d2a8daa577e8f1a2b3e4d5679db1ebae8134396b
     [trnsxn hash of calling distribute via reactive smart contract]

## Additional Feature

### Further more when a user accuires required governance threshold coins by winning bets they can create voting on admininstrative decisions and only people having enough enough governance token can vote for it [thus giving users a sense of power]

## Reactive Testnet Steps

1. Deploy the AutomatedPredictionReactive contract on Reactive testnet.

```
forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/Automated_Prediction_Market/AutomatedPredictionReactive:AutomatedPredictionReactive --constructor-args $SYSTEM_CONTRACT_ADDR $O_ORIGIN_ADDR
```

2. The contract automatically subscribes to the `PredictionResolved` event on deployment.

   - Verify subscription by checking logs or state variables if applicable

3. When a prediction is resolved on Sepolia, the Reactive contract's `react` function is triggered.

   - This is an automatic process, no manual interaction required
   - Record the transaction hash of the `react` function call

4. The `react` function emits a `Callback` event to call `distributeWinnings` on Sepolia.
   - Event parameters:
     - chain_id: SEPOLIA_CHAIN_ID (11155111)
     - to: Address of PredictionMarket contract on Sepolia
     - gasLimit: CALLBACK_GAS_LIMIT (1000000)
     - data: Encoded call to `distributeWinnings(address,uint256)`
       -Transaction Hash:0x0eb0c413f846688ebcc9723ebe43814769a1bf94a7f734f5d973c0160d7c9f13

## Cross-chain Interaction

The cross-chain functionality is emulated by:

1. The PredictionMarket contract on Sepolia emitting the `PredictionResolved` event.
2. The AutomatedPredictionReactive contract on Reactive listening for this event.
3. The Reactive contract then triggering a callback to Sepolia to distribute winnings.

This setup ensures that the two contracts only communicate through the Reactive Smart Contract, simulating a cross-chain interaction.
