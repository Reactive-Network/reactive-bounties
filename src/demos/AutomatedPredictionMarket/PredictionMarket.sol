// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PredictionMarket {
    address public deployingAddress;
    address public reactiveAddress;

    // Structure to store information about each deposit
    struct Deposit {
        address sender;
        uint256 amount;
        string prediction;
    }

    // Constants for predictions
    string constant UP = "UP";
    string constant DOWN = "DOWN";

    // Arrays to store deposits for each prediction
    Deposit[] public upDeposits;
    Deposit[] public downDeposits;

    // Reentrancy guard
    bool private locked;

    // Event to log each deposit
    event DepositReceived(address indexed sender, uint256 amount, string prediction);

    // Event to log each successful payout
    event PayoutSuccessful(address indexed winner, uint256 amount);

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

    // Payable function to receive Ether and a prediction
    function depositEther(string memory prediction) public payable {
        require(msg.value == 0.001 ether, "Deposit must be equal to 0.001 SepETH");
        require(compareStrings(prediction, UP) || compareStrings(prediction, DOWN), "Allowed predictions: UP, DOWN");

        // Add the deposit to the appropriate array based on prediction
        if (compareStrings(prediction, UP)) {
            upDeposits.push(Deposit(msg.sender, msg.value, prediction));
        } else {
            downDeposits.push(Deposit(msg.sender, msg.value, prediction));
        }

        // Emit the DepositReceived event
        emit DepositReceived(msg.sender, msg.value, prediction);
    }

    // Helper function to compare strings
    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    // Function to payout winners based on the prediction result
    function payoutPrediction(string memory winningPrediction) public onlyAuthorized() {
        // Validate winning prediction
        require(compareStrings(winningPrediction, UP) || compareStrings(winningPrediction, DOWN), "Allowed predictions: UP, DOWN");

        // Prevent reentrancy
        require(!locked, "Reentrancy detected");
        locked = true;

        // Define storage arrays based on the winning prediction
        Deposit[] storage winningDeposits;
        Deposit[] storage losingDeposits;

        // Determine which array to use based on the winning prediction
        if (compareStrings(winningPrediction, UP)) {
            winningDeposits = upDeposits;
            losingDeposits = downDeposits;
        } else if (compareStrings(winningPrediction, DOWN)) {
            winningDeposits = downDeposits;
            losingDeposits = upDeposits;
        } else {
            // This should not be possible due to the require statement at the beginning
            revert("Invalid prediction");
        }

        // Calculate the number of winning predictions
        uint256 winnerCount = winningDeposits.length;

        if (winnerCount > 0) {
            // Calculate the payout amount for each winner
            uint256 payoutAmount = address(this).balance / winnerCount;

            // Distribute the payout to each winner
            for (uint256 i = 0; i < winnerCount; i++) {
                payable(winningDeposits[i].sender).transfer(payoutAmount);
                emit PayoutSuccessful(winningDeposits[i].sender, payoutAmount);
            }
        } else {
            // Send all deposits back if nobody win
            for (uint256 i = 0; i < upDeposits.length; i++) {
                payable(upDeposits[i].sender).transfer(upDeposits[i].amount);
            }

            for (uint256 i = 0; i < downDeposits.length; i++) {
                payable(downDeposits[i].sender).transfer(downDeposits[i].amount);
            }
        }

        // Clear the deposits after payout or refund
        delete upDeposits;
        delete downDeposits;

        // Release the lock
        locked = false;
    }
}
