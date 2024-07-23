This is application for Automated Insurance Payouts bounty.

My contact e-mail: ncg8j6dz@proton.me

## Problem Statement and Proposed Solution

This proposed solution for Automated Insurance Payouts with Reactive Network uses EVM event as formal criteria for insurance claim and compensation in one automated step. It can be viewed as manifestation of "Code Is Law" attitude and completely eliminates the problem of decision bias that can happen in Validation, Investigation and Voting phases of usual decentralized insurance payout process (like Nexus Mutual).

Zero time wasted on claim review can bear massive advantages for Policyholder, while Insurance Carrier can charge more premium for such feature. Absence of necessity to present and review evidence of incident can be viewed in positive key for both parties, as contract agreements abuse, possible inadequate behavior of counter agent and obligation to gather quorum can be fully dismissed.

Automation of Insurance Payouts to some level can be achieved without Reactive Smart Contracts with use of regular Solidity tools (modifiers, hard-coded function callbacks, etc), but those methods can't be applied to already deployed smart contracts. With help of Reactive Network this solution removes such disadvantage and expands insurance market potential to already deployed smart contracts, which would be difficult or even impossible without use of RSC.

## Use case

Genius Developer created and deployed `SecureContract.sol` as a sort of piggy bank – everyone can send funds there, but only he can spend them. To restrict unauthorized access to piggy funds spending Genius Developer created *onlyGeniusDeveloper()* modifier, but for some reason he forgot to use it while writing *transferEth()* function. As a result a bug was introduced, which allows anyone to spend his piggy funds.

Unaware of this critical error but horrified of thought that some Mysterious Hecker could steal his piggy funds he applied for insurance coverage to Whatever Insurance. For some reason Whatever Insurance, which controls a vault `GenerousVault.sol`, also missed this bug and insured the fuck outta this contract. As an insurance plan they agreed to deploy oracle to monitor spending of piggy funds, special judge to decide if transactions were unauthorized, and executioner for automatic payouts.

The oracle part consists of `oracle.py` to watch SecureContract's transactions off-chain, and `HonestOracle.sol` to emit event inside EVM with *sender* and *amount* of those transactions. They decided to use new Reactive Smart Contract technology to combine roles of judge and executioner in one contract named `ReactiveJudge.sol`. If HonestOracle emits event in which *sender* is not Genius Developer, then ReactiveJudge transfers from GenerousVault to Genius Developer 50% of event's *amount*.

In context of Insurance Model:
* Genius Developer – Insurance Policyholder
* Whatever Insurance – Insurance Carrier
* Mysterious Hecker – Insurance incident Trigger

In context of Reactive Network:
* SecureContract.sol – L1 Contract
* HonestOracle.sol – L1 Source Contract
* GenerousVault.sol – L1 Callback Contract
* ReactiveJudge.sol – Reactive Contract

## Preparations, deployment and testing

