// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import '../../IReactive.sol';
import '../../ISubscriptionService.sol';

contract RSC is IReactive {
    

    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;
    uint256 private constant RECIEVED_TOPIC_0 = 0x92023dd282de3eea749a3a27a58271d70f04c1f7905fce2e1996ec9bdfccf33b;
    uint256 private constant WITHDRAW_TOPIC_0 = 0x5332f17e54d6548ba227c2597cdde808fa7184b0a1e8019eed07d9608d6b3a83; 


    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;

    uint64 private constant GAS_LIMIT = 1000000;

    
    bool public vm;

   

    // State specific to reactive network instance of the contract

    ISubscriptionService private service;
    address public _callback;

    // State specific to ReactVM instance of the contract

    uint256 public counter;

    constructor(address service_address, address _contract,  address callback) {
       
        service = ISubscriptionService(service_address);
        bytes memory payload1 = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            _contract,
            RECIEVED_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result1,) = address(service).call(payload1);
        if (!subscription_result1) {
            vm = true;
        }
        bytes memory payload2 = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            _contract,
            WITHDRAW_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result2,) = address(service).call(payload2);
        if (!subscription_result2) {
            vm = true;
        }
        _callback = callback;
    }

    modifier vmOnly() {
        // TODO: fix the assertion after testing.
        //require(vm, 'VM only');
        _;
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
        uint256 /* block_number */ ,
        uint256 /* op_code */  
    ) external override  vmOnly {
        if(topic_0==RECIEVED_TOPIC_0){
            bytes memory payload = abi.encodeWithSignature("addedfunds(address,address,uint256,uint256)", address(0),address(uint160(topic_1)),topic_2,topic_3);
            emit Callback(chain_id, _callback, GAS_LIMIT, payload);
        }
        else if(topic_0==WITHDRAW_TOPIC_0){
            bytes memory payload = abi.encodeWithSignature("withdrawFunds(address,address,uint256,uint256)", address(0),address(uint160(topic_1)),topic_2,topic_3);
            emit Callback(chain_id, _callback, GAS_LIMIT, payload);
        }

        
    }

    // Methods for testing environment only

    function subscribe(address _contract, uint256 topic_0) external {
        service.subscribe(
            SEPOLIA_CHAIN_ID,
            _contract,
            topic_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
    }

    function unsubscribe(address _contract, uint256 topic_0) external {
        service.unsubscribe(
            SEPOLIA_CHAIN_ID,
            _contract,
            topic_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
    }

    
}
