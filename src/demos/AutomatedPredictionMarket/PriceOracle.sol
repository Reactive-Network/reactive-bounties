// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PriceOracle {
    event PriceUpdate(uint256 indexed timestamp, uint256 indexed price);

    function emitEvent(uint256 _timestamp, uint256 _price) external {
        emit PriceUpdate(_timestamp, _price);
    }
}
