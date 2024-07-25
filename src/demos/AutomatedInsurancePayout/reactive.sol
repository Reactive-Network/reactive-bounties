// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import '../../IReactive.sol';
import '../../ISubscriptionService.sol';

contract Reactive is IReactive {
   

    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;
    uint256 private constant PAYOUT_TOPIC0 = 0x1fc3b2c1a44464a892fc5bdafd7f497e8037e14881fc0cfd5005cc2364a0d117;

    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;

    uint64 private constant GAS_LIMIT = 1000000;

    /**
     * Indicates whether this is a ReactVM instance of the contract.
     */
    bool private vm;

    // State specific to reactive network instance of the contract

    ISubscriptionService private service;
    address InsuranceContract;

    address USER_PAYOUT_WALLET;

    // State specific to ReactVM instance of the contract


    constructor(address service_address, address _contract,address userPayoutWallet) {

        service = ISubscriptionService(service_address);
        InsuranceContract=_contract;

        USER_PAYOUT_WALLET=userPayoutWallet;
        // user need to register their autoPayoutwallet to make automatic payout

         bytes memory payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            InsuranceContract,
            PAYOUT_TOPIC0,
            uint256(uint160(msg.sender)),
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
        }
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
        uint256 /* block_number */,
        uint256 /* op_code */
    ) external vmOnly {
        

            bytes memory payload = abi.encodeWithSignature("PayForInsurance(address,uint256,address)",address(0),topic_2 , address(uint160(topic_1)));
            emit Callback(chain_id, USER_PAYOUT_WALLET, GAS_LIMIT, payload);
        
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

// 0x4e40096020311Af7e10f670d1B996A455AC2D9E9