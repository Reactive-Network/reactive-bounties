// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import '../../IReactive.sol';
import '../../ISubscriptionService.sol';

contract ERC6551_Reactive is IReactive {
    

    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;
    uint256 private constant CreateAccount_Topic0=0x579110487e25ff4d20737727a96adf04488256fde34dff228caa34ac995a8e11;
    uint256 private constant Transfer_Topic0=0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;


    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 private constant REACTIVE_CHAIN_ID = 5318008;

    uint64 private constant GAS_LIMIT = 9000000;

    ISubscriptionService private service;
    address public _callback;
    
    uint[] DestinationChainIds;


    constructor(address service_address, address _contract, address callback,uint[] memory destinationchainid) {

        DestinationChainIds=destinationchainid;
        service = ISubscriptionService(service_address);
        bytes memory payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            _contract,
            CreateAccount_Topic0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result1,) = address(service).call(payload);
        
        
        _callback = callback;
    }

        

    // Methods specific to ReactVM instance of the contract

    function react(
        uint256 chain_id,
        address _contract,
        uint256 topic_0,
        uint256 topic_1,
        uint256 topic_2,
        uint256 topic_3,
        bytes calldata data,
        uint256 /* block_number */ _blocknumber,
        uint256 /* op_code */ _opcode 
    ) external override  {
        if(topic_0==CreateAccount_Topic0){
            address owner=abi.decode(data,(address));
            bytes memory payload= abi.encodeWithSignature(
                "createAccount(address,address,uint256,address,uint256,uint256)",
                address(0), //rvm Address
                owner,
                SEPOLIA_CHAIN_ID,
                address(uint160(topic_2)),
                topic_3,
                7000  // salt
            );

            
            emit Callback(topic_1, _callback, GAS_LIMIT, payload);
           
           bytes memory subscribepayload = abi.encodeWithSignature(
            "subscribe(address,address,uint256,uint256,uint256,uint256)",
            address(0),
            address(uint160(topic_2)),
            Transfer_Topic0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            topic_3
        );

            emit Callback(REACTIVE_CHAIN_ID, address(this), GAS_LIMIT, subscribepayload);

        }
        else if (topic_0==Transfer_Topic0){

            for(uint i=0;i<DestinationChainIds.length;i++){
            bytes memory payload = abi.encodeWithSignature("changeOwnerofAccount(address,address,uint256,address,uint256,uint256)", 
            address(0),
            address(uint160(topic_2)),
            SEPOLIA_CHAIN_ID,
            _contract,
            topic_3,
            7000
            );
            emit Callback(DestinationChainIds[i], _callback, GAS_LIMIT, payload);
            }
        }
    }



    function subscribe(address /* rvm address*/ ,address _contract,uint256 topic_0,uint256 topic_1,uint256 topic_2,uint256 topic_3) external {
        
        bytes memory payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
             SEPOLIA_CHAIN_ID,
            _contract,
            topic_0,
            topic_1,
            topic_2,
            topic_3
        );
        (bool subscription_result1,) = address(service).call(payload);
    }
 
}
