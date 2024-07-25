This is application for Automated Prediction Market bounty.

My contact e-mail: ncg8j6dz@proton.me

## Problem Statement and Proposed Solution

TEXT

## Use case

TEXT

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
PRICE_ORACLE_TOPIC_0=

# Oracle variables:
INFURA_PROJECT_ID=<INSERT_API_KEY_HERE>
API_DATA_SOURCE=https://api.coingecko.com/api/v3/simple/price
API_DATA_CRYPTOCURRENCY=bitcoin
API_DATA_VS_CURRENCY=usd
ROUND_DURATION=300

# EOAs addresses:
MARKET_CREATOR_ADDR=<INSERT_ADDRESS_HERE>
PARTICIPANT_ONE_ADDR=<INSERT_ADDRESS_HERE>
PARTICIPANT_TWO_ADDR=<INSERT_ADDRESS_HERE>

# EOAs private keys:
MARKET_CREATOR_PRIVATE_KEY=<INSERT_PRIVATE_KEY_HERE>
PARTICIPANT_ONE_PRIVATE_KEY=<INSERT_PRIVATE_KEY_HERE>
PARTICIPANT_TWO_PRIVATE_KEY=<INSERT_PRIVATE_KEY_HERE>

# Deployed contracts addresses:
PRICE_ORACLE_ADDR=<INSERT_ADDRES_FROM_DEPLOYMENT_STEP_1_HERE>
PREDICTION_MARKET_ADDR=<INSERT_ADDRES_FROM_DEPLOYMENT_STEP_2_HERE>
```

2. Use a tool like dotenv to load your environment variables, or manually source the dotenv file in your shell session:
```sh
export $(grep  -v  '^#'  .env  |  xargs)
```

3. Login or register at Infura and assign your API key to `INFURA_PROJECT_ID`. If you are a new user, it should be available under "My First Key" link in the dashboard.

4. Install Python libraries for oracle backend to access web3 framework and dotenv file:
```sh
pip3  install  web3==6.20.0
pip3  install  requests==2.28.2
pip3  install  python-dotenv==1.0.1
```

### Deployment

1. First of all, deploy PriceOracle.sol under Market Creator to Sepolia. This contract will be the Source Contract. Assign the deployment address to the environment variable `PRICE_ORACLE_ADDR`:
```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $MARKET_CREATOR_PRIVATE_KEY src/demos/AutomatedPredictionMarket/PriceOracle.sol:PriceOracle
```

2. Next, deploy PredictionMarket.sol under Market Creator to Sepolia. This contract will be the Callback Contract. Assign the deployment address to the environment variable `PREDICTION_MARKET_ADDR`:
```sh
forge create --rpc-url $SEPOLIA_RPC --private-key $MARKET_CREATOR_PRIVATE_KEY src/demos/AutomatedPredictionMarket/PredictionMarket.sol:PredictionMarket
```

3. Once again update your environment variables, so newly made `PRICE_ORACLE_ADDR` and `PREDICTION_MARKET_ADDR` could be referenced later:
```sh
export $(grep  -v  '^#'  .env  |  xargs)
```

4. Finally, deploy ReactivePayout.sol under Market Creator to Reactive Network. This contract will be the Reactive Contract. It is configured to listen to `PRICE_ORACLE_TOPIC_0` of Source Contract `PRICE_ORACLE_ADDR` and to send callbacks to Callback Contract `PREDICTION_MARKET_ADDR`:

```sh
forge create --rpc-url $REACTIVE_RPC --private-key $MARKET_CREATOR_PRIVATE_KEY src/demos/AutomatedPredictionMarket/ReactivePayout.sol:ReactivePayout --constructor-args $SYSTEM_CONTRACT_ADDR $PRICE_ORACLE_ADDR $PRICE_ORACLE_TOPIC_0 $PREDICTION_MARKET_ADDR
```

### Testing

1. Run oracle backend service script **in separate terminal window**:
```sh
python3 oracle.py
```

2. Trigger *depositEther()* function of PredictionMarket.sol under Participant One by predicting "UP" and sending 0.001 SepETH to `PREDICTION_MARKET_ADDR`:
```sh
cast send $PREDICTION_MARKET_ADDR "depositEther(string)" $PARTICIPANT_ONE_ADDR UP --private-key $PARTICIPANT_ONE_PRIVATE_KEY --rpc-url $SEPOLIA_RPC
```

3. Trigger *depositEther()* function of PredictionMarket.sol under Participant Two by predicting "DOWN" and sending 0.001 SepETH to `PREDICTION_MARKET_ADDR`:
```sh
cast send $PREDICTION_MARKET_ADDR "depositEther(string)" $PARTICIPANT_TWO_ADDR DOWN --private-key $PARTICIPANT_TWO_PRIVATE_KEY --rpc-url $SEPOLIA_RPC
```

4. Chill until countdown in oracle backend terminal window reaches zero and updated price would be emited by `PRICE_ORACLE_ADDR`.

This should result in a callback transaction signaling about prediction winner to `PREDICTION_MARKET_ADDR` being initiated by the Reactive Network and automated prediction market payout in form of 200% of SepETH sent to one of the Participants from second or third step (in rare case if price have not changed in 5 minutes both Participants will get 100% of their deposits back).

## Example Hashes

### EOAs
* Address Market Creator: `xxx`
* Address Participant One: `xxx`
* Address Participant Two: `xxx`

### Contracts
* Address PriceOracle.sol: `0x82ED4C250f4B8663ba5db169f57b8cA50b146f9b`
* Address PredictionMarket.sol: `0xAaCCd08Bc865069df670F11e7B63F0DaD23639Bf`
* Address ReactivePayout.sol: `xxx`

### Transactions
1. Market Creator deploys PriceOracle.sol: `0x5c517b02a7f19cc6f824b144f346c8858e3e7fae58fbdde68d9af7e674e2da15`
2. Market Creator deploys PredictionMarket.sol: `0x6f1c9613d7155913bfd7b9e177c6c2cb5209ce20fcf317efc6b43c9617839429`
3. Market Creator deploys ReactivePayout.sol: `xxx`
4. Participant One predicts "UP" and sends 0.001 SepETH to PredictionMarket.sol: `xxx`
5. Participant Two predicts "DOWN" and sends 0.001 SepETH to PredictionMarket.sol: `xxx`
8. Oracle backend sends transaction with price update to PriceOracle.sol: `xxx`
9. RVM sends transaction to relay (Kopli Testnet transaction): `xxx`
10. Reactive Sepolia Contract sends callback to PredictionMarket.sol: `xxx`
11. Participant XXX receives 0.002 SepETH from PredictionMarket.sol: `xxx`

## Limitations and Comments

TEXT
