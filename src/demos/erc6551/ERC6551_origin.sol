// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ERC6551_origin is AccessControl{

    event CreateAccount(uint indexed chainId,address indexed tokencontract,uint indexed  tokenid ,address owner);

    bytes32 public constant ERC_6551Admin = keccak256("ERC_6551ADMIN");

    mapping (uint =>bool) public suportedChains;
    constructor(){
        _grantRole(ERC_6551Admin, msg.sender);
    }

    function addNewChain(uint chainId)public onlyRole(ERC_6551Admin) {
        suportedChains[chainId]=true;
    }

    function removeChain (uint chainId) public onlyRole(ERC_6551Admin){
        suportedChains[chainId]=false;
    }
    

    function createAccount(uint destinationchainId,address tokenAddress,uint tokenId)public onlySupportedChains(destinationchainId){
        require(IERC721(tokenAddress).ownerOf(tokenId)==msg.sender,"only owner can create Account");
        
        emit CreateAccount(destinationchainId, tokenAddress, tokenId ,msg.sender);
    }

    modifier onlySupportedChains(uint chainId){
        require(suportedChains[chainId],"The Destination Chain Is Not Supported");
        _;
    }
}