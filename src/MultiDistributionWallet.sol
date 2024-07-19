// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract MultiPartyWallet {
    struct Shareholder {
        uint256 shares;
        uint256 balance;
    }

    mapping(address => Shareholder) public shareholders;
    address[] public shareholderAddresses;
    uint256 public totalShares;
    IERC20 public token;

    event FundsReceived(address from, uint256 amount);
    event FundsDistributed(uint256 amount);

    constructor(address[] memory _shareholders, uint256[] memory _shares, address _tokenAddress) {
        require(_shareholders.length == _shares.length, "Mismatched input lengths");
        
        for (uint256 i = 0; i < _shareholders.length; i++) {
            shareholders[_shareholders[i]] = Shareholder({
                shares: _shares[i],
                balance: 0
            });
            shareholderAddresses.push(_shareholders[i]);
            totalShares += _shares[i];
        }

        token = IERC20(_tokenAddress);
    }

    function distributeFunds() external {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No funds to distribute");

        for (uint256 i = 0; i < shareholderAddresses.length; i++) {
            address shareholder = shareholderAddresses[i];
            uint256 amount = (balance * shareholders[shareholder].shares) / totalShares;
            shareholders[shareholder].balance += amount;
        }

        for (uint256 i = 0; i < shareholderAddresses.length; i++) {
            address shareholder = shareholderAddresses[i];
            uint256 payment = shareholders[shareholder].balance;
            shareholders[shareholder].balance = 0;
            require(token.transfer(shareholder, payment), "Transfer failed");
        }

        emit FundsDistributed(balance);
    }

    function getShareholderBalance(address shareholder) public view returns (uint256) {
        return shareholders[shareholder].balance;
    }
}
