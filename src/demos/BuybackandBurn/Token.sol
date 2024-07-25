// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ProtocolToken is ERC20, ERC20Burnable, Ownable {
    constructor(address initialOwner)
        ERC20("REACTIVE", "RV")
        Ownable(initialOwner)
    {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address from ,uint256 amount ) public onlyOwner{
        _burn(from,amount);
    }
}