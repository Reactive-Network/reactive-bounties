## Story

Genius Developer created and deployed `TopSecureContract.sol` as a sort of piggy bank – everyone can send funds there, but only he can spend them. To restrict unauthorized access to piggy funds spending Genius Developer created *onlyGeniusDeveloper()* modifier, but for some reason he forgot to use it while writing *transferEth()* function. As a result a bug was introduced, which allows anyone to spend his piggy funds.

Unaware of this critical error but horrified of thought that some Mysterious Hecker could steal his piggy funds he applied for insurance coverage to Whatever Insurance. For some reason Whatever Insurance, which controls a vault `GenerousInsurance.sol`, also missed this bug and insured the fuck outta this contract. As an insurance plan they agreed to deploy oracle to monitor spending of piggy funds, special judge to decide if transactions were unauthorized, and executioner for automatic payouts.

The oracle part consists of `oracle.py` to watch TopSecureContract's transactions off-chain, and `HonestOracle.sol` to emit event inside EVM with *msg.sender* and *amount* of those transactions. They decided to use new Reactive Smart Contract technology to combine roles of judge and executioner in one contract named `ReactiveJudge.sol`. If HonestOracle emits event in which *msg.sender* is not Genius Developer, then ReactiveJudge transfers from GenerousInsurance to Genius Developer 50% of event's *amount*.

In context of Reactive Network:
* HonestOracle.sol – Source Contract
* GenerousInsurance.sol – Callback Contract
* ReactiveJudge.sol – Reactive Contract

## Dotenv, deployment and testing

For deployment and testing you will need 3 EOAs and corresponding private keys to be present in your dotenv file. The 3 EOAs map to Genius Developer (policyholder of insurance), Watever Insurance (insurer) and Mysterious Hecker (trigger of insurance event). Story aside, **if you want less hustle they can be same EOA**. In that case you can have only one EOA address and private key and should modify the following instruction examples accordingly. Also **you will need Infura API key** for the oracle.

### Dotenv file
1. You will need `.env` with the following environment variables:
```sh
# Constants:
SEPOLIA_RPC=https://rpc2.sepolia.org
REACTIVE_RPC=https://kopli-rpc.reactive.network/
SYSTEM_CONTRACT_ADDR=0x0000000000000000000000000000000000FFFFFF

# API key for oracle:
INFURA_PROJECT_ID=<INSERT_API_KEY_HERE>

# EOAs addresses:
GENIUS_DEVELOPER_ADDR=<INSERT_ADDRES_HERE>
WHATEVER_INSURANCE_ADDR=<INSERT_ADDRES_HERE>
MYSTERIOUS_HECKER_ADDR=<INSERT_ADDRES_HERE>

# EOAs private keys:
GENIUS_DEVELOPER_PRIVATE_KEY=<INSERT_PRIVATE_KEY_HERE>
WHATEVER_INSURANCE_PRIVATE_KEY=<INSERT_PRIVATE_KEY_HERE>
MYSTERIOUS_HECKER_PRIVATE_KEY=<INSERT_PRIVATE_KEY_HERE>

# Deployed contracts addresses:
TOP_SECURE_CONTRACT_ADDR=<INSERT_ADDRES_FROM_DEPLOYMENT_STEP_1_HERE>
HONEST_ORACLE_ADDR=<INSERT_ADDRES_FROM_DEPLOYMENT_STEP_2_HERE>
GENEROUS_INSURANCE_ADDR=<INSERT_ADDRES_FROM_DEPLOYMENT_STEP_3_HERE>
```

