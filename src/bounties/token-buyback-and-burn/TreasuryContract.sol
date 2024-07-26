// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

import '../../../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '../../../lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '../../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import '../../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol';

struct Reserves {
    uint112 reserve0;
    uint112 reserve1;
}

contract TreasuryContract {

    address private callback_sender;
    uint256 private buyback_size;
    address public owner;

    IUniswapV2Router02 private router;

    uint private constant DEADLINE = 2707391655;

    event ReservesMoved();

    constructor(address _callback_sender, address _router, uint256 _buyback_size, address _owner) {
        callback_sender = _callback_sender;
        router = IUniswapV2Router02(_router);
        buyback_size = _buyback_size;
        owner = _owner; 
    }

    modifier onlyReactive() {
        if (callback_sender != address(0)) {
            require(msg.sender == callback_sender, 'Unauthorized');
        }
        _;
    }

    function buybackAndBurn(
        address rvm,
        address pair,
        address client,
        bool is_token0,
        uint256 coefficient,
        uint256 threshold
    ) external onlyReactive {
        require(rvm == owner, 'Unauthorized');
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(pair).getReserves();
        require(below_threshold(is_token0, Reserves({ reserve0: reserve0, reserve1: reserve1 }), coefficient, threshold), 'Rate above threshold');
        address token_sell = is_token0 ? token0 : token1;
        address token_buy = is_token0 ? token1 : token0;
        uint amount = IERC20(token_sell).balanceOf(pair) / buyback_size;
        uint256 allowance = IERC20(token_sell).allowance(client, address(this));
        require(allowance > amount, 'Not enough allowance');
        require(IERC20(token_sell).balanceOf(client) >= allowance, 'Insufficient funds');
        assert(IERC20(token_sell).transferFrom(client, address(this), allowance));
        assert(IERC20(token_sell).approve(address(router), allowance));
        address[] memory path = new address[](2);
        path[0] = token_sell;
        path[1] = token_buy;
        uint256[] memory tokens = router.swapExactTokensForTokens(allowance, 0, path, address(this), DEADLINE);
        ERC20Burnable(token_buy).burn(tokens[1]);
        emit ReservesMoved();
    }

    function below_threshold(bool token0, Reserves memory sync, uint256 coefficient, uint256 threshold) internal pure returns (bool) {
        if (token0) {
            return (sync.reserve1 * coefficient) / sync.reserve0 <= threshold;
        } else {
            return (sync.reserve0 * coefficient) / sync.reserve1 <= threshold;
        }
    }
}
