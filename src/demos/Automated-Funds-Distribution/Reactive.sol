// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import '../../IReactive.sol';
import '../../ISubscriptionService.sol';

contract AutomatedFundsTransferReactive is IReactive {
    

    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;
    uint256  private immutable TRANSFER_TOPIC_0 ; // 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef

    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;

    uint64 private constant GAS_LIMIT = 1000000;
    
    bool private vm;


    ISubscriptionService private service;
    address private immutable CONTRACT;

    address[] public SupportedTokenaddress;



    constructor(address service_address, address _contract, uint256 topic_0,address[] memory supportedTokens) {
        SupportedTokenaddress=supportedTokens;
        TRANSFER_TOPIC_0=topic_0;
        CONTRACT = _contract;

        service = ISubscriptionService(service_address);
        bytes memory payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            _contract,
            topic_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );

        (bool subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
        }
        
        for(uint i=0;i<supportedTokens.length;i++){
            bytes memory payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            supportedTokens[i],
            topic_0,
            REACTIVE_IGNORE,
            uint256(uint160(CONTRACT)), 
            REACTIVE_IGNORE
        );

        (bool subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
        }
        }
    }

    modifier vmOnly() {   
        // require(vm, 'VM only');
        _;
    }

    // Methods specific to ReactVM instance of the contract
    function react(
        uint256 chain_id,
        address _contract,
        uint256 /*topic_0*/,
        uint256 /*topic_1*/,
        uint256 topic_2,
        uint256 /*topic_3*/,
        bytes calldata /*data*/,
        uint256 /* block_number */,
        uint256 /* op_code */
    ) external override vmOnly {
        
        if(_contract==CONTRACT){
            bytes memory payload =abi.encodeWithSignature("distributeFunds(address,address)",address(0),address(0)); // native ETH will be distributed
            emit Callback(chain_id, CONTRACT, GAS_LIMIT, payload);
        }else if(_contract!=CONTRACT && address(uint160(topic_2))==CONTRACT){  // contract recived tokens and will be distributed 
            bytes memory payload = abi.encodeWithSignature("distributeFunds(address,address)", address(0),_contract);
            emit Callback(chain_id, CONTRACT, GAS_LIMIT, payload);
        }
        
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