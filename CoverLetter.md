
# Automated Funds Distribution 

**Target Bounty** : [Automated Funds Distribution](https://github.com/Reactive-Network/reactive-bounties/issues/9) 

**Transaction proofs** : in *Deployment & Testing of Core Bounty theme* section

### Contact Me : 

Gmail : maniveer198@gmail.com

Github : [Maniveer007](https://github.com/Maniveer007)


we have implemented the MULTISIG wallet with fully decentralized Transparency having all functionalitys of a MultiSigWallet but we will discuss mainly about the automated funds distribution because we are targeting [Automated Funds Distribution](https://github.com/Reactive-Network/reactive-bounties/issues/9)

![Multisig wallet](https://cloudfront-us-east-1.images.arcpublishing.com/coindesk/HX2VPWTONNDWVPOLCFVD3X2YHM.png)

## Workflow of our solution 

- first we need to deploy Multisig Wallet follow the instructions below to deploy the contracts while deploying `Multisig Wallet` we initalize the shareholders with the share 

- deploy `Reactive contract` which is core of our solution while deploying we need to initalize supported tokens (reason is given below) 

-  when ever the supported token / Native ETH is transfered to `MULTISIG WALLET` it keep tracking the events and when transfer occur it triggers `distributeFunds` which dristubute recieved tokens/native ETH 

### how distribution works in our MultiSigWallet

the funds are dristributed in the ratio of percentage of share they have in whole MultiSigWallet


## Deployment & Testing of Core Bounty theme

To deploy testnet contracts to Sepolia, follow these steps, making sure you substitute the appropriate keys, addresses, and endpoints where necessary. You will need the following environment variables configured appropriately to follow this script:


```
export SHAREHOLDERS=
export SHARES_OF_SHAREHOLDERS=
export MINIUMUM_PERCENT_SHARES_TO_VOTE=
export SEPOLIA_RPC=
export SEPOLIA_PRIVATE_KEY=
export REACTIVE_RPC=
export REACTIVE_PRIVATE_KEY=
export SYSTEM_CONTRACT_ADDR=
export CALLBACK_SENDER_ADDR=
export SUPPORTED_COINS=
```

`forge install OpenZeppelin/openzeppelin-contracts`

### Step 1 : Create Multisig wallet

first we will need to initalize the initial share holders of multisig , their shares respectively , minimum percentage required to make any decision of wallet transactions and `CALLBACK_SENDER_ADDR` which distribute funds automatically when wallet recieces funds  

.

```bash
forge create --rpc-url $SEPOLIA_RPC --private-key $REACTIVE_PRIVATE_KEY src/demos/Automated-Funds-Distribution/MultiSig.sol:MultiSigWallet --constructor-args $SHAREHOLDERS $SHARES_OF_SHAREHOLDERS $MINIUMUM_PERCENT_SHARES_TO_VOTE $CALLBACK_SENDER_ADDR --legacy 
```
Proof of Output :
```
Deployer: 0xA5dC713243c2543De2F1b923d2e2A9E733f8Fe62
Deployed to: 0xd599C275eDaaA54db9b93AB70AAfcE21095894fA
Transaction hash: 0x52640a0d3b11da591b53597f1e94be2f0604678b6ffa0b4b037d5a4dbb83b126
```
transaction hash :[0x52640a0d3b11da591b53597f1e94be2f0604678b6ffa0b4b037d5a4dbb83b126](https://sepolia.etherscan.io/tx/0x52640a0d3b11da591b53597f1e94be2f0604678b6ffa0b4b037d5a4dbb83b126)

- add Deployed Address as `MULTISIG_ADDR` environment variable 

`export MULTISIG_ADDR=0xd599C275eDaaA54db9b93AB70AAfcE21095894fA    `



### Optional step : Creating MEME coin (If you already have skip this)

Deploy the `MEMECOIN` 

```bash
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/demos/Automated-Funds-Distribution/MemeCoin.sol:MEME --legacy 
```

Proof of Output :
```
Deployer: 0xA5dC713243c2543De2F1b923d2e2A9E733f8Fe62
Deployed to: 0x95DB6d60b9dCD01379fcEe74Ee1E6Eaf38df26c6
Transaction hash: 0xc15ce638dc95576f92e1d03bb5822d81b7c161021d0cf3103487ea7b40487317
```

transaction hash :[0xc15ce638dc95576f92e1d03bb5822d81b7c161021d0cf3103487ea7b40487317](https://sepolia.etherscan.io/tx/0xc15ce638dc95576f92e1d03bb5822d81b7c161021d0cf3103487ea7b40487317)

if you already have a memecoin then add it to Supported Coins/tokens in environment





### Step 2 : DEPLOY REACTIVE CONTRACT 

Deploy the `REACTIVE contract` which on deployment subscribe to `transfer` event emmited by MultiSig contract when it receives `native ETH` whose topic_0 is Exactly equal to transfer event of `ERC20` to have a unique topic_0 we have made a same emit when it recieves Native ETH 

`topic_0 = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef`

- in this step the deployed contract is subscribed to transfer event of MultiSig wallet which emits transfer event on recieving NATIVE ETH  and also subcribe to all transfer events which transfer Coins to `MULTISIG Wallet` emitted by `SUPPORTED_COINS` 

```bash
forge create --rpc-url $REACTIVE_RPC  --private-key $REACTIVE_PRIVATE_KEY src/demos/Automated-Funds-Distribution/Reactive.sol:AutomatedFundsTransferReactive --constructor-args $SYSTEM_CONTRACT_ADDR $MULTISIG_ADDR 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef $SUPPORTED_COINS --legacy 
```
Proof of Output :
```
Deployer: 0xA5dC713243c2543De2F1b923d2e2A9E733f8Fe62
Deployed to: 0xbe057C04eac8E1fa7e2c175283f7c6AbfaEfCaad
Transaction hash: 0x25c4a167f65ec2bcba43b18e6062cd617054efc506893ddd7eb5c11ea73ae54f
```


transaction hash :[0xa5dc713243c2543de2f1b923d2e2a9e733f8fe62](https://kopli.reactscan.net/rvm/0xa5dc713243c2543de2f1b923d2e2a9e733f8fe62/94)



### Step 5 : sending Native ETH To multisig wallet

in this step we send funds to our multisig wallet add the amount of wei you want to send in place of <value> in below script 

```bash
cast send $MULTISIG_ADDR --value <VALUE> --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY  --legacy

```
here what happens is when funds recieved the recieve function of multisig wallet emits a transfer event which is detected by reactive network below is proof for the transaction 

Funds recieved Transaction Hash :[0x6feada77726dc61926a51dd2571f8e37a2add81555fca430a56432a21d213ae4](https://sepolia.etherscan.io/tx/0x6feada77726dc61926a51dd2571f8e37a2add81555fca430a56432a21d213ae4)

now the react function in `AutomatedFundsTransferReactive` contract is triggered by rvm since a transfer event is emited 

Reactive contract triggered : [click here](https://kopli.reactscan.net/rvm/0xa5dc713243c2543de2f1b923d2e2a9e733f8fe62/95)

this reactive network trigeers the `distributeFunds` function in `MULTISIG WALLET`

Transaction Hash : [0x32caac0448d3af9d78ce4f8bf52304f5e29e921337b9eb48721949ce17160751](https://sepolia.etherscan.io/tx/0x32caac0448d3af9d78ce4f8bf52304f5e29e921337b9eb48721949ce17160751)


### Step 6 : minting MEMEcoins to multisig wallet 

in this step we send meme coins to multisig wallet (** this coin should be a Supported coin**)

here we are minting the tokens to multisig wallet which distributes the meme coin automatically 

```bash
cast send $MEMECOIN_ADDR 'mint(address,uint256)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY  $MULTISIG_ADDR <value> --legacy 
```

transation Hash : [0x95ad3be7277703980be1bc0e5df37c39248487135a0eec8f1d2af804d36cbb75](https://sepolia.etherscan.io/tx/0x95ad3be7277703980be1bc0e5df37c39248487135a0eec8f1d2af804d36cbb75)

here in this transaction the coins are sent to `MULTISIG_WALLET`
then reactive network triggers our `AutomatedFundsTransferReactive` contract

Reactive network Transaction :[click here](https://kopli.reactscan.net/rvm/0xa5dc713243c2543de2f1b923d2e2a9e733f8fe62/96)

reactive network triggered `distributeFunds` funds in `MultiSigWallet` to automatically distribute funds

transaction Hash : [0xb77f5039cea2b0cba7c6a744e11b68f149d4b870840ce39201edf55ce43ffeac](https://sepolia.etherscan.io/tx/0xb77f5039cea2b0cba7c6a744e11b68f149d4b870840ce39201edf55ce43ffeac)


you can also try to transfer coins to multisig wallet 



