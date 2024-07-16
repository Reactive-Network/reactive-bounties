## Story

  

Genius Developer created and deployed `TopSecureContract.sol` as a sort of piggy bank - everyone can send funds there, but only he can spend them. To restrict unauthorized access to piggy funds spending Genius Developer created *onlyGeniusDeveloper* modifier, but for some reason he forgot to use it while writing *transferEth* function. As a result a bug was introduced, which allows anyone to spend his piggy funds.

  

Unaware of this critical error but horrified of thought that some Mysterious Hecker could steal his piggy funds he applied for insurance coverage to Whatever Insurance. For some reason Whatever Insurance, which controls a vault `GenerousInsurance.sol`, also missed this bug and insured the fuck outta this contract. As an insurance plan they agreed to deploy oracle to monitor spending of piggy funds, special judge to decide if transactions were unauthorized, and executioner for automatic payouts.

  

The oracle part consists of `oracle.py` to watch TopSecureContract's transactions off-chain, and `HonestOracle.sol` to emit event inside EVM with *msg.sender* and *amount* of those transactions. They decided to use new Reactive Smart Contract technology to combine roles of judge and executioner in one contract named `ReactiveJudge.sol`. If HonestOracle emits event in which *msg.sender* is not Genius Developer, then ReactiveJudge transfers from GenerousInsurance to Genius Developer 50% of event's *amount*.

  

## Hashes

  

EOA Genius Developer: `0x2b32CE6f546a8a3E852DD9356f9f556D17DBd179`

EOA Whatever Insurance: `0x3282b8489F16bf4556090b0778cC5785Cd7E7d0E`

EOA Mysterious Hecker: `0xC6B9d45be6FcBdf065f5c58DBc7faD657D9d0147`

  

Contract TopSecureContract.sol: `0x0d7ab6D3CD6b7A59141a57106a051eAd6720Ccf0`

Contract GenerousInsurance.sol: `0x73A8844C5c3A3ffC3c51f9E27245eB4fd20ab037`

Contract HonestOracle.sol: `0xaB62694966807E5c149413385C052f30fcEba408`

Contract ReactiveJudge.sol:

  

## Deployment for testing

  

You will need the following environment variables configured appropriately to follow this script:

  

*  `SEPOLIA_RPC`

*  `INFURA_PROJECT_ID`

*  `GENIUS_DEVELOPER_PRIVATE_KEY`

*  `GENIUS_DEVELOPER_ADDR`

*  `WHATEVER_INSURANCE_PRIVATE_KEY`

*  `WHATEVER_INSURANCE_ADDR`

*  `MYSTERIOUS_HECKER_PRIVATE_KEY`

*  `MYSTERIOUS_HECKER_ADDR`

*  `TOP_SECURE_CONTRACT_ADDR`

*  `GENEROUS_INSURANCE_ADDR`

*  `HONEST_ORACLE_ADDR`

*  `REACTIVE_JUDGE_ADDR`

*  `REACTIVE_RPC`

*  `REACTIVE_PRIVATE_KEY`

*  `SYSTEM_CONTRACT_ADDR`

*  `CALLBACK_SENDER_ADDR`

  

Use a tool like dotenv to load your environment variables, or manually source the .env file in your shell session:

  

```sh

export $(grep  -v  '^#'  .env  |  xargs)

```

  

Install libraries for oracle backend:

```sh

pip3  install  web3

pip3  install  python-dotenv

```