// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/MultiPartyWallet.sol";

contract DeployMultiPartyWallet is Script {
    function run() external {
        address initialOwner = msg.sender; 
        vm.startBroadcast();
        MultiPartyWallet wallet = new MultiPartyWallet(initialOwner);
        vm.stopBroadcast();
    }
}
