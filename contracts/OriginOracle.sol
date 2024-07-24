// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract OriginOracle is Ownable {
    address public destinationOracle;

    event DataSent(uint256 proposalId, string description, uint256 voteCount);

    constructor(address _destinationOracle) Ownable(msg.sender) {
        destinationOracle = _destinationOracle;
    }

    function setDestinationOracle(address _destinationOracle) external onlyOwner {
        destinationOracle = _destinationOracle;
    }

    function sendData(uint256 _proposalId, string memory _description, uint256 _voteCount) external onlyOwner {
        // Send data to Destination Oracle 
        emit DataSent(_proposalId, _description, _voteCount);
    }
}
