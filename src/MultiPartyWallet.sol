// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MultiPartyWallet is Ownable {
    struct Shareholder {
        uint256 shares;
        uint256 lastClaimed;
    }

    uint256 public totalShares;
    uint256 public totalDistributed;
    mapping(address => Shareholder) public shareholders;
    address[] public shareholderAddresses;

    event FundsReceived(address indexed from, uint256 amount);
    event FundsDistributed(uint256 totalDistributed);
    event ShareholderAdded(address indexed shareholder, uint256 shares);
    event ShareholderRemoved(address indexed shareholder);

    modifier onlyShareholder() {
        require(shareholders[msg.sender].shares > 0, "Not a shareholder");
        _;
    }

    constructor(address initialOwner) Ownable(initialOwner) {}

    function addShareholder(address _shareholder, uint256 _shares) external onlyOwner {
        require(_shareholder != address(0), "Invalid address");
        require(_shares > 0, "Shares must be greater than zero");
        require(shareholders[_shareholder].shares == 0, "Shareholder already exists");

        shareholders[_shareholder] = Shareholder({
            shares: _shares,
            lastClaimed: totalDistributed
        });
        shareholderAddresses.push(_shareholder);
        totalShares += _shares;

        emit ShareholderAdded(_shareholder, _shares);
    }

    function removeShareholder(address _shareholder) external onlyOwner {
        require(shareholders[_shareholder].shares > 0, "Not a shareholder");

        totalShares -= shareholders[_shareholder].shares;
        delete shareholders[_shareholder];

        for (uint256 i = 0; i < shareholderAddresses.length; i++) {
            if (shareholderAddresses[i] == _shareholder) {
                shareholderAddresses[i] = shareholderAddresses[shareholderAddresses.length - 1];
                shareholderAddresses.pop();
                break;
            }
        }

        emit ShareholderRemoved(_shareholder);
    }

    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }

    function distributeFunds() external {
        require(address(this).balance > 0, "No funds to distribute");

        uint256 totalBalance = address(this).balance;
        for (uint256 i = 0; i < shareholderAddresses.length; i++) {
            address shareholderAddress = shareholderAddresses[i];
            Shareholder storage shareholder = shareholders[shareholderAddress];

            uint256 payment = (totalBalance * shareholder.shares) / totalShares;
            payable(shareholderAddress).transfer(payment);
        }

        totalDistributed += totalBalance;
        emit FundsDistributed(totalBalance);
    }

    function distributeTokenFunds(IERC20 token) external {
        uint256 totalBalance = token.balanceOf(address(this));
        require(totalBalance > 0, "No token funds to distribute");

        for (uint256 i = 0; i < shareholderAddresses.length; i++) {
            address shareholderAddress = shareholderAddresses[i];
            Shareholder storage shareholder = shareholders[shareholderAddress];

            uint256 payment = (totalBalance * shareholder.shares) / totalShares;
            token.transfer(shareholderAddress, payment);
        }

        totalDistributed += totalBalance;
        emit FundsDistributed(totalBalance);
    }

    function getShareholderAddresses() external view returns (address[] memory) {
        return shareholderAddresses;
    }

    function getShareholder(address _shareholder) external view returns (uint256 shares, uint256 lastClaimed) {
        Shareholder memory shareholder = shareholders[_shareholder];
        return (shareholder.shares, shareholder.lastClaimed);
    }
}
