// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import { IPriceFeed } from "./interfaces/IPriceFeed.sol";


contract L1ChainlinkOraclePriceFetcher {

    event PriceFetched(address pair, uint price);
    
    function getPrice(address _pairOracle ) public {
        IPriceFeed priceFeed = IPriceFeed(_pairOracle);
        
        // Call the latestAnswer function
        int256 latestPrice = priceFeed.latestAnswer();
        // Convert int256 to uint256 (assuming latestAnswer is always non-negative)
        require(latestPrice >= 0, "Negative price not supported");
        uint price = uint256(latestPrice);
        
        emit PriceFetched( _pairOracle, price);
    }
}
