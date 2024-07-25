// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CryptoInsurance is Ownable,ReentrancyGuard{
    enum InsuranceType { LOAN, THRESHOLD, SUDDEN_DROP }
    
    struct AssetInfo {
        AggregatorV3Interface priceFeed;
        uint256 maxCoverage;
    }

    struct Policy {
        address holder;
        InsuranceType insuranceType;
        uint256 coverageAmount;
        uint256 premium;
        uint256 startTime;
        uint256 endTime;
        uint256 triggerPrice;
        uint256 purchasePrice;
        bool active;
    }

    struct Claim {
        uint256 amount;
        bool processed;
    }

    struct AssetPrice {
        uint256 lastPrice;
        uint256 lastUpdateTimestamp;
    }

    address[] public supportedAssetsList;
    uint256 public LastTriggerTimestamp;
    IERC20 public memeCoin;
    uint256 public memeCoinsPerCheck;
    uint256 public activePoliciesCount;

    mapping(address => AssetInfo) public supportedAssets;
    mapping(address => mapping(address => mapping(InsuranceType => Policy))) public policies;
    mapping(address => mapping(address => mapping(InsuranceType => Claim))) public claims;
    mapping(address => AssetPrice) public assetPrices;
    mapping(address => uint256) public memeRewards;

    uint256 public constant POLICY_DURATION = 30 days;
    uint256 public constant SUDDEN_DROP_THRESHOLD = 20;
    uint256 public constant SUDDEN_DROP_WINDOW = 1 days;
    uint256 public constant LOAN_PREMIUM_RATE = 1000;
    uint256 public constant THRESHOLD_PREMIUM_RATE = 1500;
    uint256 public constant SUDDEN_DROP_PREMIUM_RATE = 2000;

    event PolicyCreated(address indexed holder, address indexed asset, InsuranceType insuranceType, uint256 coverageAmount);
    event ClaimFiled(address indexed holder, address indexed asset, InsuranceType insuranceType, uint256 amount);
    event ClaimPaid(address indexed holder, address indexed asset, InsuranceType insuranceType, uint256 amount);
    event PriceChanged(address indexed asset, uint256 oldPrice, uint256 newPrice);
    event TriggerPriceCheck();
    event MemeCoinsDistributed(address indexed recipient, uint256 amount);

    constructor() Ownable(msg.sender) {}

    receive() external payable {}

    function addSupportedAsset(address asset, address priceFeed, uint256 maxCoverage) external onlyOwner {
        supportedAssets[asset] = AssetInfo(AggregatorV3Interface(priceFeed), maxCoverage);
        supportedAssetsList.push(asset);
        
        (,int256 price,,,) = AggregatorV3Interface(priceFeed).latestRoundData();
        require(price > 0, "Invalid price data");
        assetPrices[asset] = AssetPrice(uint256(price), block.timestamp);
    }

    function createPolicy(
        address asset,
        InsuranceType insuranceType,
        uint256 coverageAmount,
        uint256 triggerPrice
    ) external payable nonReentrant {
        AssetInfo storage assetInfo = supportedAssets[asset];
        require(address(assetInfo.priceFeed) != address(0), "Asset not supported");
        require(coverageAmount <= assetInfo.maxCoverage, "Coverage exceeds limit");

        uint256 premium = calculatePremium(insuranceType, coverageAmount);
        require(msg.value >= premium, "Insufficient premium");

        (, int256 currentPrice,,,) = assetInfo.priceFeed.latestRoundData();
        require(currentPrice > 0, "Invalid price data");

        policies[asset][msg.sender][insuranceType] = Policy({
            holder: msg.sender,
            insuranceType: insuranceType,
            coverageAmount: coverageAmount,
            premium: premium,
            startTime: block.timestamp,
            endTime: block.timestamp + POLICY_DURATION,
            triggerPrice: triggerPrice,
            purchasePrice: uint256(currentPrice),
            active: true
        });

        activePoliciesCount++;
        emit PolicyCreated(msg.sender, asset, insuranceType, coverageAmount);
    }

    function calculatePremium(InsuranceType insuranceType, uint256 coverageAmount) internal pure returns (uint256) {
        if (insuranceType == InsuranceType.LOAN) {
            return (coverageAmount * LOAN_PREMIUM_RATE) / 10000;
        } else if (insuranceType == InsuranceType.THRESHOLD) {
            return (coverageAmount * THRESHOLD_PREMIUM_RATE) / 10000;
        } else if (insuranceType == InsuranceType.SUDDEN_DROP) {
            return (coverageAmount * SUDDEN_DROP_PREMIUM_RATE) / 10000;
        }
        revert("Invalid insurance type");
    }

    function setMemeCoin(address _memeCoinAddress, uint256 _memeCoinsPerCheck) external onlyOwner {
        memeCoin = IERC20(_memeCoinAddress);
        memeCoinsPerCheck = _memeCoinsPerCheck;
    }

    function triggerPriceCheck() external {
        if(LastTriggerTimestamp !=0){
            require(block.timestamp >= LastTriggerTimestamp + 1 hours, "Can only trigger once per hour");
        }
        LastTriggerTimestamp = block.timestamp;
        
        if (address(memeCoin) != address(0) && memeCoinsPerCheck > 0) {
            memeRewards[msg.sender] += memeCoinsPerCheck;
            emit MemeCoinsDistributed(msg.sender, memeCoinsPerCheck);
        }
        
        emit TriggerPriceCheck();
    }

    function checkAllPriceChanges(address /*sender*/) external {
        for (uint256 i = 0; i < supportedAssetsList.length; i++) {
            checkPriceChange(supportedAssetsList[i]);
        }
    }

    function checkPriceChange(address asset) public {
        AssetInfo storage assetInfo = supportedAssets[asset];
        require(address(assetInfo.priceFeed) != address(0), "Asset not supported");

        AssetPrice storage assetPrice = assetPrices[asset];
        require(block.timestamp >= assetPrice.lastUpdateTimestamp, "Check too frequent");

        (,int256 currentPrice,,,) = assetInfo.priceFeed.latestRoundData();
        require(currentPrice > 0, "Invalid price data");

        uint256 oldPrice = assetPrice.lastPrice;
        uint256 newPrice = uint256(currentPrice);

        if (newPrice != oldPrice) {
            assetPrice.lastPrice = newPrice;
            assetPrice.lastUpdateTimestamp = block.timestamp;
            emit PriceChanged(asset, oldPrice, newPrice);

            // Check claims for all policy types
            for (uint i = 0; i < 3; i++) {
                InsuranceType insuranceType = InsuranceType(i);
                _checkAndProcessClaims(asset, insuranceType);
            }
        }
    }

    function _checkAndProcessClaims(address asset, InsuranceType insuranceType) internal {
        for (uint256 i = 0; i < supportedAssetsList.length; i++) {
            address holder = supportedAssetsList[i];
            Policy storage policy = policies[asset][holder][insuranceType];
            if (policy.active && isClaimValid(asset, policy)) {
                _processClaim(asset, holder, insuranceType);
            }
        }
    }

    function _processClaim(address asset, address holder, InsuranceType insuranceType) internal {
        Policy storage policy = policies[asset][holder][insuranceType];
        uint256 payoutAmount = calculatePayout(asset, policy);
        if (payoutAmount > 0) {
            claims[asset][holder][insuranceType] = Claim({
                amount: payoutAmount,
                processed: true
            });
            policy.active = false;
            activePoliciesCount--;

            (bool success, ) = payable(holder).call{value: payoutAmount}("");
            require(success, "Payout failed");
            emit ClaimFiled(holder, asset, insuranceType, payoutAmount);
            emit ClaimPaid(holder, asset, insuranceType, payoutAmount);
        }
    }

    function isClaimValid(address asset, Policy storage policy) internal view returns (bool) {
        if (block.timestamp > policy.endTime) return false;

        (, int256 currentPrice,,,) = supportedAssets[asset].priceFeed.latestRoundData();
        require(currentPrice > 0, "Invalid price data");

        if (policy.insuranceType == InsuranceType.LOAN || policy.insuranceType == InsuranceType.THRESHOLD) {
            return uint256(currentPrice) < policy.triggerPrice;
        } else if (policy.insuranceType == InsuranceType.SUDDEN_DROP) {
            uint256 dropPercentage = calculatePriceDrop(policy.purchasePrice, uint256(currentPrice));
            return dropPercentage >= SUDDEN_DROP_THRESHOLD && (block.timestamp - policy.startTime) <= SUDDEN_DROP_WINDOW;
        }
        return false;
    }

    function calculatePayout(address asset, Policy storage policy) internal view returns (uint256) {
        (, int256 currentPrice,,,) = supportedAssets[asset].priceFeed.latestRoundData();
        
        if (policy.insuranceType == InsuranceType.LOAN) {
            return calculateLoanPayout(policy.coverageAmount, policy.triggerPrice, uint256(currentPrice));
        } else if (policy.insuranceType == InsuranceType.THRESHOLD) {
            return policy.coverageAmount;
        } else if (policy.insuranceType == InsuranceType.SUDDEN_DROP) {
            uint256 dropPercentage = calculatePriceDrop(policy.purchasePrice, uint256(currentPrice));
            return (policy.coverageAmount * dropPercentage) / 100;
        }
        return 0;
    }

    function calculateLoanPayout(uint256 coverageAmount, uint256 loanPrice, uint256 currentPrice) 
        internal pure returns (uint256) 
    {
        if (currentPrice >= loanPrice) return 0;
        uint256 priceDrop = loanPrice - currentPrice;
        return (coverageAmount * priceDrop) / loanPrice;
    }

    function calculatePriceDrop(uint256 startPrice, uint256 currentPrice) 
        internal pure returns (uint256) 
    {
        if (currentPrice >= startPrice) return 0;
        return ((startPrice - currentPrice) * 100) / startPrice;
    }

    function claimMemeReward() external {
        uint256 rewardAmount = memeRewards[msg.sender];
        require(rewardAmount > 0, "No meme coin rewards to claim");
        
        memeRewards[msg.sender] = 0;
        
        require(memeCoin.transfer(msg.sender, rewardAmount), "Meme coin transfer failed");
    }

    function getUserPolicies(address user, address asset) external view returns (Policy[3] memory) {
        Policy[3] memory userPolicies;
        for (uint i = 0; i < 3; i++) {
            userPolicies[i] = policies[asset][user][InsuranceType(i)];
        }
        return userPolicies;
    }
    function withdrawEther() external onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "No Ether to withdraw");

    (bool success, ) = payable(owner()).call{value: balance}("");
    require(success, "Withdrawal failed");

    
}
}