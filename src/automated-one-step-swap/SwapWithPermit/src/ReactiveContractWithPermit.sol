// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
pragma abicoder v2;

import "../../../Interfaces/IReactive.sol";
import "../../../Interfaces/ISubscriptionService.sol";

contract ReactiveContract is IReactive {
    /// CONSTANTS

    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint64 private constant GAS_LIMIT = 1000000;
    uint256 constant TOPIC_0 = 0x79c488d5c1f559341a4ff5f993e3ec18efc5c3c90595752c9d89d50fae65c4d2; // Topic of the SwapApproved event

    /// STATE VARIABLES

    bool private vm;
    ISubscriptionService private service;
    address private originContract;

    /// CONSTRUCTOR

    constructor(address _service, address _originContract) {
        service = ISubscriptionService(_service);
        _subscribe(_originContract, TOPIC_0);
        originContract = _originContract;
    }

    /// MODIFIERS

    modifier vmOnly() {
        // TODO: fix the assertion after testing.
        //require(vm, 'VM only');
        _;
    }

    /// EXTERNAL FUNCTIONS

    function react(
        uint256 chain_id,
        address _contract, // TODO: add checks with these parameters
        uint256 topic_0,
        uint256 topic_1,
        uint256 topic_2,
        uint256 topic_3,
        bytes calldata data,
        uint256, /* block_number */
        uint256 /* op_code */
    ) external vmOnly {
        (uint256 amountIn, uint256 amountOutMin, uint24 fee) = abi.decode(data, (uint256, uint256, uint24));

        bytes memory payload = abi.encodeWithSignature(
            "callback(address,address,address,address,uint256,uint256,uint24)",
            address(0),
            address(uint160(topic_1)),
            address(uint160(topic_2)),
            address(uint160(topic_3)),
            amountIn,
            amountOutMin,
            fee
        );

        emit Callback(chain_id, originContract, GAS_LIMIT, payload);
    }

    // PRIVATE FUNCTIONS

    function _subscribe(address _originContract, uint256 topic) private {
        bytes memory payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            _originContract,
            topic,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
        }
    }

    /// Methods for testing environment only

    function subscribe(address _contract, uint256 topic_0) external {
        service.subscribe(SEPOLIA_CHAIN_ID, _contract, topic_0, REACTIVE_IGNORE, REACTIVE_IGNORE, REACTIVE_IGNORE);
    }

    function unsubscribe(address _contract, uint256 topic_0) external {
        service.unsubscribe(SEPOLIA_CHAIN_ID, _contract, topic_0, REACTIVE_IGNORE, REACTIVE_IGNORE, REACTIVE_IGNORE);
    }
}

// CURRENT: 0x2A91a9717ef9A4bA87d76Fb3E4Cb33BbF9C3d25a
