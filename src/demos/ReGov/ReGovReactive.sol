// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

import '../../IReactive.sol';
import '../../ISubscriptionService.sol';


contract ReGovReactive is IReactive {
    event Sync(
        address indexed pair,
        uint256 indexed block_number,
        uint112 reserve0,
        uint112 reserve1
    );

    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;

    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;


    uint256 private constant REQUEST_PROPOSAL_CREATE_TOPIC_0 = 0x3199a34f29254e2f3052f39a547b89816d2e8c9f8b08c5c8ce5c60b5b6c43ca6;
    uint256 private constant REQUEST_PROPOSAL_EXECUTE_TOPIC_0 = 0x9650e8f3bcebc1b27a4b3010f07e121f3e3e3e05ea1c000e5c31d0325cc7e01e;
    uint256 private constant REQUEST_VOTE_TOPIC_0 = 0x34fb1cc9ebd331c305f8b04f4d8d05ab58f15346234d3c8e6c678d125b292cd3;
    uint256 private constant REQUEST_FUND_CONTRACT_TOPIC_0 = 0x5ba8e4f49ceeeda68c20e69e05da60c77e21f0b04b98be9422b47aa5481b8e02;

    uint64 private constant CALLBACK_GAS_LIMIT = 1000000;

    /**
     * Indicates whether this is the contract instance deployed to ReactVM.
     */
    bool private vm;

    // State specific to reactive network contract instance

    ISubscriptionService private service;

    // State specific to ReactVM contract instance

    address private l1;

    constructor(
        address service_address,
        address _l1
    ) {
        l1 = _l1;
        service = ISubscriptionService(service_address);
        bytes memory payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            0,
            REQUEST_VOTE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
        }
        payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            0,
            REQUEST_PROPOSAL_CREATE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
        }
        payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            0,
            REQUEST_FUND_CONTRACT_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
        }
        payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            0,
            REQUEST_PROPOSAL_EXECUTE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
        }
    }


    modifier rnOnly() {
        require(!vm, 'Reactive Network only');
        _;
    }

    modifier vmOnly() {
        // TODO: fix the assertion after testing.
        //require(vm, 'VM only');
        _;
    }


    // Methods specific to ReactVM contract instance

function react(
    uint256 chain_id,
    address _contract,
    uint256 topic_0,
    uint256 topic_1,
    uint256 topic_2,
    uint256 topic_3,
    bytes calldata data,
    uint256 block_number,
    uint256 /* op_code */
) external vmOnly {
    if (topic_0 == REQUEST_VOTE_TOPIC_0) {
        bool support = topic_3 > 0 ? true : false;
        bytes memory payload = abi.encodeWithSignature(
            "vote(address,address,uint256,bool)",
            address(0),
            address(uint160(topic_1)),
            topic_2,
            support
        );
        emit Callback(chain_id, l1, CALLBACK_GAS_LIMIT, payload);
    } else if (topic_0 == REQUEST_PROPOSAL_CREATE_TOPIC_0) {
        bytes memory payload = abi.encodeWithSignature(
            "createProposal(address,address,uint256,string)",
            address(0),
            address(uint160(topic_1)),
            topic_2,
            data
        );
        emit Callback(chain_id, l1, CALLBACK_GAS_LIMIT, payload);
    } else if (topic_0 == REQUEST_PROPOSAL_EXECUTE_TOPIC_0) {
        bytes memory payload = abi.encodeWithSignature(
            "executeProposal(address,uint256)",
            address(0),
            topic_1
        );
        emit Callback(chain_id, l1, CALLBACK_GAS_LIMIT, payload);
    } else if (topic_0 == REQUEST_FUND_CONTRACT_TOPIC_0) {
        bytes memory payload = abi.encodeWithSignature(
            "fundContract(address,address,uint256)",
            address(0),
            address(uint160(topic_1)),
            topic_2
        );
        emit Callback(chain_id, l1, CALLBACK_GAS_LIMIT, payload);
    }
}
}
