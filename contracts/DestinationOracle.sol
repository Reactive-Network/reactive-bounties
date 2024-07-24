// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DestinationOracle is Ownable {
    event DataReceived(uint256 proposalId, string description, uint256 voteCount);

    constructor() Ownable(msg.sender) {}

    function receiveData(uint256 _proposalId, string memory _description, uint256 _voteCount) external onlyOwner {
        emit DataReceived(_proposalId, _description, _voteCount);
    }
}
