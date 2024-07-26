// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract is almost the same as SecureContract.sol,
// but modifier bug is corrected, some var names adjusted
// and payout function slightly changed
contract GenerousVault {
    address public deployingAddress;
    address public reactiveAddress;

    // Event to be emitted on ETH transfer
    event EthTransferred(address indexed initiator, uint256 value, address indexed recipient);

    // Modifier to restrict access to the Reactive Network Sepolia Address or the deploying address
    modifier onlyAuthorized() {
        require(msg.sender == reactiveAddress || msg.sender == deployingAddress, "Access restricted to authorized addresses");
        _;
    }

    // Constructor to set the Reactive Network Sepolia Address and the deploying address
    constructor() {
        deployingAddress = msg.sender;
        reactiveAddress = 0x356bc9241f9b004323fE0Fe75C3d75DD946cF15c;
    }

    // Function to receive ETH (payable)
    receive() external payable {
        // Emit the event on ETH reception for transparency
        emit EthTransferred(msg.sender, msg.value, address(this));
    }

    // Fallback function to receive ETH (payable)
    fallback() external payable {
        // Emit the event on ETH reception for transparency
        emit EthTransferred(msg.sender, msg.value, address(this));
    }

    // Function to transfer ETH from the contract to any address
    // Blank address arg added to comply with RCS specification
    function payout(address /* RVM ID */, address payable policyholder, uint256 compensation) onlyAuthorized() public {
        require(address(this).balance >= compensation, "Insufficient ETH balance in GenerousVault");
        policyholder.transfer(compensation);

        // Emit the EthTransferred event
        emit EthTransferred(msg.sender, compensation, policyholder);
    }
}
