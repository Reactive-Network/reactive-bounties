// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

import '../IReactive.sol';
import '../ISubscriptionService.sol';

contract AutomatedPredictionReactive is IReactive {
    

    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 private constant PREDICTION_RESOLVED_TOPIC_0 = 0xe0d11dcca65d89777e74a05aabfc99281a4c018644b33af1b397a7dbf5e2911b;
    uint64 private constant CALLBACK_GAS_LIMIT = 1000000;

    bool private vm;
    ISubscriptionService private service;
    address private l1;

    constructor(address service_address, address _l1) {
        service = ISubscriptionService(service_address);

        // First subscription call
        bytes memory payload1 = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            _l1,
            PREDICTION_RESOLVED_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result1,) = address(service).call(payload1);
        if (!subscription_result1) {
            vm = true;
        }

        l1 = _l1;
    }

    modifier rnOnly() {
        require(!vm, "Reactive Network only");
        _;
    }

    modifier vmOnly() {
        // require(vm, "VM only");
        _;
    }

    function react(
        uint256 chain_id,
        address _contract,
        uint256 topic_0,
        uint256 topic_1,
        uint256 topic_2,
        uint256 topic_3,
        bytes calldata data,
        uint256 /* block number */,
        uint256 /* op_code */
    ) external vmOnly {
        if(topic_0 == PREDICTION_RESOLVED_TOPIC_0){
           

        bytes memory payload = abi.encodeWithSignature(
            "distributeWinnings(address,uint256)",
            address(0),
            topic_1
        );

        emit Callback(SEPOLIA_CHAIN_ID, l1, CALLBACK_GAS_LIMIT, payload);
            
        }

        // Assuming topic_1 contains the required uint256 value for resolvePrediction
        
    }
}