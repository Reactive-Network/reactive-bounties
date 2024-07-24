// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract OneStepSwap {
    address public uniswapRouter;

    event SwapApproved(
        address indexed user,
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address to,
        uint deadline
    );

    constructor(address _uniswapRouter) {
        uniswapRouter = _uniswapRouter;
    }

    function approveAndEmit(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address to,
        uint deadline
    ) external {
        require(IERC20(tokenIn).approve(uniswapRouter, amountIn), "Approval Failed");
        emit SwapApproved(msg.sender, tokenIn, tokenOut, amountIn, amountOutMin, to, deadline);
    }
}