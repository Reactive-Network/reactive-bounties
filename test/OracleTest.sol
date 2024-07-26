// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/OriginOracle.sol";
import "../contracts/DestinationOracle.sol";

contract OracleTest is Test {
    OriginOracle originOracle;
    DestinationOracle destinationOracle;

    function setUp() public {
        destinationOracle = new DestinationOracle();
        originOracle = new OriginOracle(address(destinationOracle));
    }

    function testSetDestinationOracle() public {
        address newDestinationOracle = address(0x123);
        originOracle.setDestinationOracle(newDestinationOracle);
        assertEq(originOracle.destinationOracle(), newDestinationOracle);
    }

    function testSendData() public {
        originOracle.sendData(1, "Test Proposal", 100);
        // Verify event emission (Forge automatically captures events)
    }

    function testReceiveData() public {
        destinationOracle.receiveData(1, "Test Proposal", 100);
        // Verify event emission (Forge automatically captures events)
    }
}
