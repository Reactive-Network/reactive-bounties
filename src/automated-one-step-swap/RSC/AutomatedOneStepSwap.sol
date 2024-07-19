// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import '../../Interfaces/IReactive.sol';
import '../../Interfaces/ISubscriptionService.sol';


contract AutomatedOneStepSwap is IReactive {
    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint64 private constant GAS_LIMIT = 1000000;

    uint256 approval_or_transferFrom_topic_data = 0; // some topic hex for the approval or transferFrom TODO: Find the correct value

    /**
     * Indicates whether this is a ReactVM instance of the contract.
     */
    bool private vm;

    // State specific to reactive network instance of the contract
    ISubscriptionService private service;
    address private _callback;

    // State specific to ReactVM instance of the contract
            /** CUSTOM DATA TYPES GO HERE */


    // Emit some events 
    event SwapExecuted(address indexed user, uint256 orderId, uint256 amountOut);
    event EmitSomeEvent();

    constructor(address service_address, address _contract, uint256 topic_0, address callback) {
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
        _callback = callback;
    }

    modifier vmOnly() {
        require(vm, 'VM only');
        _;
    }

    modifier rnOnly() {
        require(!vm, 'Reactive Network only');
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
        emit EmitSomeEvent();

        // 1. Check for some topic condition
        if (topic_0 == approval_or_transferFrom_topic_data) {

            // 2. Perform some logic
            // TODO: perform the swap logic maybe here

            // 3. Create and send payload
            bytes memory payload = abi.encodeWithSignature("callback(address)", address(0));
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