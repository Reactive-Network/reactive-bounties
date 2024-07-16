// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract is same as TopSecureContract.sol, but modifier bug is corrected
contract GenerousInsurance {
    address public whateverInsuranceInc;

    // Event to be emitted on ETH transfer
    event EthTransferred(address indexed initiator, uint256 value, address indexed recipient);

    // Modifier to restrict access to only the Whatever Insurance
    modifier onlyWhateverInsurance() {
        require(msg.sender == whateverInsuranceInc, "Access restricted to the Whatever Insurance");
        _;
    }

    // Constructor to set the Whatever Insurance
    constructor() {
        whateverInsuranceInc = msg.sender;
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
    function transferEth(address payable recipient, uint256 amount) onlyWhateverInsurance() public {
        require(address(this).balance >= amount, "Insufficient ETH balance");
        recipient.transfer(amount);

        // Emit the EthTransferred event
        emit EthTransferred(msg.sender, amount, recipient);
    }
}
