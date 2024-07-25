// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Token.sol";

contract ProtocolTokenManager  {

    uint TOKEN_TO_PROTOCOL_RATIO = 0.005 ether;
    // uint REWARD_TOKENS =5;
    // uint REWARD_LIMIT=0.1 ether;
    
    address REACTIVE_CALLBACK;
    address MANAGER;

    ProtocolToken Token;

    constructor(address callback_sender)
    {
        REACTIVE_CALLBACK=callback_sender;   // 0x356bc9241f9b004323fE0Fe75C3d75DD946cF15c
        MANAGER=msg.sender;
    }

   function setProtocolToken(address _token) public onlyManager {
        Token=ProtocolToken(_token);
   }

    function addedfunds(address ,address user,uint increasedAmount , uint totalAmount)public onlyReactive{

        uint totalTokensForUser=totalAmount/TOKEN_TO_PROTOCOL_RATIO;
        uint tokensTobeMinted= totalTokensForUser - Token.balanceOf(user);

        // if(increasedAmount>=REWARD_LIMIT){
        // // add any functionality if user spends more than specific funds on protocol    
        // _mint(user , REWARD_TOKENS); // this is additional amount
        // }

        Token.mint(user,tokensTobeMinted);
    }
    function withdrawFunds (address,address user , uint decreasedAmount ,uint totalAmount)public onlyReactive {
        uint totalTokensForUser=totalAmount/TOKEN_TO_PROTOCOL_RATIO;
        uint tokensTobeBurned=Token.balanceOf(user) - totalTokensForUser ;

        Token.burn(user,tokensTobeBurned);
    }

    modifier onlyReactive(){
        require(msg.sender==REACTIVE_CALLBACK);
        _;
    }

    modifier onlyManager(){
        require(msg.sender==MANAGER);
        _;
    }
}

