// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/OriginGovernance.sol";
import "../contracts/DestinationGovernance.sol";
import "../contracts/OriginOracle.sol";
import "../contracts/DestinationOracle.sol";

contract DeployContracts is Script {
    function run() external {
        address deployer = vm.envAddress("DEPLOYER_ADDRESS");
        vm.startBroadcast();

        OriginGovernance originGovernance = new OriginGovernance(3, deployer);
        DestinationGovernance destinationGovernance = new DestinationGovernance();
        OriginOracle originOracle = new OriginOracle(address(destinationGovernance));
        DestinationOracle destinationOracle = new DestinationOracle();

        vm.stopBroadcast();
    }
}
