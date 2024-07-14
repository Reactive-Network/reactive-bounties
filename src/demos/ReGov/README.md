# Reactive Network Cross-Chain Governance

## Overview

Key concepts:

- Low-latency monitoring of governance request events emitted by arbitrary contracts in the L1 Network (Sepolia testnet in this case).
- Calls from Reactive Network to L1 Governance contracts.

```mermaid
%%{ init: { 'flowchart': { 'curve': 'basis' } } }%%
flowchart TB
    subgraph RN["Reactive Network"]
        subgraph RV["ReactVM"]
            subgraph RC["Reactive Contract"]
                RGR("ReGovReactive")
            end
        end
    end
    subgraph L1["L1 Network"]
        subgraph OCC["Origin Chain Contract"]
            RGE("RegGovEvents")
        end
        subgraph DCC["Destination Chain Contract"]
            RGL1("RegGovL1")
        end
    end

OCC -. emitted log .-> RGR
RGR -. callback .-> DCC

style RV stroke:transparent
```

In practical terms, this general use case can be applicable in any number of scenarios, from simple stop orders to fully decentralized algorithmic trading.

There are three main contracts involved in this scenario:

- Origin chain contract.
- Reactive contract.
- Destination chain contract.

### Origin Chain Contract

This contract, or set of contracts, presumably emits logs of interest to the Reactive Network user. In financial applications, this could be a DEX, such as a Uniswap pool, emitting data on trades and/or exchange rates. Typically, the contract is controlled by a third party; otherwise, mediation by Reactive Network would be unnecessary.

Here, this contract is implemented in ReGovEvents.sol. Its functionality is to send governance requests and emit the corresponding events. This could be called from any chain but requires the owner to have a share of the governance token on the destination chain.

## Reactive Contract

Reactive contracts implement the logic of event monitoring and initiating calls back to L1 chains. These contracts are fully-fledged EVM contracts with the ability to maintain state persistence, subscribe/unsubscribe to multiple event origins, and perform callbacks. This can be done both statically and dynamically by emitting specialized log records, which specify the parameters of a transaction to be submitted to the destination chain.

Reactive contracts are executed in a private subnet (ReactVM) tied to a specific deployer address. This limitation enhances their ability to scale, although it restricts their interaction with other reactive contracts.

In our demo, the reactive contract implemented in ReGovReactive.sol subscribes to governance events emitted by ReGovL1Contract.sol upon deployment. Whenever the observed contract reports a governance decision requiring execution, the reactive contract initiates an authorized L1 callback by emitting a log record with the necessary transaction parameters and payload to ensure proper execution on the destination network.

## Destination Chain Contract

The ReGovL1.sol is the L1 part of the governance logic. The governance contract listens to the voter authorized events and call the appropriate governance function on the destination network.  
For setting a proposal to accepted or rejected, we'll use a common approach based on the voting period and a quorum (minimum number of votes required for the proposal to be valid). We can add a deadline to each proposal, and only proposals that receive enough votes before the deadline will be considered valid.  
To add more dynamic business logic, we'll incorporate a base grant amount and a multiplier for the quorum. This will allow the quorum requirement to scale with the grant amount requested in the proposal.

## Deployment

### Prerequisites

Ensure you have the following environment variables set up:

```
export SEPOLIA_RPC="<YOUR_SEPOLIA_RPC_URL>"
export SEPOLIA_PRIVATE_KEY="<YOUR_SEPOLIA_PRIVATE_KEY>"
export REACTIVE_RPC="<YOUR_REACTIVE_RPC_URL>"
export REACTIVE_PRIVATE_KEY="<YOUR_REACTIVE_PRIVATE_KEY>"
export SYSTEM_CONTRACT_ADDR="<YOUR_SYSTEM_CONTRACT_ADDR>"
export GOVERNANCE_TOKEN_ADDRESS="<YOUR_GOVERNANCE_TOKEN_ADDRESS>"
```

### Deploy the Contracts

First, deploy the governance token contract to Sepolia:

```
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/demos/ReGov/GovernanceToken.sol:GovernanceToken --constructor-args 1000000000000000000 # deployed to 0xd14CF5dCf446612Ef5f766e4cc7e0950DC466077
```

Grab the governance token address and put it in this environment variable: $GOVERNANCE_TOKEN_ADDRESS.

Next, deploy the origin chain contract to Sepolia:

```
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/demos/ReGov/ReGovEvents.sol:ReGovEvents # deployed to 0x1bc8d43e4A8B95B8a8BcB46258458b7176EFd038
```

Assign the deployment address to the environment variable ORIGIN_ADDR.

Now deploy the governance contract to Sepolia (Here, the AUTHORIZED_CALLER_ADDRESS should contain the address you intend to authorize for performing callbacks or use 0x0000000000000000000000000000000000000000 to skip this check):
Other constructor-args should be set as follows:

- BASE_GRANT: The base grant used for calculating the base voting - requirement for a proposal to be accepted (uint256).
- QUORUM_MULTIPLIER: Used to adjust voting requirements based on the grant amount (uint256).
- VOTING_PERIOD: The allowed period for proposal voting (uint256).

```
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/demos/ReGov/ReGovL1.sol:ReGovL1 --constructor-args $GOVERNANCE_TOKEN_ADDRESS $AUTHORIZED_CALLER_ADDRESS $BASE_GRANT $QUORUM_MULTIPLIER $VOTING_PERIOD # deployed to 0x6692AdC196A4CffB1cB1358205C2B0b9A6AdE2a1
```

Assign the deployment address to the environment variable `CALLBACK_ADDR`.

Finally, deploy the reactive contract, configuring it to send callbacks
to `CALLBACK_ADDR`.

```
forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/demos/ReGov/ReGovReactive.sol:ReGovReactive --constructor-args $SYSTEM_CONTRACT_ADDR $CALLBACK_ADDR # deployed to 0x8420Bd1209967d0DBe6c3cdF38dDCe077350Af08
```

## Testing the workflow

Test the whole setup by creating a proposal:

```
cast send $ORIGIN_ADDR 'requestProposalCreate(string,uint256)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY "Proposal 1" 5000000000000000 # sample tx(Sepolia Testnet): sample tx: 0x183657320e5dafb5f2b23ac86e557e4d6ac8c303fde8b3b25e1681274cef88a5
```

After a few moments, the ReactVM calls on the callback contract, and we will have a new proposal record:

```
cast call $CALLBACK_ADDR 'proposals(uint256)(uint256,address,string,uint256,uint256,uint256,bool,uint256,uint256)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY 1
```
