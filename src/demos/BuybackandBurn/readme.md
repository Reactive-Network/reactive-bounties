# Automated Token Buyback and Burn


- Target Bounty : [Automated Token Buyback and Burn](https://github.com/Reactive-Network/reactive-bounties/issues/3)


- Target Task : Implement contracts that automatically buy and burn a portion of the token supply when certain on-chain metrics are met, such as protocol revenue reaching a predefined threshold 

## Contact Me :

linkedin : [link](https://www.linkedin.com/in/aditya-chaurasia-10998622b/?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app)


## Overview


This bounty submission simulates a use case of Reactive Network,
 employing two key capabilities:


* Low-latency monitoring of logs emitted by arbitrary contracts in L1 Network (Sepolia testnet in this case).
* Calls from Reactive Network to arbitrary L1 contracts.










There are Four main contracts involved in this scenario:


* Protocol contract (Origin chain).
* Reactive contract (Reactive chain).
* ProtocolTokenManager contract (Destination chain).
* ProtocolToken contract (Destination chain).


## Explanation of My solution for Bounty


 - Protocol contract is has main functionalities in other protocols like flashloans,Leverage markets  


 - So first user will addfunds in protocol (liquidate protocol) when user adds function it emits event called FundsAdded /FundsRemoved when this event occur 


 - Our reactive smart contract comes into role and when our FundsAdded/FundsRemoved event is emitted by protocol contract it listen to event and triggers the `ProtocolTokenManager` contract 


 - ProtocolTokenManager manages the token for protocol based on users activity in the protocol and when reactive contract call the ProtocolTokenManager it will Mint/Burn ProtocolToken respectively


### Protocol contract (Origin chain) 


The `Protocol contract` is a smart contract which has basic functionalities of protocols like depositeFunds and withdraw funds when ever user `deposite / withdraw` funds `FundsAdded/FundsRemoved` event is emmited


### Reactive contract (Reactive chain) 


The `Reactive contract` is a smart contract designed for the Reactive Network, implementing the `IReactive` interface. It subscribes to events of `Protocol contract` on the Sepolia chain and processes them through the `react` function. When an event is received, it emits a detailed `Event` log and,


-  when `Protocol contract` emits `FundsAdded` event reactive contract triggers a `addedfunds` function on `ProtocolTokenManager` on Destination chain 


-  when `Protocol contract` emits `FundsRemoved` event reactive contract triggers a `withdrawFunds` function on `ProtocolTokenManager` on Destination chain 




### ProtocolTokenManager contract (Destination chain)


The `ProtocolTokenManager` is a manager of `Protocol token` in which automatically mints token if user invest in protocol and also burn token if user withdraw from protocol 

- when user invest in protocol the reactive network calls `addedfunds` function which mints the protocol token automatically

- and when user withdraw funds the reactive network calls `withdrawFunds` function which burns token 

- here in `ProtocolTokenManager` it has a `TOKEN_TO_PROTOCOL_RATIO=0.005 ether` which indicates that for every 0.005 eth investment in protocol the user gets a protocol token 



### Further Considerations


this can be widely usable by `LIQUID STAKING PROTOCOLS` which enables a huge use real world usecase 

## Deployment & Testing


To deploy testnet contracts to Sepolia, follow these steps, making sure you substitute the appropriate keys, addresses, and endpoints where necessary. You will need the following environment variables configured appropriately to follow this script:


* `export SEPOLIA_RPC=`
* `export SEPOLIA_PRIVATE_KEY=`
* ` export SEPOLIA_MANAGER_PRIVATE_KEY=`
* `export REACTIVE_RPC=`
* `export REACTIVE_PRIVATE_KEY=`
* `export SYSTEM_CONTRACT_ADDR=`
* `export CALLBACK_SENDER=`


You can use the recommended Sepolia RPC URL: `https://rpc2.sepolia.org`.


```bash
  forge install openzeppelin/openzeppelin-contracts
```

### Step 1


Deploy the `Protocol contract` (origin chain contract) and assign the `Deployed to` address from the response to `PROTOCOL_ADDR`.

- Transaction [hash](https://sepolia.etherscan.io/tx/0x479ce52202a305bde9c3f09f7f72606304c735f51d3d54050ed869e8cf2aa10f)



```bash
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_MANAGER_PRIVATE_KEY src/demos/BuybackandBurn/Protocol.sol:Protocol --legacy
```

### Step 2 

Deploy the `ProtocolTokenManager` (destination chain contract) and assign the `Deployed to` address from the responce to `PROTOCOL_TOKEN_MANAGER_ADDR`

- Transaction [hash](https://sepolia.etherscan.io/tx/0x4fec042ea145f3ca856e9eeb0cdbd476e76f60df53c8c031b3dcd1a5888c0a7c)

```bash
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_MANAGER_PRIVATE_KEY src/demos/BuybackandBurn/ProtocolTokenManager.sol:ProtocolTokenManager --constructor-args $CALLBACK_SENDER --legacy
```


### Step 3


Deploy the `Protocol Token` (destination chain contract) and assign the `Deployed to` address from the response to `PROTOCOL_TOKEN_ADDR`.

- Transaction [hash](https://sepolia.etherscan.io/tx/0x3240f554b2ad82ed4db4dd2ca7766de0abc15f6bcae062c6da43220078116194)



```bash
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_MANAGER_PRIVATE_KEY src/demos/BuybackandBurn/Token.sol:ProtocolToken --constructor-args $PROTOCOL_TOKEN_MANAGER_ADDR --legacy
```


### Step 4

set Protocol token as the token in `PROTOCOL_TOKEN_MANAGER`
by protocol manager

- Transaction [hash](https://sepolia.etherscan.io/tx/0x934c41c15800ab14ff6000e928c999b1dfcac622364532cb6714710b4f747df3)

```bash 
cast send $PROTOCOL_TOKEN_MANAGER_ADDR 'setProtocolToken(address)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_MANAGER_PRIVATE_KEY  $PROTOCOL_TOKEN_ADDR  --legacy 
```

### Step 5 

Deploy the `RSC` (reactive contract), configuring it to listen to `PROTOCOL` and to send callbacks to `PROTOCOL_TOKEN_MANAGER`.

- Transaction [hash](https://kopli.reactscan.net/rvm/0xcbfa155b74ad8abb3b0303c2ef2a55af9c3fb5bb/7)


```bash
forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/demos/BuybackandBurn/ReactiveSmartcontract.sol:RSC --constructor-args $SYSTEM_CONTRACT_ADDR $PROTOCOL_ADDR $PROTOCOL_TOKEN_MANAGER_ADDR --legacy
```



### Step 6


Adds funds for Protocol 


```bash
cast send $PROTOCOL_ADDR 'depositeFunds()' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY --value 0.01ether --legacy
```

- Transaction [hash](https://sepolia.etherscan.io/tx/0x4db507a0cd3c243f6cebe74ac2d6733468051a0c614172c0d4fa56ec251674fa)

this transaction emmited `FundsAdded` which is monitored by reactive network and triggered  react function at []()

and reactive network sent a callback to PROTOCOL_TOKEN_MANAGER to `Mint` user their respective tokens

- Transaction [hash](https://kopli.reactscan.net/rvm/0xcbfa155b74ad8abb3b0303c2ef2a55af9c3fb5bb/8)

    Callback is send from reactive network

- Transaction [hash](https://sepolia.etherscan.io/tx/0x9dbc114f2b2f8e3069526f6df8dde8a2b16c83aeb55f15f31eabfd86ca3011cb)

### Step 7 

remove funds from protocol

- Transaction [hash](https://sepolia.etherscan.io/tx/0xcf8f05adccf145309fe88532f4bbd3c4797d3cec54077b4519d3bc7794613342)

```bash
cast send $PROTOCOL_ADDR 'withdrawFunds(uint256)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY  0.01ether --legacy
```

this transaction emmited `FundsAdded` which is monitored by reactive network and triggered  react function at []()

and reactive network sent a callback to PROTOCOL_TOKEN_MANAGER to `Burn` user their respective tokens


- Transaction [hash](https://kopli.reactscan.net/rvm/0xcbfa155b74ad8abb3b0303c2ef2a55af9c3fb5bb/9)

    Callback is send from reactive network

- Transaction [hash](https://sepolia.etherscan.io/tx/0x6dc4a1654c100e7c2ecefbffd3bd3b8940e1242cee13933c9190b1a9da7e2d31)
