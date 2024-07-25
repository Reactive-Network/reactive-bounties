// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;



import '../IReactive.sol';
import '../ISubscriptionService.sol';

contract InsuranceReactive is IReactive {

    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;

    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;

    uint256 private constant TRIGGER_PRICE_CHECK_TOPIC_0 =0xc873fdd0f3a9dd3aaad60921469a4f370bb6a654b5077af1c558b994a49bca36 ;
    
    uint64 private constant CALLBACK_GAS_LIMIT = 1000000;

    bool private vm;

    ISubscriptionService private service;
    address private l1;

    constructor(address service_address, address _l1) {
        
        service = ISubscriptionService(service_address);
        bytes memory payload1 = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            _l1,
            TRIGGER_PRICE_CHECK_TOPIC_0,
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
        if (topic_0 == TRIGGER_PRICE_CHECK_TOPIC_0) {
           
            bytes memory payload = abi.encodeWithSignature(
                "checkAllPriceChanges(address)",
                address(0)
            
            );
            emit Callback(chain_id, l1, CALLBACK_GAS_LIMIT, payload);
        }
    }
}
