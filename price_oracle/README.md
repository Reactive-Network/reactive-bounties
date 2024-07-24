# Price Oracle

The PriceOracle contract provided here is a demo version designed to showcase the flexibility and adaptability of Chainlink oracles. 
It demonstrates how different logic can be implemented and various types of data can be utilized. 
For further steps, any needed logic could be implemented to serve any oracle purposes.

## Token Implementation Details

For simplicity and demonstration purposes, this project utilizes a Chainlink token on the Sepolia network. However, it can also be implemented with the project's custom token.

### Custom Token Requirements

The custom token must implement the following function:

```solidity
transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);
```

This function plays a crucial role in sending requests. It is part of the **ERC677** token standard, which inherits functionality from the **ERC20** token standard and allows token transfers to contain a data payload.

### Additional Resources

For more information about Chainlink tokens, please refer to the official documentation: [Chainlink Token Contracts](https://docs.chain.link/resources/link-token-contracts).


# Overview

This is a basic implementation of a Price Oracle built on top of the Chainlink oracles system. The choice of Chainlink was made because it implements best practices, is widely adopted, and can be adapted to any oracle logic.

## Key Features

- **Open Source**: Built on the open-source Chainlink system.
- **Best Practices**: Utilizes Chainlink's best practices for oracle implementation.
- **Flexible and Adaptable**: Can be customized for different types of data and logic.

# Setup Guide

This guide shows you how to deploy your own operator contract and add jobs to your Chainlink node so that it can provide data to smart contracts. To be able to run it from scratch, please follow the steps outlined below to ensure you have all the necessary tools.

## Notice
It is recommended to copy the `price_oracle` directory into your Hardhat project and run it using Hardhat.


## Prerequisites

- MetaMask
- Testnet LINK
- Chainlink Node
- Sepolia ETH

## Steps

1. **Set up MetaMask and Obtain Testnet LINK**

   - Install the MetaMask browser extension.
   - Switch to a test network (e.g., Sepolia).
   - Obtain testnet LINK tokens from a faucet or a friend.

2. **Run a Chainlink Node**

   - Follow the [Chainlink documentation](https://docs.chain.link/docs/running-a-chainlink-node/) to set up and run your own Chainlink node.
   - Ensure your node is connected to the appropriate test network.

3. **Fund the Ethereum Address of Your Chainlink Node**

   - In the Chainlink node GUI, navigate to the Key Management section under the configuration.
   - Identify the Regular type address used by your node.
   - Obtain Sepolia ETH from a faucet.
   - Send Sepolia ETH to the Ethereum address of your node.

4. **Add a Job to the Node**

   - In the Chainlink node GUI, find and copy the address of your Chainlink node.
   - Navigate to the "Jobs" section in the GUI.
   - Click on "New Job" and select the "TOML" option.
   - You can find ready-to-use job definitions in the `./job_definition` directory along with the setup steps.
   - Copy the contents of the desired job definition file and paste it into the job creation form.
   - Click "Create Job" to save the new job on your Chainlink node.

## Requirements

- **Sepolia ETH**: Fund your node's Ethereum address with Sepolia ETH to enable it to fulfill requests. Ensure you have enough ETH to cover gas fees for transactions.
- **Chainlink Node Address**: In the Chainlink node GUI, find and copy the address of your Chainlink node to use in your smart contracts.

By following these steps, you can deploy your own operator contract, run a Chainlink node, and add jobs to your node to provide data to smart contracts.

## Additional Resources

- [Chainlink Documentation](https://docs.chain.link/docs)

For further details on job definitions and settings, refer to the `./job_definition` directory in this repository.

# PriceOracle Contract Usage

### Description

The `PriceOracle` contract interacts with Chainlink oracles to fetch cryptocurrency prices. It supports both single-chain and cross-chain price requests.

### Deployment and Usage

1. **Deploy the PriceOracle Contract**
   - Once your node is up and the Operator contract is deployed, you can deploy the PriceOracle contract and experiment with it.
   - Use the files located in the `scripts` directory to deploy the contract.

2. **Specify the Job ID**
   - After deploying the Oracle, the Job ID should be specified for it.
   - Use the jobs created in the previous steps:
     - For `requestType = 1`, use the `cryptocompare_coin_price_job.toml`.
     - For `requestType = 2`, use the `cross_chain_coin_price_job.toml`.

3. **Set Jobs in Settings**
   - For this repository, you can specify these jobs in the settings.
   - The jobs will be set while running the contract deployment scripts.


### Making Requests

Once the steps from above are done, you can start making requests and use the PriceOracle. 

1. **requestCryptocompareETHPrice**
   - This function does not require any parameters. 
   - Simply call this function and check the contract's events to see the price of ETH.

2. **requestCryptocompareCoinPrice**
   - This function allows you to request the price of any coin.
   - Pass the coin name as a simple string parameter, such as `"ETH"` or `"BNB"`.

3. **requestCrossChainCoinPrice**
   - This function takes an array of length 3, consisting of tuples.
   - You can specify data for all 3 objects, or fewer if needed.
   - If you do not want to fill all of them, specify an empty string for those you are not interested in. Empty fields will be returned as zero values.

Example parameters:

```javascript
   const crossChainPriceRequest = [
      { 
         rpcUrl: "https://bsc-dataseed.binance.org/", 
         priceFeedContract:"0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE" 
      },
      { 
         rpcUrl: `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`, 
         priceFeedContract: "0x14e613AC84a31f709eadbdF89C6CC390fDc9540A" 
      },
      { 
         rpcUrl: "", 
         priceFeedContract: "" 
      }
   ];
```

- **rpcUrl**: This is the regular RPC URL of the blockchain.
- **priceFeedContract**: This is a BNB/USD price feed oracle address, one for the ETH chain and another one for the BNB chain.

### You can find and run the request examples in the deploymentTest directory.

## Additional Resources
- [Chainlink Fulfilling Requests Tutorial ](https://docs.chain.link/docs)

## Deployment Addresses

### Sepolia Network
- **Current Operator Address**: `0x0E9F7697bdd7D16268De7a882A377A0aFEC50Cff`
- **Current PriceOracle Address**: `0x1cC0B5AD859842d9a715207358Cd763F598B9E49`









