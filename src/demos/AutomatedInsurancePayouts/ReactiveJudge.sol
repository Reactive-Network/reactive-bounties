// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../../IReactive.sol';
import '../../ISubscriptionService.sol';

contract ReactiveJudge is IReactive {
    event Event(
        uint256 indexed chain_id,
        address indexed _contract,
        uint256 indexed topic_0,
        uint256 topic_1,
        uint256 topic_2,
        uint256 topic_3,
        bytes data,
        uint256 counter
    );

    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint64 private constant GAS_LIMIT = 1000000;

    /**
     * Indicates whether this is a ReactVM instance of the contract.
     */
    bool private vm;

    // State specific to reactive network instance of the contract
    ISubscriptionService private service;
    address private _callback;

    // State specific to ReactVM instance of the contract
    uint256 public counter;

    // State specific variables for insurance payouts
    address public policyholderAddress;
    address public senderAddress;
    uint256 public payoutAmount;

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
        emit Event(chain_id, _contract, topic_0, topic_1, topic_2, topic_3, data, ++counter);
        
        // Arguments for payout() function in Callback Contract
        policyholderAddress = 0x2b32CE6f546a8a3E852DD9356f9f556D17DBd179;
        senderAddress = address(uint160(topic_1));
        payoutAmount = topic_2 / 2;

        // In case of incident make payload based on event topics
        // and cast callback to payout() function of GenerousVault
        if (senderAddress != policyholderAddress) {
            bytes memory payload = abi.encodeWithSignature("payout(address,address,uint256)", address(0), policyholderAddress, payoutAmount);
            emit Callback(chain_id, _callback, GAS_LIMIT, payload); // Emit callback to the GenerousVault
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

    function resetCounter() external {
        counter = 0;
    }
}
