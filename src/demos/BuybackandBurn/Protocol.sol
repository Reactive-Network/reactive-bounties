// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

contract Protocol {

    event FundsAdded (address indexed user,uint indexed increasedBalance,uint indexed totalBalance);
    event FundsRemoved (address indexed user, uint indexed reducedBalance,uint indexed totalBalance);

    mapping (address => uint) balances;
    bool locked;

    function depositeFunds() public payable {
        balances[msg.sender]+=msg.value;
        emit FundsAdded(msg.sender, msg.value, balances[msg.sender]);
    }

    function withdrawFunds(uint _amount) public ReentrancyGuard {
        require(balances[msg.sender]>=_amount,"cannot withdraw beyond user balance");

        balances[msg.sender]-=_amount;

        (bool success,)=payable(msg.sender).call{value:_amount}("");
        require(success,"withraw failed");
        emit FundsRemoved(msg.sender,_amount,balances[msg.sender]);

    }
    
    function demowith(uint totalamountshouldbe) public{
        emit FundsRemoved(msg.sender,100,totalamountshouldbe);
    }
    function demoadd(uint amount) public{
        emit FundsAdded(msg.sender, amount,amount*5);
    }

    modifier ReentrancyGuard (){
        require(!locked,"");
        locked=true;
        _;
        locked=false;
    }
    
}