2. Login or register at [Infura](https://app.infura.io/login) and assign your API key to `INFURA_PROJECT_ID`.

3. Use a tool like dotenv to load your environment variables, or manually source the dotenv file in your shell session:
```sh
export $(grep  -v  '^#'  .env  |  xargs)
```

4. Install Python libraries for oracle backend to access web3 framework and dotenv file:
```sh
pip3  install  web3==6.20.0
pip3  install  python-dotenv==1.0.1
```

### Deployment

1. First of all, deploy TopSecureContract under Genious Developer to Sepolia. This contract will be monitored by oracle. Assign the deployment address to the environment variable `TOP_SECURE_CONTRACT_ADDR`.
```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $GENIUS_DEVELOPER_PRIVATE_KEY src/demos/AutomatedInsurancePayouts/TopSecureContract.sol:TopSecureContract
```

2. Next, deploy HonestOracle under Watever Insurance to Sepolia. This contract will be the Source Contract. Assign the deployment address to the environment variable `HONEST_ORACLE_ADDR`.
```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $WHATEVER_INSURANCE_PRIVATE_KEY src/demos/AutomatedInsurancePayouts/HonestOracle.sol:HonestOracle
```

3. Next, deploy GenerousInsurance under Watever Insurance to Sepolia. This contract will be the Callback Contract. Assign the deployment address to the environment variable `GENEROUS_INSURANCE_ADDR`.
```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $WHATEVER_INSURANCE_PRIVATE_KEY src/demos/AutomatedInsurancePayouts/GenerousInsurance.sol:GenerousInsurance
```

4. Finally, deploy ReactiveJudge under Watever Insurance to Reactive Network. This contract will be the Reactive Contract. It is configured to listen to Source Contract `HONEST_ORACLE_ADDR` and to send callbacks to Callback Contract `GENEROUS_INSURANCE_ADDR`.

```sh
forge create --rpc-url $REACTIVE_RPC --private-key $WHATEVER_INSURANCE_PRIVATE_KEY src/demos/AutomatedInsurancePayouts/ReactiveJudge.sol:ReactiveJudge --constructor-args $SYSTEM_CONTRACT_ADDR $HONEST_ORACLE_ADDR 0x8cabf31d2b1b11ba52dbb302817a3c9c83e4b2a5194d35121ab1354d69f6a4cb $GENEROUS_INSURANCE_ADDR
```

### Testing

1. Send some SepETH under Genious Developer to `TOP_SECURE_CONTRACT_ADDR`
```sh
cast send $TOP_SECURE_CONTRACT_ADDR --rpc-url $SEPOLIA_RPC --private-key $GENIUS_DEVELOPER_PRIVATE_KEY --value 0.02ether
```
2. Send some SepETH under Watever Insurance to `GENEROUS_INSURANCE_ADDR`
```sh
cast send $GENEROUS_INSURANCE_ADDR --rpc-url $SEPOLIA_RPC --private-key $WHATEVER_INSURANCE_PRIVATE_KEY --value 0.04ether
```
3. Run oracle backend service script **in separate terminal window**:
```sh
python3 oracle.py
```
4. Trigger *transferEth()* function of TopSecureContract under Mysterious Hecker and send some SepETH to `MYSTERIOUS_HECKER_ADDR`
```sh
cast send $TOP_SECURE_CONTRACT_ADDR "transferEth(address,uint256)" $MYSTERIOUS_HECKER_ADDR --value 0.01ether --private-key $MYSTERIOUS_HECKER_PRIVATE_KEY --rpc-url $SEPOLIA_RPC
```
5. This should result in a callback transaction to `GENEROUS_INSURANCE_ADDR` being initiated by the Reactive Network and insurance payout to `GENIUS_DEVELOPER_ADDR` in form of 50% of SepETH stolen by Mysterious Hecker in previous step.

## Hashes

EOA Genius Developer: `0x2b32CE6f546a8a3E852DD9356f9f556D17DBd179`
EOA Whatever Insurance: `0x3282b8489F16bf4556090b0778cC5785Cd7E7d0E`
EOA Mysterious Hecker: `0xC6B9d45be6FcBdf065f5c58DBc7faD657D9d0147`

Contract TopSecureContract.sol: `–`
Contract GenerousInsurance.sol: `–`
Contract HonestOracle.sol: `–`
Contract ReactiveJudge.sol: `–`

***development in progress***