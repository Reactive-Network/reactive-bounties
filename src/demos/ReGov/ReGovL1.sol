// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract ReGovL1 is Ownable {
    using Strings for bytes;
    IERC20 public governanceToken;
    uint256 public proposalCount;
    address private callback_sender;
    uint256 public baseGrantAmount;
    uint256 public quorumMultiplier;
    uint256 public votingPeriod;

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 grantAmount;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        uint256 deadline;
        uint256 requiredQuorum;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public votes;

    event ProposalCreated(uint256 id, address proposer, string description, uint256 grantAmount, uint256 requiredQuorum);
    event Voted(uint256 proposalId, address voter, bool support);
    event ProposalExecuted(uint256 id, uint256 grantAmount);
    event ProposalRejected(uint256 id);

    constructor(address _governanceToken, address _callback_sender, uint256 _baseGrantAmount, uint256 _quorumMultiplier, uint256 _votingPeriod) Ownable(msg.sender) {
        governanceToken = IERC20(_governanceToken);
        callback_sender = _callback_sender;
        baseGrantAmount = _baseGrantAmount;
        quorumMultiplier = _quorumMultiplier;
        votingPeriod = _votingPeriod;
    }

    modifier onlyReactive() {
        if (callback_sender != address(0)) {
            require(msg.sender == callback_sender, 'Unauthorized');
        }
        _;
    }

    function createProposal(address /* sender */, address voter, uint256 grantAmount, string memory description) external onlyReactive {
        proposalCount++;
        uint256 requiredQuorum = calculateQuorum(grantAmount);
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            proposer: voter,
            description: description,
            grantAmount: grantAmount,
            votesFor: 0,
            votesAgainst: 0,
            executed: false,
            deadline: block.timestamp + votingPeriod,
            requiredQuorum: requiredQuorum
        });

        emit ProposalCreated(proposalCount, voter, description, grantAmount, requiredQuorum);
    }

    function vote(address /* sender */, address voter, uint256 proposalId, bool support) external onlyReactive {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.deadline, "Voting period has ended");
        require(!votes[proposalId][voter], "Already voted");

        uint256 balance = governanceToken.balanceOf(voter);
        require(balance > 0, "No governance tokens");

        if (support) {
            proposal.votesFor += balance;
        } else {
            proposal.votesAgainst += balance;
        }

        votes[proposalId][voter] = true;
        emit Voted(proposalId, voter, support);
    }

    function executeProposal(address /* sender */, uint256 proposalId) external onlyReactive {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.deadline, "Voting period not ended");
        require(!proposal.executed, "Already executed");

        if (proposal.votesFor + proposal.votesAgainst < proposal.requiredQuorum) {
            emit ProposalRejected(proposalId);
            return;
        }

        if (proposal.votesFor > proposal.votesAgainst) {
            proposal.executed = true;
            require(governanceToken.transfer(proposal.proposer, proposal.grantAmount), "Transfer failed");
            emit ProposalExecuted(proposalId, proposal.grantAmount);
        } else {
            emit ProposalRejected(proposalId);
        }
    }

    // Function to fund the contract with governance tokens
    function fundContract(address /* sender */, address funder, uint256 amount) external onlyReactive {
        require(governanceToken.transferFrom(funder, address(this), amount), "Funding failed");
    }

    function calculateQuorum(uint256 grantAmount) public view returns (uint256) {
        return baseGrantAmount * quorumMultiplier + grantAmount * quorumMultiplier;
    }
}
