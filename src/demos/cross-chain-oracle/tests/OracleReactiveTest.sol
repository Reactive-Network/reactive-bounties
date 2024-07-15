// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../DestOracle.sol";
import "../OracleReactive.sol";
import '../../../IReactive.sol';



contract MockReactiveVm is Test {
    // Addresses for testing
    address private constant SERVICE_ADDRESS = address(0x1);

    address private destOracle;
    OracleReactive private oracleReactive;
    address private callback_sender;
    constructor(address _destOracle, address _callback_sender) {
        destOracle = _destOracle;
        callback_sender = callback_sender;
        oracleReactive = new OracleReactive(SERVICE_ADDRESS, destOracle);
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
        oracleReactive.react(
            1, // chain_id
            address(destOracle), // _contract
            topic_0, // topic_0
            topic_1, // topic_1
            topic_2, // topic_2
            topic_3, // topic_3
            data, // data
            0, // block_number
            0 // op_code
        );
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes memory payload = abi.decode(entries[0].data, (bytes));

        return payload;
    }
}

contract DestOracleTest is Test {

    uint256 private constant DATA_UPDATED_TOPIC_0 = 0x7f7c53560eed5d6aab9db16abd65f6a8b3ed69d910c5e8e8842215596ffc6d78;

    DestOracle destOracle;
    MockReactiveVm mockReactiveVm;
    address owner = address(0x1);
    address callback_sender = address(0x0);

    function setUp() public {
        vm.startPrank(owner);
        destOracle = new DestOracle(callback_sender);
        mockReactiveVm = new MockReactiveVm(address(destOracle), callback_sender);
        vm.stopPrank();
    }

    function testReactiveUpdateData() public {
        vm.startPrank(callback_sender);
        // Simulate react call
        bytes memory payload = mockReactiveVm.ensureReactEmission(
            1, // chain_id
            address(destOracle), // _contract
            DATA_UPDATED_TOPIC_0, // topic_0
            50 ether, // topic_1
            0,
            0,
            "", // data
            0, // block_number
            0 // op_code
        );

        bytes memory payloadExpected = abi.encodeWithSignature(
            "updateData(uint256)",
            50 ether
        );

        assertEq(payloadExpected, payload);
        vm.stopPrank();


    }

}