To prepare for deployment and testing you will need:
* 3 EOAs and corresponding private keys (can easily be made with MetaMask).
* Foundry to deploy contracts and cast transactions. Setup instructions can be found at the root of this repository.
* Python 3 to run oracle backend. If you are a Linux user it should be already pre-installed in your system, for MacOS and Windows you can get it from [here](https://www.python.org/downloads/).
* [Infura](https://app.infura.io/login) API key to feed the oracle EVM data (free Core Plan is sufficient).

### Preparations
1. You will need `.env` with the following environment variables:
```sh
# Constants:
SEPOLIA_RPC=https://rpc2.sepolia.org
REACTIVE_RPC=https://kopli-rpc.reactive.network/
SYSTEM_CONTRACT_ADDR=0x0000000000000000000000000000000000FFFFFF
HONEST_ORACLE_TOPIC_0=0xbc81b6bd809362423e274881c88ccb051c3a5e8cf8c9b6f8b625ddb589484e85

# API key for oracle:
INFURA_PROJECT_ID=<INSERT_API_KEY_HERE>

# EOAs addresses:
GENIUS_DEVELOPER_ADDR=<INSERT_ADDRESS_HERE>
WHATEVER_INSURANCE_ADDR=<INSERT_ADDRESS_HERE>
MYSTERIOUS_HECKER_ADDR=<INSERT_ADDRESS_HERE>

# EOAs private keys:
GENIUS_DEVELOPER_PRIVATE_KEY=<INSERT_PRIVATE_KEY_HERE>
WHATEVER_INSURANCE_PRIVATE_KEY=<INSERT_PRIVATE_KEY_HERE>
MYSTERIOUS_HECKER_PRIVATE_KEY=<INSERT_PRIVATE_KEY_HERE>

# Deployed contracts addresses:
SECURE_CONTRACT_ADDR=<INSERT_ADDRES_FROM_DEPLOYMENT_STEP_1_HERE>
HONEST_ORACLE_ADDR=<INSERT_ADDRES_FROM_DEPLOYMENT_STEP_2_HERE>
GENEROUS_VAULT_ADDR=<INSERT_ADDRES_FROM_DEPLOYMENT_STEP_3_HERE>
```

2. Use a tool like dotenv to load your environment variables, or manually source the dotenv file in your shell session:
```sh
export $(grep  -v  '^#'  .env  |  xargs)
```

3. Login or register at Infura and assign your API key to `INFURA_PROJECT_ID`. If you are a new user, it should be available under "My First Key" link in the dashboard.

4. Install Python libraries for oracle backend to access web3 framework and dotenv file:
```sh
pip3  install  web3==6.20.0
pip3  install  python-dotenv==1.0.1
```

### Deployment

1. First of all, deploy SecureContract.sol under Genious Developer to Sepolia. This contract will be monitored by oracle. Assign the deployment address to the environment variable `SECURE_CONTRACT_ADDR`:
```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $GENIUS_DEVELOPER_PRIVATE_KEY src/demos/AutomatedInsurancePayouts/SecureContract.sol:SecureContract
```

2. Next, deploy HonestOracle.sol under Whatever Insurance to Sepolia. This contract will be the Source Contract. Assign the deployment address to the environment variable `HONEST_ORACLE_ADDR`:
```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $WHATEVER_INSURANCE_PRIVATE_KEY src/demos/AutomatedInsurancePayouts/HonestOracle.sol:HonestOracle
```

3. Next, deploy GenerousVault.sol under Whatever Insurance to Sepolia. This contract will be the Callback Contract. Assign the deployment address to the environment variable `GENEROUS_VAULT_ADDR`:
```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $WHATEVER_INSURANCE_PRIVATE_KEY src/demos/AutomatedInsurancePayouts/GenerousVault.sol:GenerousVault
```

4. Once again update your environment variables, so newly made `SECURE_CONTRACT_ADDR`, `HONEST_ORACLE_ADDR` and `GENEROUS_VAULT_ADDR` could be referenced later:
```sh
export $(grep  -v  '^#'  .env  |  xargs)
```

5. Finally, deploy ReactiveJudge.sol under Whatever Insurance to Reactive Network. This contract will be the Reactive Contract. It is configured to listen to Source Contract `HONEST_ORACLE_ADDR` and to send callbacks to Callback Contract `GENEROUS_VAULT_ADDR`:

```sh
forge create --rpc-url $REACTIVE_RPC --private-key $WHATEVER_INSURANCE_PRIVATE_KEY src/demos/AutomatedInsurancePayouts/ReactiveJudge.sol:ReactiveJudge --constructor-args $SYSTEM_CONTRACT_ADDR $HONEST_ORACLE_ADDR $HONEST_ORACLE_TOPIC_0 $GENEROUS_VAULT_ADDR
```

### Testing

1. Run oracle backend service script **in separate terminal window**:
```sh
python3 oracle.py
```

2. Send some SepETH under Genious Developer to `SECURE_CONTRACT_ADDR`:
```sh
cast send $SECURE_CONTRACT_ADDR --rpc-url $SEPOLIA_RPC --private-key $GENIUS_DEVELOPER_PRIVATE_KEY --value 0.002ether
```

3. Send some SepETH under Whatever Insurance to `GENEROUS_VAULT_ADDR`:
```sh
cast send $GENEROUS_VAULT_ADDR --rpc-url $SEPOLIA_RPC --private-key $WHATEVER_INSURANCE_PRIVATE_KEY --value 0.004ether
```

4. Trigger *transferEth()* function of SecureContract under Mysterious Hecker and steal some SepETH to `MYSTERIOUS_HECKER_ADDR`:
```sh
cast send $SECURE_CONTRACT_ADDR "transferEth(address,uint256)" $MYSTERIOUS_HECKER_ADDR 1000000000000000 --private-key $MYSTERIOUS_HECKER_PRIVATE_KEY --rpc-url $SEPOLIA_RPC
```

This should result in a callback transaction signaling about insurance incident to `GENEROUS_VAULT_ADDR` being initiated by the Reactive Network and automated insurance payout to `GENIUS_DEVELOPER_ADDR` in form of 50% of SepETH stolen by Mysterious Hecker in the last step.

## Example Hashes

### EOAs
* Address Genius Developer: `0x2b32CE6f546a8a3E852DD9356f9f556D17DBd179`
* Address Whatever Insurance: `0xCC0380780Ebf6E906B3EE035e39B1e4Ae0fB6Aa9`
* Address Mysterious Hecker: `0xC6B9d45be6FcBdf065f5c58DBc7faD657D9d0147`

### Contracts
* Address SecureContract.sol: `0x45f53c968b69b391EB44aa8dd6CB134056BC4a65`
* Address HonestOracle.sol: `0xBB890C1a5362205d3483b4900A95cd7c5F09aBa4`
* Address GenerousVault.sol: `0xC163b84BBfDe7f81760a904EaeCAED346cd13F27`
* Address ReactiveJudge.sol: `0x452086a3bA3B135D05a20B309981EC20eE1ab0D1`

### Transactions
1. Genius Developer deploys SecureContract.sol: `0x7ab29f6003616a3d178fc356edd3ea87fb902ae1f0624a94f80cd35bbd553273`
2. Whatever Insurance deploys HonestOracle.sol: `0x4d93b833ad20462bbe6d83b19869e52bf0967bb8bc2f5b905f66793f7d1757ab`
3. Whatever Insurance deploys GenerousVault.sol: `0x9b868654a604582fa9d05aea343402c989f68931b05923078d4ed496a8f95df0`
4. Whatever Insurance deploys ReactiveJudge.sol: `0x4160edad5c5f6ae129e6c023002bbaf0390fe713d7cc288e79651de642e4beaa`
5. Genius Developer sends 0.0002 SepETH to SecureContract.sol: `0x13bcb80c494099ad9cfabf749087aa710ff9bc6e45371a9c4c5f46a8c7dba865`
6. Whatever Insurance sends 0.0004 SepETH to GenerousVault.sol: `0xf16b11df2f3fc936c1529a8e5590eed4ec76cbe0a78f611d5049626e37c7d33b`
7. Mysterious Hecker steals 0.0001 SepETH from SecureContract.sol: `0xcea2a0ff49f889ebd627195c33a16646d0ac69552c538a7704ffdc559455b44b`
8. Oracle backend sends transaction with event to HonestOracle.sol: `0x90da960d9bfdedd7e8cc78a2224b02f9d9af748213ac346f50add3b6b871927a`
9. RVM sends transaction to relay (Kopli Testnet transaction): `0xb7ee393932ff4b3d0350328db840158844a907ae10107bf1a1710feaff580420`
10. Reactive Sepolia Contract sends callback to GenerousVault.sol: `0x076aa708a9c9defb9f978eea8953d9a8acab9e7d982f104da50b5f9737fea7d6`
11. GenerousVault.sol payouts 0.0005 SepETH to Genius Developer: `0x076aa708a9c9defb9f978eea8953d9a8acab9e7d982f104da50b5f9737fea7d6`

## Limitations and Comments

* This solution does not encourage anyone of trying to steal funds that do not belong to them.
* This solution on purpose implements basic minimalist variant of L1 contracts for the reason of simplification of example.
* This solution on purpose overlooks many real-life insurance practices (like Carrier Premium, Insurance Period, etc) for the reason of simplification of example.
* This solution assumes that Policyholder introduced the bug unintentionally. However, if done on purpose this can be used as an attack vector on Carrier.
* While scenario of this solution may look somewhat infantile, it underlines the principle of aforementioned "Code Is Law" attitude, where stupidity of both Policyholder and Carrier left them with considerable funds loss.
