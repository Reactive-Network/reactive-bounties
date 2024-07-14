// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../ReGovL1.sol";
import "../GovernanceToken.sol";
import "../ReGovReactive.sol";
import '../../../IReactive.sol';



contract MockReactiveVm is Test {
    // Addresses for testing
    address private constant SERVICE_ADDRESS = address(0x1);

    address private regov;
    ReGovReactive private regovReactive;
    address private callback_sender;
    constructor(address _regov, address _callback_sender) {
        regov = _regov;
        callback_sender = callback_sender;
        regovReactive = new ReGovReactive(SERVICE_ADDRESS, regov, address(0x0));
    }

    function ensureReactEmission(uint256 chain_id,
                            address _contract,
                            uint256 topic_0,
                            uint256 topic_1,
                            uint256 topic_2,
                            uint256 topic_3,
                            bytes calldata data,
                            uint256 block_number,
                            uint256 /* op_code */) external returns (bytes memory) {
        // Start the recorder
        vm.recordLogs();
        // vm.expectEmit(true, true, false, true);
        // Simulate react call
        regovReactive.react(
            1, // chain_id
            address(regov), // _contract
            topic_0, // topic_0
            topic_1, // topic_1
            topic_2, // topic_2
            topic_3, // topic_3 (description)
            data, // data
            0, // block_number
            0 // op_code
        );
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes memory payload = abi.decode(entries[0].data, (bytes));

        return payload;
    }
}

contract ReGovL1Test is Test {

    uint256 private constant REQUEST_PROPOSAL_CREATE_TOPIC_0 = 0xe647f9c40f113518b40273f67af29fe3bae0e7f7581a87b42ec9ef84989306b6;
    uint256 private constant REQUEST_PROPOSAL_EXECUTE_TOPIC_0 = 0xae64303d6f1b5137f8b05757269e5af8ff7ea2ef7c733f3e3adf553d974060e8;
    uint256 private constant REQUEST_VOTE_TOPIC_0 = 0xb703f403fb13707ed08878590d45680ceb08bba172ab33f5f46ca40f000ee1de;
    uint256 private constant REQUEST_FUND_CONTRACT_TOPIC_0 = 0xf5a4d15b2e66768f5633794bc3d0727dfe77f80a11b57947ae0f3d79a23802d1;

    ReGovL1 regov;
    MockReactiveVm mockReactiveVm;
    GovernanceToken governanceToken;
    address owner = address(0x1);
    address voter1 = address(0x2);
    address voter2 = address(0x3);
    address callback_sender = address(0x0);
    address funder = address(0x5);
    uint256 baseGrantAmount = 10 ether;
    uint256 quorumMultiplier = 2;
    uint256 votingPeriod = 1 days;

    function setUp() public {
        vm.startPrank(owner);
        governanceToken = new GovernanceToken(1000000 ether);
        regov = new ReGovL1(address(governanceToken), callback_sender, baseGrantAmount, quorumMultiplier, votingPeriod);
        mockReactiveVm = new MockReactiveVm(address(regov), callback_sender);
        governanceToken.transfer(voter1, 100 ether);
        governanceToken.transfer(voter2, 100 ether);
        governanceToken.transfer(funder, 100 ether);
        vm.stopPrank();
    }

    function testReactiveCreateProposal() public {
        vm.startPrank(callback_sender);
        // Simulate react call
        bytes memory payload = mockReactiveVm.ensureReactEmission(
            1, // chain_id
            address(regov), // _contract
            REQUEST_PROPOSAL_CREATE_TOPIC_0, // topic_0
            0,
            0,
            0,
            abi.encode(voter1, 50 ether, "Proposal 1"), // data
            0, // block_number
            0 // op_code
        );

        bytes memory payloadExpected = abi.encodeWithSignature(
            "createProposal(address,address,uint256,string)",
            address(0),
            address(voter1),
            50 ether,
            "Proposal 1"
        );

        assertEq(payloadExpected, payload);
        vm.stopPrank();


    }

    function testReactiveVote() public {
        vm.startPrank(callback_sender);
        regov.createProposal(callback_sender, voter1, 50 ether, "Proposal 1");
        vm.stopPrank();

        vm.startPrank(callback_sender);

        // Simulate react call
        bytes memory payload = mockReactiveVm.ensureReactEmission(
            1, // chain_id
            address(regov), // _contract
            REQUEST_VOTE_TOPIC_0, // topic_0
            0,
            0,
            0,
            abi.encode(voter1, uint256(1), true), // data
            0, // block_number
            0 // op_code
        );
        bytes memory payloadExpected = abi.encodeWithSignature(
            "vote(address,address,uint256,bool)",
            address(0),
            voter1,
            uint256(1),
            true
        );

        assertEq(payloadExpected, payload);
        vm.stopPrank();
    }

    function testReactiveExecuteProposal() public {
        vm.startPrank(callback_sender);
        // Simulate react call
        bytes memory payload = mockReactiveVm.ensureReactEmission(
            1, // chain_id
            address(regov), // _contract
            REQUEST_PROPOSAL_EXECUTE_TOPIC_0, // topic_0
            0,
            0,
            0,
            abi.encode(uint256(1)), // data
            0, // block_number
            0 // op_code
        );
        bytes memory payloadExpected = abi.encodeWithSignature(
            "executeProposal(address,uint256)",
            address(0),
            uint256(1)
        );

        assertEq(payloadExpected, payload);
        vm.stopPrank();
    }

    function testReactiveFundContract() public {
        vm.startPrank(funder);
        governanceToken.approve(address(regov), 100 ether);
        vm.stopPrank();

        vm.startPrank(callback_sender);

        // Simulate react call
        bytes memory payload = mockReactiveVm.ensureReactEmission(
            1, // chain_id
            address(regov), // _contract
            REQUEST_FUND_CONTRACT_TOPIC_0, // topic_0
            0,
            0,
            0,
            abi.encode(funder, 100), // data
            0, // block_number
            0 // op_code
        );

        bytes memory payloadExpected = abi.encodeWithSignature(
            "fundContract(address,address,uint256)",
            address(0),
            address(funder),
            100
        );

        assertEq(payloadExpected, payload);
        vm.stopPrank();
    }
}
