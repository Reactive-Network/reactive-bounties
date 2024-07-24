// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "openzeppelin-contracts/contracts-upgradeable/security/PausableUpgradeable.sol";
import "openzeppelin-contracts/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract MultiPartyWallet is OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable {
    using SafeMathUpgradeable for uint256;

    uint256 public creationTime;
    uint256 public totalContributions;
    bool public walletClosed;
    uint256 public minimumContribution;
    uint256 public closureTime;
    uint256 public additionalFunds;

    struct Shareholder {
        uint256 contribution;
        uint256 share;
    }

    mapping(address => Shareholder) public shareholders;
    address[] public shareholderAddresses;
    mapping(address => uint256) private shareholderIndex;
    bool[] public shareholderActive;

    IERC20 public memeCoin;
    uint256 public memeCoinsPerEth;

    event MemeCoinsDistributed(address indexed shareholder, uint256 amount);
    event ContributionReceived(address indexed contributor, uint256 amount);
    event WalletClosed();
    event FundsDistributed(uint256 amount);
    event ShareCalculated(address indexed shareholder, uint256 share);
    event MinimumContributionUpdated(uint256 newMinimum);
    event SharesUpdated();
    event FallbackCalled(address sender, uint256 amount);
    event ClosureTimeUpdated(uint256 newClosureTime);
    event FundsReceived(address sender, uint256 amount);
    event FundsDistributedDirectly(uint256 amount);
    event ShareholderLeft(address indexed shareholder, uint256 amountWithdrawn, uint256 feesPaid);

    error WalletClosedError();
    error ContributionTooLowError();
    error NotClosedError();

    modifier onlyOpen() {
        if (walletClosed) revert WalletClosedError();
        _;
    }

    modifier onlyClosed() {
        if (!walletClosed) revert NotClosedError();
        _;
    }

    function initialize(uint256 _minimumContribution, uint256 _closureTime, address _memeCoinAddress, uint256 _memeCoinsPerEth) public initializer {
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        __Pausable_init();
        creationTime = block.timestamp;
        walletClosed = false;
        minimumContribution = _minimumContribution;
        closureTime = _closureTime;
        memeCoin = IERC20(_memeCoinAddress);
        memeCoinsPerEth = _memeCoinsPerEth;
        shareholderActive = new bool[](0);
    }

    function setMemeCoin(address _memeCoinAddress, uint256 _memeCoinsPerEth) external onlyOwner {
        memeCoin = IERC20(_memeCoinAddress);
        memeCoinsPerEth = _memeCoinsPerEth;
    }

    fallback() external payable {
        emit FallbackCalled(msg.sender, msg.value);
        if (walletClosed) {
            additionalFunds = additionalFunds.add(msg.value);
            emit FundsReceived(msg.sender, msg.value);
        } else {
            contribute();
        }
    }

    function setMinimumContribution(uint256 _newMinimum) external onlyOwner onlyOpen {
        require(_newMinimum > 0, "Minimum contribution must be greater than 0");
        minimumContribution = _newMinimum;
        emit MinimumContributionUpdated(_newMinimum);
    }

    function setClosureTime(uint256 _newClosureTime) external onlyOwner onlyOpen {
        require(_newClosureTime > block.timestamp, "Closure time must be in the future");
        closureTime = _newClosureTime;
        emit ClosureTimeUpdated(_newClosureTime);
    }

    function contribute() public payable onlyOpen whenNotPaused {
        if (msg.value < minimumContribution) revert ContributionTooLowError();

        if (shareholders[msg.sender].contribution == 0) {
            shareholderIndex[msg.sender] = shareholderAddresses.length;
            shareholderAddresses.push(msg.sender);
            shareholderActive.push(true);
        }

        shareholders[msg.sender].contribution = shareholders[msg.sender].contribution.add(msg.value);
        totalContributions = totalContributions.add(msg.value);

        emit ContributionReceived(msg.sender, msg.value);
    }

    function closeWallet() external onlyOpen {
    require(block.timestamp >= closureTime, "Cannot close wallet yet");
    walletClosed = true;

    // Distribute 1000 meme coins as a reward to the caller
    uint256 rewardAmount = 1000 * 10**18; // Assuming 18 decimals for the meme coin
    require(memeCoin.transfer(msg.sender, rewardAmount), "Reward transfer failed");

    emit WalletClosed();
    emit MemeCoinsDistributed(msg.sender, rewardAmount);
    //0xfa2763f7373a68fe3e9319f043584ac47e91ba6a95bef184a5a5ed00d198bba9
    }

    function updateShares() external onlyClosed {
        for (uint256 i = 0; i < shareholderAddresses.length; i++) {
            if (shareholderActive[i]) {
                address shareholderAddress = shareholderAddresses[i];
                shareholders[shareholderAddress].share = shareholders[shareholderAddress].contribution.mul(1e18).div(totalContributions);
                emit ShareCalculated(shareholderAddress, shareholders[shareholderAddress].share);
            }
        }
        emit SharesUpdated();
       // 0xc37a0c4c33ee983b1c1646116557ef4b86dcd6e2fec2c7938be43137a744d2f9
    }

    function distributeAllFunds() external onlyClosed nonReentrant {
        uint256 fundsToDistribute = additionalFunds;
        require(fundsToDistribute > 0, "No funds to distribute");

        for (uint256 i = 0; i < shareholderAddresses.length; i++) {
            if (shareholderActive[i]) {
                address shareholderAddress = shareholderAddresses[i];
                uint256 shareAmount = fundsToDistribute.mul(shareholders[shareholderAddress].share).div(1e18);

                if (shareAmount > 0) {
                    (bool success, ) = payable(shareholderAddress).call{value: shareAmount}("");
                    require(success, "Transfer failed");

                    if (address(memeCoin) != address(0) && memeCoinsPerEth > 0) {
                        uint256 memeCoinsAmount = shareAmount.mul(memeCoinsPerEth).div(1e18);
                        require(memeCoin.transfer(shareholderAddress, memeCoinsAmount), "MemeCoin transfer failed");
                        emit MemeCoinsDistributed(shareholderAddress, memeCoinsAmount);
                    }
                }
            }
        }

        additionalFunds = 0;
        emit FundsDistributedDirectly(fundsToDistribute);
        //0x667db984c13b718d62ef9e0788b2b1bf17a4b86d58d610d5299ebe3612249474
    }

    function leaveShareholding() external onlyClosed nonReentrant {
        Shareholder storage shareholder = shareholders[msg.sender];
        require(shareholder.contribution > 0, "Not a shareholder");
        require(shareholderActive[shareholderIndex[msg.sender]], "Shareholder already left");

        uint256 shareAmount = shareholder.contribution;
        uint256 feeAmount = shareAmount.mul(5).div(100); // 5% fee
        uint256 withdrawAmount = shareAmount.sub(feeAmount);

        // Mark shareholder as inactive
        shareholderActive[shareholderIndex[msg.sender]] = false;

        // Update total contributions
        totalContributions = totalContributions.sub(shareholder.contribution);

        // Reset shareholder's data
        shareholder.contribution = 0;
        shareholder.share = 0;

        // Transfer funds
        (bool success, ) = payable(msg.sender).call{value: withdrawAmount}("");
        require(success, "Transfer failed");

        emit ShareholderLeft(msg.sender, withdrawAmount, feeAmount);
        //0x5d6712e456ca571022e39ac7fef2dc1faf6c7d5f308ad90462f775c670896e1c
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    receive() external payable onlyClosed {
        additionalFunds = additionalFunds.add(msg.value);
        emit FundsReceived(msg.sender, msg.value);
        //0x8e47b87b0ef542cdfa1659c551d88bad38aa7f452d2bbb349ab7530dfec8be8f
    }
}