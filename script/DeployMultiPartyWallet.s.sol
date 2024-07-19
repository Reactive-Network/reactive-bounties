// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { MultiPartyWallet } from "../src/MultiPartyWallet.sol";

contract DeployMultiPartyWallet is Script {
    function run() public {
        // Define the shareholders, shares, and token address
        address[] memory shareholders = new address[](2);
        uint256[] memory shares = new uint256[](2);
        address tokenAddress = 0xYourTokenAddressHere;

        shareholders[0] = 0xShareholderAddress1;
        shareholders[1] = 0xShareholderAddress2;
        shares[0] = 50;
        shares[1] = 50;

        // Start broadcasting the transaction
        vm.startBroadcast();

        // Deploy the contract
        MultiPartyWallet wallet = new MultiPartyWallet(shareholders, shares, tokenAddress);

        // End broadcasting the transaction
        vm.stopBroadcast();

        // Print the contract address
        console.log("MultiPartyWallet deployed to:", address(wallet));
    }
}
