/**
 *Submitted for verification at Etherscan.io on 2024-07-24
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

contract PaymentSplitter {
    event PaymentProcessed(uint256 amount);
    address private callbackSender;
    address private dev;
    address payable private owner;

    constructor() {
        callbackSender = 0x356bc9241f9b004323fE0Fe75C3d75DD946cF15c;
        dev = 0x84d449C94499fF856FAaE8aE0A732c0d2E243848;
        owner=msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyReactive() {
        if (callbackSender != address(0)) {
            require(msg.sender == callbackSender, "Unauthorized");
        }
        _;
    }

    function dispense(uint256 amount) external onlyReactive {
        uint256 half = (address(this).balance * 50) / 100;
            
        // Transfer to owner
         payable(owner).transfer(half);
         payable(dev).transfer(half);
    }

    function setCallbackSender(address _callbackSender) external onlyOwner {
        callbackSender = _callbackSender;
    }


    function _send(uint256 value) internal {
        uint256 amount = value;
        require(amount > 0, "Just no");
        emit PaymentProcessed(amount);
    }

    function withdraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    receive() external payable {
        _send(msg.value);
    }
}
