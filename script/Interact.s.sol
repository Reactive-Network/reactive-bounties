// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/MultiPartyWallet.sol";

contract Interact is Script {
    MultiPartyWallet wallet;

    function setUp() public {
        wallet = MultiPartyWallet(payable(0xEa7a667800Ac855D739E2396eC12f67DbB144Cc8));
    }

    function addShareholder(address shareholder, uint256 shares) public {
        vm.startBroadcast();
        wallet.addShareholder(shareholder, shares);
        vm.stopBroadcast();
    }

    function distributeFunds() public {
        vm.startBroadcast();
        wallet.distributeFunds();
        vm.stopBroadcast();
    }
}
