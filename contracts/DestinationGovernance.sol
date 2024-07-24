// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DestinationGovernance {
    address private owner;

    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;

    event ProposalReceived(uint256 id, string description, uint256 voteCount);
    event ProposalExecuted(uint256 id);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function receivedProposal(uint256 _id, string memory _description, uint256 _voteCount) external onlyOwner {
        proposals[_id] = Proposal({
            id: _id,
            description: _description,
            voteCount: _voteCount,
            executed: false
        });

        emit ProposalReceived(_id, _description, _voteCount);
        executeProposal(_id);
    }

    function executeProposal(uint256 _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");

        // Execute proposal logic here

        proposal.executed = true;
        emit ProposalExecuted(_proposalId);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        owner = newOwner;
    }
}
