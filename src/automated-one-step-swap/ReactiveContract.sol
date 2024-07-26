// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
pragma abicoder v2;

import "../Interfaces/IReactive.sol";
import "../Interfaces/ISubscriptionService.sol";

contract ReactiveContract is IReactive {
    /// CONSTANTS

    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint64 private constant GAS_LIMIT = 1000000;
    uint256 constant APPROVAL_TOPIC = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

    /// STATE VARIABLES

    bool private vm;
    ISubscriptionService private service;
    address private originContract;

    /// CONSTRUCTOR

    constructor(address _service, address _originContract) {
        service = ISubscriptionService(_service);
        _subscribe(address(0), APPROVAL_TOPIC);
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
        address _contract,
        uint256, /* topic_0 */
        uint256 topic_1,
        uint256 topic_2,
        uint256, /* topic_3 */
        bytes calldata data,
        uint256, /* block_number */
        uint256 /* op_code */
    ) external vmOnly {
        address owner = address(uint160(topic_1));
        address spender = address(uint160(topic_2));
        uint256 amountIn = abi.decode(data, (uint256));

        require(spender == originContract, "Approval not for origin contract");
        require(amountIn > 0, "Approval amount must be greater than zero");

        bytes memory payload = abi.encodeWithSignature(
            "callback(address,address,address,address,uint256)",
            address(0),
            owner,
            spender,
            _contract, //tokenIn
            amountIn
        );

        emit Callback(chain_id, originContract, GAS_LIMIT, payload);
    }

    // PRIVATE FUNCTIONS

    function _subscribe(address contractAddress, uint256 topic) private {
        bytes memory payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            contractAddress,
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
