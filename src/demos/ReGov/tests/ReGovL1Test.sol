// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../ReGovL1.sol";
import "../GovernanceToken.sol";

contract ReGovL1Test is Test {
    ReGovL1 regov;
    GovernanceToken governanceToken;
    address owner = address(0x1);
    address voter1 = address(0x2);
    address voter2 = address(0x3);
    address callback_sender = address(0x4);
    address funder = address(0x5);
    uint256 baseGrantAmount = 10 ether;
    uint256 quorumMultiplier = 2;
    uint256 votingPeriod = 1 days;

    function setUp() public {
        vm.startPrank(owner);
        governanceToken = new GovernanceToken(1000000 ether);
        regov = new ReGovL1(address(governanceToken), callback_sender, baseGrantAmount, quorumMultiplier, votingPeriod);
        governanceToken.transfer(voter1, 100 ether);
        governanceToken.transfer(voter2, 100 ether);
        governanceToken.transfer(funder, 100 ether);
        vm.stopPrank();
    }

    function testCreateProposal() public {
        vm.startPrank(callback_sender);
        regov.createProposal(callback_sender, voter1, 50 ether, "Proposal 1");
        vm.stopPrank();

        (uint256 id, address proposer, string memory description, uint256 grantAmount, uint256 votesFor, uint256 votesAgainst, bool executed, uint256 deadline, uint256 requiredQuorum) = regov.proposals(1);

        assertEq(id, 1);
        assertEq(proposer, voter1);
        assertEq(description, "Proposal 1");
        assertEq(grantAmount, 50 ether);
        assertEq(votesFor, 0);
        assertEq(votesAgainst, 0);
        assertFalse(executed);
        assertTrue(deadline > block.timestamp);
        assertEq(requiredQuorum, baseGrantAmount * quorumMultiplier + grantAmount * quorumMultiplier);
    }

    function testVote() public {
        vm.startPrank(callback_sender);
        regov.createProposal(callback_sender, voter1, 50 ether, "Proposal 1");
        vm.stopPrank();

        vm.startPrank(callback_sender);
        regov.vote(callback_sender, voter1, 1, true);
        vm.stopPrank();

        (, , , , uint256 votesFor, uint256 votesAgainst, , , ) = regov.proposals(1);
        assertEq(votesFor, 100 ether);
        assertEq(votesAgainst, 0);

        vm.startPrank(callback_sender);
        regov.vote(callback_sender, voter2, 1, false);
        vm.stopPrank();

        (, , , , votesFor, votesAgainst, , , ) = regov.proposals(1);
        assertEq(votesFor, 100 ether);
        assertEq(votesAgainst, 100 ether);
    }

    function testExecuteProposal() public {
        vm.startPrank(callback_sender);
        regov.createProposal(callback_sender, voter1, 50 ether, "Proposal 1");
        vm.stopPrank();

        vm.startPrank(callback_sender);
        regov.vote(callback_sender, voter1, 1, true);
        vm.stopPrank();

        vm.startPrank(callback_sender);
        regov.vote(callback_sender, voter2, 1, true);
        vm.stopPrank();

        vm.warp(block.timestamp + votingPeriod + 1);

        vm.startPrank(owner);
        governanceToken.transfer(address(regov), 50 ether);
        vm.stopPrank();

        vm.startPrank(callback_sender);
        regov.executeProposal(callback_sender, 1);
        vm.stopPrank();

        (, , , , , , bool executed, , ) = regov.proposals(1);
        assertTrue(executed);
        assertEq(governanceToken.balanceOf(voter1), 150 ether);
    }

    function testExecuteProposalFailsWithoutQuorum() public {
        vm.startPrank(callback_sender);
        regov.createProposal(callback_sender, voter1, 100 ether, "Proposal 1");
        vm.stopPrank();

        vm.startPrank(callback_sender);
        regov.vote(callback_sender, voter1, 1, true);
        vm.stopPrank();

        vm.warp(block.timestamp + votingPeriod + 1);

        vm.startPrank(owner);
        governanceToken.transfer(address(regov), 100 ether);
        vm.stopPrank();

        vm.startPrank(callback_sender);
        regov.executeProposal(callback_sender, 1);
        vm.stopPrank();

        (, , , , , , bool executed, , ) = regov.proposals(1);
        assertFalse(executed);
        assertEq(governanceToken.balanceOf(voter1), 100 ether);
    }

    function testFundContract() public {
        vm.startPrank(funder);
        governanceToken.approve(address(regov), 100 ether);
        vm.stopPrank();

        vm.startPrank(callback_sender);
        regov.fundContract(callback_sender, funder, 100 ether);
        assertEq(governanceToken.balanceOf(address(regov)), 100 ether);
        vm.stopPrank();
    }
}
