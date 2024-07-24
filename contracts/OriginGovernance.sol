// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract OriginGovernance is Ownable {
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        uint256 endTime;
        bool executed;
    }

    Proposal[] public proposals;
    uint256 public proposalCount;
    uint256 public voteThreshold;

    mapping(uint256 => mapping(address => bool)) public votes;

    event ProposalCreated(uint256 id, string description, uint256 endTime);
    event Voted(uint256 proposalId, address voter);
    event ProposalExecuted(uint256 id);
    event CrossChainEvent(uint256 id, string description, uint256 voteCount);

    constructor(uint256 _voteThreshold, address initialOwner) Ownable(initialOwner) {
        voteThreshold = _voteThreshold;
        transferOwnership(initialOwner);
    }

    function createProposal(string memory _description, uint256 _duration) external onlyOwner {
        proposalCount++;
        proposals.push(Proposal({
            id: proposalCount,
            description: _description,
            voteCount: 0,
            endTime: block.timestamp + _duration,
            executed: false
        }));
        emit ProposalCreated(proposalCount, _description, block.timestamp + _duration);
    }

    function vote(uint256 _proposalId) external {
        require(_proposalId <= proposalCount, "Invalid proposal ID");
        require(!votes[_proposalId][msg.sender], "Already voted");
        require(block.timestamp < proposals[_proposalId - 1].endTime, "Voting has ended");

        votes[_proposalId][msg.sender] = true;
        proposals[_proposalId - 1].voteCount++;

        emit Voted(_proposalId, msg.sender);
    }

    function executeProposal(uint256 _proposalId) public {
        require(_proposalId <= proposalCount, "Invalid proposal ID");
        Proposal storage proposal = proposals[_proposalId - 1];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.voteCount >= voteThreshold || block.timestamp >= proposal.endTime, "Threshold not met or time not expired");

        proposal.executed = true;

        // Trigger cross-chain event
        emit CrossChainEvent(proposal.id, proposal.description, proposal.voteCount);

        // Execute proposal logic here
        emit ProposalExecuted(_proposalId);
    }
}
