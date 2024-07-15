// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract OrgOracle is Ownable {
    uint256 public data;
    event DataUpdated(uint256 indexed newData);

    constructor() Ownable(msg.sender) {
    }

    function updateData(uint256 _data) public onlyOwner {
        data = _data;
        emit DataUpdated(_data);
    }

    function getData() public view returns (uint256) {
        return data;
    }
}
