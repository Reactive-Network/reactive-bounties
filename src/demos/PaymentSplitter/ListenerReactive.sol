// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import 'IReactive.sol';
import './ISubscriptionService.sol';

contract ListenerReactive is IReactive {
    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;

    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 private constant REACTIVE_CHAIN_ID = 0x512578;

    uint256 private constant DISTRIBUTION_TOPIC_0 = 0xcff5d694e6a309557fa48081000c42ece1f65fba8fbfdefdefc4e6c7108d55b1;

    uint64 private constant CALLBACK_GAS_LIMIT = 1000000;

    /**
     * Indicates whether this is the contract instance deployed to ReactVM.
     */
    bool private vm;

    // State specific to reactive network contract instance

    address private owner;
    bool private paused;
    ISubscriptionService private service;

    // State specific to ReactVM contract instance

    address private l1;

    constructor(
        address service_address,
        address _l1
        ) {
        owner = msg.sender;
        paused = false;
        l1 = _l1;
        service = ISubscriptionService(service_address);
        bytes memory payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            l1,
            DISTRIBUTION_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Unauthorized');
        _;
    }

    modifier rnOnly() {
        require(!vm, 'Reactive Network only');
        _;
    }

    modifier vmOnly() {
        // require(vm, 'VM only');
        _;
    }

    // Methods specific to reactive network contract instance

    function pause() external rnOnly onlyOwner {
        require(!paused, 'Already paused');
        service.unsubscribe(
            SEPOLIA_CHAIN_ID,
            l1,
            DISTRIBUTION_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        paused = true;
    }

    function resume() external rnOnly onlyOwner {
        require(paused, 'Not paused');
        service.subscribe(
            SEPOLIA_CHAIN_ID,
            l1,
            DISTRIBUTION_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        paused = false;
    }

    // Methods specific to ReactVM contract instance

    function react(
        uint256  /* chain_id */,
        address /* _contract */,
        uint256 /* topic_0 */,
        uint256 _topic1 /* topic_1 */,
        uint256 /* topic_2 */,
        uint256 /* topic_3 */,
        bytes calldata /* data */,
        uint256 /* block_number */,
        uint256 /* op_code */
    ) external vmOnly {


        bytes memory payload = abi.encodeWithSignature(
            "dispense(uint256)",
            _topic1
        );
        emit Callback(SEPOLIA_CHAIN_ID, l1, CALLBACK_GAS_LIMIT, payload);
    }
}