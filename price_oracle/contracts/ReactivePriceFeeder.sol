// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import './interfaces/IReactive.sol';
import './interfaces/ISubscriptionService.sol';

contract ReactivePriceFeeder is IReactive {
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
    uint64 private constant GAS_LIMIT = 1000000;

    /**
     * Indicates whether this is a ReactVM instance of the contract.
     */
    bool private vm;

    // State specific to reactive network instance of the contract

    ISubscriptionService private service;
    address private _priceFeederCallback;

    // State specific to ReactVM instance of the contract

    uint256 public counter;

    constructor(address service_address, uint256 chain_id, address _contract, address callback) {
        service = ISubscriptionService(service_address);
        bytes memory payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            chain_id,
            _contract,
            keccak256("PriceFetched(address,uint256)"),
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
        }
        _priceFeederCallback = callback;
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

        (address pair, uint256 price) = abi.decode(data, (address, uint256));

        // Encode the payload for feedPriceRSC function
        bytes memory payload = abi.encodeWithSignature("feedPriceRSC(uint256,address,uint256)", chain_id, pair, price);
        emit Callback(chain_id, _priceFeederCallback, GAS_LIMIT, payload);
    }

    function resetCounter() external {
        counter = 0;
    }
}
