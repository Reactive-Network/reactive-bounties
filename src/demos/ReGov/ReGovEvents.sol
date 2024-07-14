// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ReGovEvents is Ownable {
    constructor() Ownable(msg.sender) {
    }

    event ProposalCreateRequested(address proposer, uint256 grantAmount,  string description);
    event VoteRequested(address voter, uint256 proposalId, bool support);
    event ProposalExecuteRequested(uint256 id);
    event FundContractRequested(address funder, uint256 grantAmount);

    function requestVote(uint256 proposalId, bool support) external onlyOwner {
        emit VoteRequested(msg.sender, proposalId, support);
    }

    function requestProposalCreate(string memory description, uint256 grantAmount) external onlyOwner {
        emit ProposalCreateRequested( msg.sender, grantAmount, description);
    }

    function requestProposalExecute(uint256 proposalId) external onlyOwner {
        emit ProposalExecuteRequested(proposalId);
    }

    function requestFundContract(uint256 grantAmount) external onlyOwner {
        emit FundContractRequested(msg.sender, grantAmount);
    }

}
