// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import {IERC6551Account}  from "./interface/IERC6551Account.sol";



contract ERC6551Account is IERC6551Account,AccessControl { 


    uint256 public nonce;

     

    address public owner;
    address Reactive;
    address RegistryContract;

    event TransactionExecuted(uint chainid,address from ,address to,uint256 value,bytes data);
    bytes32 public constant INITIALIZE_ROLE=keccak256("INITIALIZE_ROLE");
    bytes32 public constant CALLBACK_ROLE=keccak256("CALLBACK_ROLE");
    constructor(uint _sourcechainID,address _tokenaddress,uint _tokenID,address reactive_callback){
        
        Reactive=reactive_callback;
        RegistryContract=msg.sender;
        _grantRole(INITIALIZE_ROLE, RegistryContract); // only registry can initialize owner
        _grantRole(CALLBACK_ROLE, reactive_callback);
        Token=TokenDetails(_sourcechainID,_tokenaddress,_tokenID);
    }

    TokenDetails Token;

    receive() external payable {}

    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory result) {

        require(msg.sender == owner, "Not token owner");

        ++nonce;

        emit TransactionExecuted(block.chainid,msg.sender,to, value, data);

        bool success;
        (success, result) = to.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function InitializeOwner(address _owner) public onlyRole(INITIALIZE_ROLE){
        require(owner==address(0),"Owner is also initialized");
        owner=_owner;

    }

    
    function changeOwner(address newowner)public onlyReactive {
        // Trigers only when the ownership is transfered of NFT on source blockchain
        owner=newowner;
    }

    

    function token() public view returns(TokenDetails memory){
        return Token;
    }
    

    

    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        returns (bytes4 magicValue)
    {
        bool isValid = SignatureChecker.isValidSignatureNow(owner, hash, signature);

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }

        return "";
    }

    modifier onlyReactive() {
        require(msg.sender==RegistryContract);
        require(tx.origin==Reactive);
        _;
    }
}