// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ReactiveMultiPartyWallet.sol";

contract DeployReactiveMultiPartyWallet is Script {
    function run() external {
        address[] memory shareholders = new address[](2);
        uint256[] memory shares = new uint256[](2);

        shareholders[0] = 0xAbc...; // Replace with actual address
        shareholders[1] = 0xDef...; // Replace with actual address
        shares[0] = 50;
        shares[1] = 50;

        address tokenAddress = 0x123...; // Replace with actual token address

        vm.startBroadcast();
        new ReactiveMultiPartyWallet(shareholders, shares, tokenAddress);
        vm.stopBroadcast();
    }
}
