// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC6551Account {


    receive() external payable;

    struct TokenDetails{
        uint sourcechainID;
        address tokenaddress;
        uint tokenID;
    }

    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory);

    function token()
        external
        view
        returns (TokenDetails memory );

    function owner() external view returns (address);

    function nonce() external view returns (uint256);

    
}