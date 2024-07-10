// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ReGovEvents is Ownable {
    constructor() Ownable(msg.sender) {
    }

    event RequestProposalCreate(address proposer, uint256 grantAmount,  string description);
    event RequestVote(address voter, uint256 proposalId, bool support);
    event RequestProposalExecute(uint256 id);
    event RequestFundContract(address funder, uint256 grantAmount);

    function requestVote(uint256 proposalId, bool support) external onlyOwner {
        emit RequestVote(msg.sender, proposalId, support);
    }

    function requestProposalCreate(string memory description, uint256 grantAmount) external onlyOwner {
        emit RequestProposalCreate( msg.sender, grantAmount, description);
    }

    function requestProposalExecute(uint256 proposalId) external onlyOwner {
        emit RequestProposalExecute(proposalId);
    }

    function requestFundContract(uint256 grantAmount) external onlyOwner {
        emit RequestFundContract(msg.sender, grantAmount);
    }

}
