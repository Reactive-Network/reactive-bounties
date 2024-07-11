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


    uint256 private constant REQUEST_PROPOSAL_CREATE_TOPIC_0 = 0xb605297f31a6d20fd1daf224402b81de1a5b7128be27c5f891e29757ac8e24fb;
    uint256 private constant REQUEST_PROPOSAL_EXECUTE_TOPIC_0 = 0xcfc536199fed6fc9a1800da06eff07bc51565c5b442f83cd2d96344089bb07e4;
    uint256 private constant REQUEST_VOTE_TOPIC_0 = 0x8131eb889128114273bfedf30bfe5aad1a8f3bbef5d40f786c44000e3361ed0a;
    uint256 private constant REQUEST_FUND_CONTRACT_TOPIC_0 = 0xcffd2dfa796a5228c2b23ade7c7ad9dc8c4235795e0c7aa43c3a43e7e945fbc4;

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
