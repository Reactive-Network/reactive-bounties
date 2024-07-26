This is application for Automated Prediction Market bounty.

My contact e-mail: ncg8j6dz@proton.me

## Problem Statement and Proposed Solution

This proposed solution for Automated Prediction Market with Reactive Network uses EVM event as mean for Market Closure. Traditional Prediction Market usually involves direct transaction from oracle to smart contract which can be rather expensive, especially if demanded frequency of updates is high. This problem can be addressed with Reactive Network, which allows to switch from costly L1 callbacks to relatively cheap L1 events.

Another advantage of Reactive Smart Contracts lies within their versatility for both already and to-be deployed oracles. If existing oracle emits valuable data as an event, than there is no need to redeploy it for casting callback in one particular smart contract. In he same way to-be deployed oracles can be developed with tailoring to Reactive Network and be much more reusable in various cases. That allows oracle developers to offer more competitive prices to consumer and simultaneously significantly increase their user base, which would be difficult or even impossible without use of RSC.

## Use case

Contract `PredictionMarket.sol` was developed by Market Creator to log predictions of unlimited number of Participants, take their deposits and make payouts to winners. Participants are expected to answer if price of some currency pair will go UP or DOWN until the end of round. Although this contract template supports any crypto and fiat currency tracked by CoinGecko, in this use case Market Creator decided to go with classic choice and implement BTC/USD pair. Round duration was set to 5 minutes to give Participants reasonable time to place prediction and to comply with limitations of CoinGecko API.

This contract implements payable *depositEther()* function that collects constant deposit 0.001 SepETH and Participant's prediction 'UP' or 'DOWN' as part of calldata. All predictions stored in *upDeposits*, *downDeposits* structs respectively and *allDeposits* in case of price did not change. When authorized entity sends round's correct answer to *payoutPrediction()* this function calculates payout by dividing contract balance by length of corresponding struct. Finally it checks if winning struct's length is positive number. If yes, it sends each winner Participant equal payout, else each Participant gets their deposit back.

To to figure out which way price dynamics went each round, Market Creator deployed `oracle.py` to fetch off-chain latest price from CoinGecko and `PriceOracle.sol` to emit event with price and timestamp of moment when backend received price from CoinGecko. For automatic execution of payouts he also deployed `ReactivePayout.sol` on Reactive Network. This contract catches events emitted by PriceOracle and checks if new timestamp is bigger than previous. If current event does indeed contains updated price, then it compares previous price with received one and decides which is correct – 'UP', 'DOWN' or 'DRAW'. Finally, it sends callback to PredictionMarket and triggers aforementioned *payoutPrediction()* function.

In context of Prediction Market Model:
* PredictionMarket.sol – Deposit Vault and Payout Agent
* PriceOracle.sol – Data Supplier
* ReactivePayout.sol – Decision Maker 

In context of Reactive Network:
* PredictionMarket.sol – L1 Callback Contract
* PriceOracle.sol – L1 Source Contract
* ReactivePayout.sol – Reactive Contract

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
PRICE_ORACLE_TOPIC_0=0x92664190cca12aca9cd5309d87194bdda75bb51362d71c06e1a6f75c7c765711

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

