// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract ReactiveMultiPartyWallet {
    struct Shareholder {
        uint256 shares;
        uint256 balance;
    }

    mapping(address => Shareholder) public shareholders;
    address[] public shareholderAddresses;
    uint256 public totalShares;
    IERC20 public token;

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

    function onTokenTransfer(address sender, uint256 amount, bytes calldata data) external {
        require(msg.sender == address(token), "Only the token contract can call this function");
        distributeFunds(amount);
    }

    function distributeFunds(uint256 amount) internal {
        require(amount > 0, "No funds to distribute");

        for (uint256 i = 0; i < shareholderAddresses.length; i++) {
            address shareholder = shareholderAddresses[i];
            uint256 shareholderAmount = (amount * shareholders[shareholder].shares) / totalShares;
            shareholders[shareholder].balance += shareholderAmount;
        }

        for (uint256 i = 0; i < shareholderAddresses.length; i++) {
            address shareholder = shareholderAddresses[i];
            uint256 payment = shareholders[shareholder].balance;
            shareholders[shareholder].balance = 0;
            require(token.transfer(shareholder, payment), "Transfer failed");
        }

        emit FundsDistributed(amount);
    }

    function getShareholderBalance(address shareholder) public view returns (uint256) {
        return shareholders[shareholder].balance;
    }
}
