// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

import '../../IReactive.sol';
import '../../ISubscriptionService.sol';
import "@openzeppelin/contracts/access/Ownable.sol";



contract ReGovReactive is IReactive, Ownable {
    event Subscribed(
        address indexed service_address,
        address indexed _contract,
        uint256 indexed topic_0
    );
    event VM();

    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;

    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;


    uint256 private constant REQUEST_PROPOSAL_CREATE_TOPIC_0 = 0xe647f9c40f113518b40273f67af29fe3bae0e7f7581a87b42ec9ef84989306b6;
    uint256 private constant REQUEST_PROPOSAL_EXECUTE_TOPIC_0 = 0xae64303d6f1b5137f8b05757269e5af8ff7ea2ef7c733f3e3adf553d974060e8;
    uint256 private constant REQUEST_VOTE_TOPIC_0 = 0xb703f403fb13707ed08878590d45680ceb08bba172ab33f5f46ca40f000ee1de;
    uint256 private constant REQUEST_FUND_CONTRACT_TOPIC_0 = 0xf5a4d15b2e66768f5633794bc3d0727dfe77f80a11b57947ae0f3d79a23802d1;

    uint64 private constant CALLBACK_GAS_LIMIT = 1000000;

    /**
     * Indicates whether this is the contract instance deployed to ReactVM.
     */
    bool private vm;

    // State specific to reactive network contract instance

    ISubscriptionService private service;

    // State specific to ReactVM contract instance

    address private l1;
    address private emitterContract;
    bool private paused;

    constructor(
        address service_address,
        address _l1,
        address _emitterContract
    ) Ownable(msg.sender) {
        l1 = _l1;
        emitterContract = _emitterContract;
        service = ISubscriptionService(service_address);
        bytes memory payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            emitterContract,
            REQUEST_VOTE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
            emit VM();
        } else {
            emit Subscribed(service_address, emitterContract, REQUEST_VOTE_TOPIC_0);
        }
        payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            emitterContract,
            REQUEST_PROPOSAL_CREATE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
            emit VM();
        } else {
            emit Subscribed(service_address, emitterContract, REQUEST_PROPOSAL_CREATE_TOPIC_0);
        }
        payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            emitterContract,
            REQUEST_FUND_CONTRACT_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
            emit VM();
        } else {
            emit Subscribed(service_address, emitterContract, REQUEST_FUND_CONTRACT_TOPIC_0);
        }
        payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            emitterContract,
            REQUEST_PROPOSAL_EXECUTE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
            emit VM();
        } else {
            emit Subscribed(service_address, emitterContract, REQUEST_PROPOSAL_EXECUTE_TOPIC_0);
        }
    }

        // Methods specific to reactive network contract instance

    function pause() external rnOnly onlyOwner {
        require(!paused, 'Already paused');
        service.unsubscribe(
            SEPOLIA_CHAIN_ID,
            emitterContract,
            REQUEST_VOTE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        service.unsubscribe(
            SEPOLIA_CHAIN_ID,
            emitterContract,
            REQUEST_PROPOSAL_CREATE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        service.unsubscribe(
            SEPOLIA_CHAIN_ID,
            emitterContract,
            REQUEST_PROPOSAL_EXECUTE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        service.unsubscribe(
            SEPOLIA_CHAIN_ID,
            emitterContract,
            REQUEST_FUND_CONTRACT_TOPIC_0,
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
            emitterContract,
            REQUEST_VOTE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        service.subscribe(
            SEPOLIA_CHAIN_ID,
            emitterContract,
            REQUEST_PROPOSAL_CREATE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        service.subscribe(
            SEPOLIA_CHAIN_ID,
            emitterContract,
            REQUEST_PROPOSAL_EXECUTE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        service.subscribe(
            SEPOLIA_CHAIN_ID,
            emitterContract,
            REQUEST_FUND_CONTRACT_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        paused = false;
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

    function decodeLog(bytes calldata data) public pure returns (address proposer, uint256 grantAmount, string memory description) {
        (proposer, grantAmount, description) = abi.decode(data, (address, uint256, string));
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
        (address proposer, uint256 proposalId, bool support) = abi.decode(data, (address, uint256, bool));
        bytes memory payload = abi.encodeWithSignature(
            "vote(address,address,uint256,bool)",
            address(0),
            proposer,
            proposalId,
            support
        );
        emit Callback(chain_id, l1, CALLBACK_GAS_LIMIT, payload);
    } else if (topic_0 == REQUEST_PROPOSAL_CREATE_TOPIC_0) {
        // Decode the dynamic string parameter
        (address proposer, uint256 grantAmount, string memory description) = abi.decode(data, (address, uint256, string));
        // require(false, description);
        bytes memory payload = abi.encodeWithSignature(
            "createProposal(address,address,uint256,string)",
            address(0),
            proposer,
            grantAmount,
            description
        );
        emit Callback(chain_id, l1, CALLBACK_GAS_LIMIT, payload);
    } else if (topic_0 == REQUEST_PROPOSAL_EXECUTE_TOPIC_0) {
        (uint256 proposalId) = abi.decode(data, (uint256));
        bytes memory payload = abi.encodeWithSignature(
            "executeProposal(address,uint256)",
            address(0),
            proposalId
        );
        emit Callback(chain_id, l1, CALLBACK_GAS_LIMIT, payload);
    } else if (topic_0 == REQUEST_FUND_CONTRACT_TOPIC_0) {
        (address funder, uint256 amount) = abi.decode(data, (address, uint256));
        bytes memory payload = abi.encodeWithSignature(
            "fundContract(address,address,uint256)",
            address(0),
            funder,
            amount
        );
        emit Callback(chain_id, l1, CALLBACK_GAS_LIMIT, payload);
    }
}
}
