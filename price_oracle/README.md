
# Overview

In this topic, I will describe a use case of an oracle deployed on the Sepolia network. This oracle will act as a destination smart contract (SC) and will be fed by several Reactive Smart Contracts (RSCs) that are subscribed to different origins on various chains. The RSCs will collect price data from these origins and transmit it to the Sepolia-based oracle, ensuring a consolidated and up-to-date price feed within the network.


# Contracts Overview

## PriceOracle Contract
The price oracle described here functions as a Origin and destination contract managing chain price feeds. It includes the following function:

```solidity
function feedPriceRSC(uint _chainId, address _pair, uint _price) external onlyReactive() {
    
    // Update the latest price for the given chain ID and token pair
    latestRSCPrice[_chainId][_pair] = _price;

    // Emit an event to signal that the price has been updated
    emit PriceUpdated(
        _chainId,
        _pair,
        _price
    );
}
```

This function allows different contracts deployed on various chains to send pricing data to it via the Reactive Smart Contract. The `feedPriceRSC` function updates the latest price for a given chain ID and token pair, ensuring that the price feeds are synchronized across different blockchain environments. The `onlyReactive` modifier restricts access to ensure that only authorized contracts can call this function, maintaining the integrity and reliability of the price updates.



## L1ChainlinkOraclePriceFetcher 

The contract is designed to act as an origin for different chains. It provides the following function:

```solidity
function getPrice(address _pairOracle) public {
    IPriceFeed priceFeed = IPriceFeed(_pairOracle);
    
    // Call the latestAnswer function
    int256 latestPrice = priceFeed.latestAnswer();
    
    // Convert int256 to uint256 (assuming latestAnswer is always non-negative)
    require(latestPrice >= 0, "Negative price not supported");
    uint price = uint256(latestPrice);
    
    emit PriceFetched(_pairOracle, price);
}
```

The constructor for this contract takes the following parameters:

```solidity
constructor(address service_address, uint256 chain_id, address _contract, address callback)
```

- `service_address`: `0x0000000000000000000000000000000000FFFFFF`, a placeholder service address.
- `chain_id`: The number of the chain where the desired `L1ChainlinkOraclePriceFetcher` is deployed.
- `_contract`: The address of the deployed `L1ChainlinkOraclePriceFetcher`.
- `callback`: The address of the deployed `PriceOracle`.

This function can be called by bots or humans to retrieve the latest price of the specified token pair from the Chainlink oracle on that chain. Upon fetching the latest price, it emits an event containing the oracle address and the fetched price. This allows for real-time price retrieval and event-driven processing within the blockchain ecosystem.

## ReactivePriceFeeder 

This contract is designed to listen to Origin events, such as those from the `L1ChainlinkOraclePriceFetcher`, process them in the ReactiveEVM, and feed the `PriceOracle` with the requested price. 

This architecture ensures that price updates from various origins are efficiently processed and propagated to the destination `PriceOracle` contract, maintaining accurate and up-to-date price feeds across different chains.

## ReactiveOffChainPriceHandler
Is designed to listen to the `PriceOracle` as an origin. It processes the logic based on the off-chain prices emitted by the `PriceOracle` since it can function as both an Origin and a destination smart contract.

This setup allows the `ReactiveOffChainPriceHandler` to respond to price updates from the `PriceOracle`, enabling it to execute specific logic or actions based on the received price data.


## Steps to Launch and Use the Oracle

1. **Deploy the `L1ChainlinkOraclePriceFetcher` on the Desired Chain:**
   - Deploy the `L1ChainlinkOraclePriceFetcher` contract on your chosen chain (e.g., Ethereum or Binance Smart Chain).

2. **Deploy the `PriceOracle` on the Sepolia Chain:**
   - Deploy the `PriceOracle` contract on the Sepolia network.

3. **Deploy Reactive Contracts on the Reactive Network:**
   - Deploy the `ReactivePriceFeeder` contract on the Reactive Network.
   - Deploy the `ReactiveOffChainPriceHandler` contract on the Reactive Network.

4. **Fetch and Update Prices:**
   - Call the `getPrice()` function of your `L1ChainlinkOraclePriceFetcher`.
   - Once the transaction is finished, check the `latestRSCPrice` mapping in the `PriceOracle` to get the latest price of the desired token pair.

This sequence ensures that price data is accurately fetched from the Chainlink oracle, processed through the Reactive Network, and updated in the `PriceOracle` on the Sepolia chain.


## Important Notice
The price oracle also includes a component related to Chainlink, allowing price data to be fetched from various on-chain and off-chain sources. This component operates independently of the Reactive Network. For those interested in configuring this Chainlink-related part, all the setup steps can be found in the `./node-config` directory.
