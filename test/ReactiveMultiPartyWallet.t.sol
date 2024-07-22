// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ReactiveMultiPartyWallet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
    constructor() ERC20("TestToken", "TTK") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        bool result = super.transfer(recipient, amount);
        if (result) {
            ReactiveMultiPartyWallet wallet = ReactiveMultiPartyWallet(recipient);
            if (address(wallet) == recipient) {
                wallet.onTokenTransfer(msg.sender, amount, "");
            }
        }
        return result;
    }
}

contract ReactiveMultiPartyWalletTest is Test {
    ReactiveMultiPartyWallet wallet;
    TestERC20 token;

    address[] shareholders;
    uint256[] shares;

    function setUp() public {
        token = new TestERC20();
        shareholders = new address ;
        shares = new uint256 ;

        shareholders[0] = address(1);
        shareholders[1] = address(2);
        shares[0] = 50;
        shares[1] = 50;

        wallet = new ReactiveMultiPartyWallet(shareholders, shares, address(token));
    }

    function testDistributeFunds() public {
        // Mint tokens to this contract for testing purposes
        token.transfer(address(wallet), 100);

        assertEq(token.balanceOf(address(shareholders[0])), 50);
        assertEq(token.balanceOf(address(shareholders[1])), 50);
    }
}
