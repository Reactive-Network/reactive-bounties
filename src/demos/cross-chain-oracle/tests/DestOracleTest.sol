// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../DestOracle.sol";

contract DestOracleTest is Test {
    DestOracle public oracle;
    address public callbackSender = address(1);

    function setUp() public {
        oracle = new DestOracle(callbackSender);
    }

    function testInitialData() public {
        uint256 initialData = oracle.getData();
        assertEq(initialData, 0);
    }

    function testUpdateData() public {
        vm.prank(callbackSender);
        uint256 newData = 42;
        oracle.updateData(newData);

        uint256 updatedData = oracle.getData();
        assertEq(updatedData, newData);
    }

    function testUnauthorizedUpdateData() public {
        vm.expectRevert("Unauthorized");
        oracle.updateData(42);
    }

    function testEventEmittedOnUpdate() public {
        vm.prank(callbackSender);
        uint256 newData = 42;

        vm.expectEmit(true, true, false, true);
        emit DataUpdated(newData);

        oracle.updateData(newData);
    }

    event DataUpdated(uint256 indexed newData);
}

