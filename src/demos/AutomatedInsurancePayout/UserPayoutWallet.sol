// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

contract UserPayoutWallet {

    address owner;
    address Reactive;
    address InsuranceContract;

    constructor(address callback_sender,address insurance_contract){
        Reactive=callback_sender;
        InsuranceContract=insurance_contract;
        owner=msg.sender;
    }

    function PayForInsurance(address ,uint amount,address to)public {
        require(address(this).balance>=amount,"Insufficient funds");

        bytes memory payload = abi.encodeWithSignature("payInsurance(address,uint256)", to,amount);

        (bool success,)=InsuranceContract.call
        {value:amount}
        (payload);
        require(success,"Payment Failed");
    }

    function withdraw() public onlyOwner{
        payable(owner).transfer(address(this).balance);
    }
    
    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }
    



    receive() external payable { }
}