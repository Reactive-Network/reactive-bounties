// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ReGovL1.sol";
import "../src/GovernanceToken.sol";
import "../src/ReGovReactive.sol";
import '../src/Reactive/IReactive.sol';



contract MockReactiveVm is Test {
    // Addresses for testing
    address private constant SERVICE_ADDRESS = address(0x1);

    address private regov;
    ReGovReactive private regovReactive;
    address private callback_sender;
    constructor(address _regov, address _callback_sender) {
        regov = _regov;
        callback_sender = callback_sender;
        regovReactive = new ReGovReactive(SERVICE_ADDRESS, regov);
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

    uint256 public constant REQUEST_PROPOSAL_CREATE_TOPIC_0 = 0x3199a34f29254e2f3052f39a547b89816d2e8c9f8b08c5c8ce5c60b5b6c43ca6;
    uint256 public constant REQUEST_PROPOSAL_EXECUTE_TOPIC_0 = 0x9650e8f3bcebc1b27a4b3010f07e121f3e3e3e05ea1c000e5c31d0325cc7e01e;
    uint256 public constant REQUEST_VOTE_TOPIC_0 = 0x34fb1cc9ebd331c305f8b04f4d8d05ab58f15346234d3c8e6c678d125b292cd3;
    uint256 public constant REQUEST_FUND_CONTRACT_TOPIC_0 = 0x5ba8e4f49ceeeda68c20e69e05da60c77e21f0b04b98be9422b47aa5481b8e02;

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
            uint256(uint160(voter1)), // topic_1
            50 ether, // topic_2 grantAmount
            0,
            "Proposal 1", // data
            0, // block_number
            0 // op_code
        );

        bytes memory payloadExpected = abi.encodeWithSignature(
            "createProposal(address,address,uint256,string)",
            address(0),
            address(uint160(voter1)),
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
            uint256(uint160(voter1)), // topic_1
            1, // topic_2 
            1, // topic_3 (support)
            "", // data
            0, // block_number
            0 // op_code
        );
        bytes memory payloadExpected = abi.encodeWithSignature(
            "vote(address,address,uint256,bool)",
            address(0),
            address(uint160(voter1)),
            1,
            1
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
            1, // topic_1
            0, // topic_2
            0, // topic_3
            "", // data
            0, // block_number
            0 // op_code
        );
        bytes memory payloadExpected = abi.encodeWithSignature(
            "executeProposal(address,uint256)",
            address(0),
            1
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
            uint256(uint160(funder)), // topic_1
            100, // topic_2 (amount)
            0, // topic_3
            "", // data
            0, // block_number
            0 // op_code
        );

        bytes memory payloadExpected = abi.encodeWithSignature(
            "fundContract(address,address,uint256)",
            address(0),
            address(uint160(funder)),
            100
        );
        
        assertEq(payloadExpected, payload);
        vm.stopPrank();
    }
}
