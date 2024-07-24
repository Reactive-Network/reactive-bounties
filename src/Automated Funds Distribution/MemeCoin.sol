// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contract/token/ERC20/ERC20.sol";


contract MemeCoin is ERC20 {
    constructor(uint256 initialSupply) ERC20("BobBanana", "BananaCoin") {
        _mint(msg.sender, initialSupply);
    }
}