// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/OriginGovernance.sol";

contract OriginGovernanceTest is Test {
    OriginGovernance originGovernance;
    address voter1 = address(0x123);
    address voter2 = address(0x456);
    address voter3 = address(0x789);

    function setUp() public {
        originGovernance = new OriginGovernance(3, address(this)); // Set vote threshold to 3
    }

    function testCreateProposal() public {
        originGovernance.createProposal("Test Proposal", 1000);
        (uint256 id, string memory description,,,) = originGovernance.proposals(0);
        assertEq(id, 1);
        assertEq(description, "Test Proposal");
    }

    function testVote() public {
        originGovernance.createProposal("Test Proposal", 1000);
        vm.prank(voter1);
        originGovernance.vote(1);
        (, , uint256 voteCount,,) = originGovernance.proposals(0);
        assertEq(voteCount, 1);
    }

    function testExecuteProposal() public {
        originGovernance.createProposal("Test Proposal", 1000);

        vm.prank(voter1);
        originGovernance.vote(1);

        vm.prank(voter2);
        originGovernance.vote(1);

        vm.prank(voter3);
        originGovernance.vote(1);

        (, , uint256 voteCount,,) = originGovernance.proposals(0);
        assertEq(voteCount, 3);

        originGovernance.executeProposal(1);
        (, , , , bool executed) = originGovernance.proposals(0);
        assertTrue(executed);
    }
}
