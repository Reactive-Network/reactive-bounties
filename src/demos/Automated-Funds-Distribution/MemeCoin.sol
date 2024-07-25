// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MEME is ERC20 {
    constructor()
        ERC20("PEPE", "PP")
    {}

    function mint(address to, uint256 amount) public  {
        _mint(to, amount);
    }
}