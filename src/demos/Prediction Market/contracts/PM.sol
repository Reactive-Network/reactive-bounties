// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PredictionMarket{
    enum BetOption { Fear, Greed }
    enum MarketStatus { Active, Closed }
    
    struct Bet {
        address user;
        BetOption option;
        uint256 amount;
    }

    struct Market {
        Bet[] bets;
        uint256 totalBetFear;
        uint256 totalBetGreed;
        uint256 totalBalance;
        bool resultSet;
        BetOption result;
        uint256 FGI;
        MarketStatus status;
        mapping(address => uint256) userBets;
    }

    uint256 public marketCount;
    mapping(uint256 => Market) public markets;

    event MarketCreated(uint256 marketId);
    event BetPlaced(uint256 marketId, address user, BetOption option, uint256 amount);
    event FGISet(uint256 indexed marketId, uint256 indexed FGI);
    event Payout(uint256 marketId, address user, uint256 amount);
    
    address public oracle;
    address public owner;
    
    modifier onlyOracle() {
        require(msg.sender == oracle, "Caller is not the oracle");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
    
    modifier onlyActiveMarket(uint256 _marketId) {
        require(markets[_marketId].status == MarketStatus.Active, "Market is not active");
        _;
    }
    
    
    constructor() {
        createMarket();
        oracle = msg.sender; // Set to contract creator initially
        owner = msg.sender;  // Set to contract creator initially
    }

    function createMarket() internal {
        marketCount++;
        Market storage newMarket = markets[marketCount];
        newMarket.status = MarketStatus.Active;
        emit MarketCreated(marketCount);
    }

    function placeBet(uint256 _marketId, BetOption _option) external payable onlyActiveMarket(_marketId) {
        require(msg.value > 0, "Bet amount must be greater than 0");
        Market storage market = markets[_marketId];

        if (_option == BetOption.Fear) {
            market.totalBetFear += msg.value;
        } else if (_option == BetOption.Greed) {
            market.totalBetGreed += msg.value;
        }
        
        market.totalBalance += msg.value;
        market.userBets[msg.sender] += msg.value;

        market.bets.push(Bet({
            user: msg.sender,
            option: _option,
            amount: msg.value
        }));

        emit BetPlaced(_marketId, msg.sender, _option, msg.value);
    }

    function setFGI(uint256 _marketId, uint256 _fgi) external onlyOracle onlyActiveMarket(_marketId) {
        Market storage market = markets[_marketId];
        market.FGI = _fgi;

        if (_fgi > 50) {
            market.result = BetOption.Greed;
        } else {
            market.result = BetOption.Fear;
        }
        market.resultSet = true;
        market.status = MarketStatus.Closed;

        emit FGISet(_marketId, _fgi);
        // Create a new market for future bets
        createMarket();
    }
    
    function payout(uint256 _marketId) external {
        marketCount= marketCount-1;
        Market storage market = markets[marketCount];
        require(markets[marketCount].resultSet == true, "Market is not closed");

        for (uint256 i = 0; i < market.bets.length; i++) {
            Bet memory bet = market.bets[i];
            uint256 payoutAmount = 0;

            if (market.result == BetOption.Greed) {
                if (market.totalBetGreed > 0) {
                    payoutAmount = (bet.amount * market.totalBalance) / market.totalBetGreed;
                }
            } else if (market.result == BetOption.Fear) {
                if (market.totalBetFear > 0) {
                    payoutAmount = (bet.amount * market.totalBalance) / market.totalBetFear;
                }
            }

            if (payoutAmount > 0) {
                payable(bet.user).transfer(payoutAmount);
                emit Payout(_marketId, bet.user, payoutAmount);
            }
        }
    }
    
    function updateOracle(address _newOracle) external onlyOwner {
        oracle = _newOracle;
    }
    
    function emergencyWithdraw(uint256 _marketId) external onlyOwner {
        Market storage market = markets[_marketId];
        require(market.status == MarketStatus.Active, "Market is not active");
        
        uint256 balance = market.totalBalance;
        market.totalBalance = 0;
        
        payable(owner).transfer(balance);
    }
}
