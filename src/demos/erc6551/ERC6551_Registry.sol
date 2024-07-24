//SPDX-License-Identifier:MiT

pragma solidity ^0.8.0;

import "./ERC6551Account.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";



contract ERC6551_Registry {

    
    address callbackSender; // 0x356bc9241f9b004323fE0Fe75C3d75DD946cF15c

    constructor(address callback_sender){
        callbackSender =callback_sender;
    }


    event Deployed(address addr, uint256 salt);
    event Account_created(address accountaddress,uint sourcechainID,address tokenaddress,uint tokenID,address owner);
    event test(address , uint,address ,uint,uint);


    function getBytecode(uint _sourcechainID,address _tokenaddress,uint _tokenID)
        internal 
        view
        returns (bytes memory)
    {
        bytes memory bytecode = type(ERC6551Account).creationCode;

        return abi.encodePacked(bytecode, abi.encode( _sourcechainID, _tokenaddress, _tokenID,callbackSender));
    }

    function account(uint _sourcechainID,address _tokenaddress,uint _tokenID, uint256 _salt)
        public
        view
        returns (address)
    {
        bytes memory bytecode=getBytecode(_sourcechainID, _tokenaddress, _tokenID);

        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff), address(this), _salt, keccak256(bytecode)
            )
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }

    function createAccount(address/* rvm address*/ ,address owner,uint _sourcechainID,address _tokenaddress,uint _tokenID,uint256 _salt)  public onlyCallbackSender {
        address addr;

        bytes memory bytecode =getBytecode(_sourcechainID, _tokenaddress, _tokenID);
        
        address deployedaddress =account(_sourcechainID, _tokenaddress, _tokenID,_salt);

        assembly {
            addr :=
                create2(
                    callvalue(), // wei sent with current call
                    // Actual code starts after skipping the first 32 bytes
                    add(bytecode, 0x20),
                    mload(bytecode), // Load the size of code contained in the first 32 bytes
                    _salt // Salt from function arguments
                )

            if iszero(extcodesize(addr)) { revert(0, 0) }
        }

        ERC6551Account(payable(deployedaddress)).InitializeOwner(owner);


        emit test( owner, _sourcechainID, _tokenaddress, _tokenID, _salt);
    }

    function isAccountCreated(uint _sourcechainID,address _tokenaddress,uint _tokenID, uint256 _salt)public view returns(bool){
        address accountaddress= account( _sourcechainID, _tokenaddress, _tokenID, _salt);
        if(accountaddress.code.length!=0){
            return true;
        }
        return false;
    }

    function changeOwnerofAccount(address /* rvm address*/ ,address newowner,uint _sourcechainID,address _tokenaddress,uint _tokenID, uint256 _salt) onlyCallbackSender public{
        bytes memory payload =abi.encodeWithSignature("changeOwner(address)", newowner);
        address Erc6551account=account(_sourcechainID, _tokenaddress, _tokenID, _salt);

        (bool success,)=Erc6551account.call(payload);
        require(success);
    }

    modifier onlyCallbackSender(){
        require(msg.sender==callbackSender);
        _;
    }
}