5. (Optional) You can change `API_DATA_CRYPTOCURRENCY` to any cryptocurrency id from [here](https://api.coingecko.com/api/v3/coins/list) and `API_DATA_VS_CURRENCY` ticker from [here](https://api.coingecko.com/api/v3/simple/supported_vs_currencies).

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
cast send $PREDICTION_MARKET_ADDR "depositEther(string)" "UP" --private-key $PARTICIPANT_ONE_PRIVATE_KEY --rpc-url $SEPOLIA_RPC --value 0.001ether
```

3. Trigger *depositEther()* function of PredictionMarket.sol under Participant Two by predicting "DOWN" and sending 0.001 SepETH to `PREDICTION_MARKET_ADDR`:
```sh
cast send $PREDICTION_MARKET_ADDR "depositEther(string)" "DOWN" --private-key $PARTICIPANT_TWO_PRIVATE_KEY --rpc-url $SEPOLIA_RPC --value 0.001ether
```

4. Chill until countdown in oracle backend terminal window reaches zero and updated price would be emitted by `PRICE_ORACLE_ADDR`.

This should result in a callback transaction signaling about prediction winner to `PREDICTION_MARKET_ADDR` being initiated by the Reactive Network and automated prediction market payout in form of 200% of SepETH sent to one of the Participants from second or third step (in rare case if price have not changed in 5 minutes both Participants will get 100% of their deposits back).

## Example Hashes

### EOAs
* Address Market Creator: `0x1D43182a0439723ad745A8557D2570E3F592f911`
* Address Participant One: `0x3282b8489F16bf4556090b0778cC5785Cd7E7d0E`
* Address Participant Two: `0x6358491dff91f92561326e3aDf9A6e86B9B00190`

### Contracts
* Address PriceOracle.sol: `0xD09ceCB0918B76e4e8676cF77e6e8D5330F0AaC4`
* Address PredictionMarket.sol: `0xEE25e5a73787c4926D06E10025fE814e91584875`
* Address ReactivePayout.sol: `0xe739ebA621EBD990C3ebf7E3D03074919c081538`

### Transactions
1. Market Creator deploys PriceOracle.sol: `0xbeef044f4dbe6f0741524e6ea18800e2c5c706c9e2fa0c33d4f728c5df99595e`
2. Market Creator deploys PredictionMarket.sol: `0xe2ba46b0e00ff5490fe1448843fcdb32bc01e38ae675df7c3b6bfa84b17ec9d3`
3. Market Creator deploys ReactivePayout.sol: `0x969ea3c5a709c74e110c7ac55a0cae41938983be6a20d22b18aaa916f1ed5c92`
4. Oracle backend sends initial transaction with price to PriceOracle.sol: `0x45f5f86a557242b99071da87ddce49be799bd67164fdeeb30594fd73f76557da`
5. RVM sends transaction to relay (Kopli Testnet transaction): `0x7b402d9723b7fb8627f2587b37a17c5b00949531a1a4ba0fd40729a9900abbac`

### Round 1 – winner UP:
6. Participant One predicts "UP" and sends 0.001 SepETH to PredictionMarket.sol: `0xc4ce2e2e970707045f9ffb67bb067b3b740a7bde4b0f67c65f0f34801729a800`
7. Participant Two predicts "DOWN" and sends 0.001 SepETH to PredictionMarket.sol: `0xa36aa23e0571c74f814f299f7f684e2eea9c1f93419ce3d55cfbbdf507fa701e`
8. Oracle backend sends transaction with price update to PriceOracle.sol: `0x08c35076feadfd47dfde9040345bbb7d5eb0edcdbf129504239286b09aad34f1`
9. RVM sends transaction to relay (Kopli Testnet transaction): `0xb4f6f983490c4bfaac75a0b972c7e7a54ff0b2ec80cd618f6d762e3c0db43b8f`
10. Reactive Sepolia Contract sends callback to PredictionMarket.sol: `0x91a3b52e12df01b21e86893cf78c92bb081ef4051815dcd023a9146f39023238`
11. Participant One receives 0.002 SepETH from PredictionMarket.sol: `0x91a3b52e12df01b21e86893cf78c92bb081ef4051815dcd023a9146f39023238`

### Round 2 – winner DOWN:
12. Participant One predicts "UP" and sends 0.001 SepETH to PredictionMarket.sol: `0x9ca668b7c32ee608c39b69f8de60133f379e57a5f45ab92cb23881ccbe726236`
13. Participant Two predicts "DOWN" and sends 0.001 SepETH to PredictionMarket.sol: `0x08de58692880941c6c41ffef7982faf8bf868c93ab2124818af417930686453e`
14. Oracle backend sends transaction with price update to PriceOracle.sol: `0x3efa493ebc9ade688d94661282a0bdc7e30b3a72e03b09a2d0cfe28c851a909b`
15. RVM sends transaction to relay (Kopli Testnet transaction): `0x6e43dc93a1f893a1e0ec2bd03af193c30b470d3c3f7fb7d15882d80f59ae460f`
16. Reactive Sepolia Contract sends callback to PredictionMarket.sol: `0x887d2742e3cdc7e900996825acf09f68b3fe8126829f728e9ea3bdf42df36271`
17. Participant Two receives 0.002 SepETH from PredictionMarket.sol: `0x887d2742e3cdc7e900996825acf09f68b3fe8126829f728e9ea3bdf42df36271`

## Limitations and Comments

* CoinGecko API documentation declares that price update supposed to happen every 2-3 minutes. In my experience occasionally it may take slightly longer for BTC and ETH, I suspect that for some less popular coins it can be much longer. To avoid situation with multiple 'DRAW' outcomes I recommend set `ROUND_DURATION` to at least 300 (5 minutes).
* This solution on purpose implements basic minimalist variant of L1 contracts for the reason of simplification of example.
* This solution on purpose overlooks many real-life prediction market practices (like custom bet amounts, bet resale, etc) for the reason of simplification of example.
