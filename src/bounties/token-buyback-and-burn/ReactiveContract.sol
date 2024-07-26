// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

import '../../IReactive.sol';
import '../../ISubscriptionService.sol';

struct Reserves {
    uint112 reserve0;
    uint112 reserve1;
}

contract ReactiveContract is IReactive {
    event Subscribed(
        address indexed service_address,
        address indexed _contract,
        uint256 indexed topic_0
    );

    event VM();

    event AboveThreshold(
        uint112 indexed reserve0,
        uint112 indexed reserve1,
        uint256 coefficient,
        uint256 threshold
    );

    event CallbackSent();

    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;

    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;

    uint256 private constant UNISWAP_V2_SYNC_TOPIC_0 = 0x1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1;

    uint64 private constant CALLBACK_GAS_LIMIT = 1000000;

    /**
     * Indicates whether this is the instance of the contract deployed to ReactVM.
     */
    bool private vm;

    // State specific to ReactVM instance of the contract.

    address private pair;
    address private treasury_contract;
    address private client;
    bool private direction;
    uint256 private coefficient;
    uint256 private threshold;

    constructor(
        address service_address,
        address _pair,
        address _treasury_contract,
        address _client,
        bool _direction,
        uint256 _coefficient,
        uint256 _threshold
    ) {
        ISubscriptionService service = ISubscriptionService(service_address);
        pair = _pair;
        bytes memory payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            pair,
            UNISWAP_V2_SYNC_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
            emit VM();
        } else {
            emit Subscribed(service_address, pair, UNISWAP_V2_SYNC_TOPIC_0);
        }
        treasury_contract = _treasury_contract;
        client = _client;
        direction = _direction;
        coefficient = _coefficient;
        threshold = _threshold;
    }

    modifier vmOnly() {
        // TODO: fix the assertion after testing.
        //require(vm, 'VM only');
        _;
    }

    // Methods specific to ReactVM instance of the contract.

    function react(
        uint256 chain_id,
        address _contract,
        uint256 /* topic_0 */,
        uint256 /* topic_1 */,
        uint256 /* topic_2 */,
        uint256 /* topic_3 */,
        bytes calldata data,
        uint256 /* block_number */,
        uint256 /* op_code */
    ) external vmOnly {
        if (_contract == pair) {
            Reserves memory sync = abi.decode(data, ( Reserves ));
            if (below_threshold(sync)) {
                emit CallbackSent();
                bytes memory payload = abi.encodeWithSignature(
                    "buybackAndBurn(address,address,address,bool,uint256,uint256)",
                    address(0),
                    pair,
                    client,
                    direction,
                    coefficient,
                    threshold
                );
                emit Callback(chain_id, treasury_contract, CALLBACK_GAS_LIMIT, payload);
            }
        }
    }

    function below_threshold(Reserves memory sync) internal view returns (bool) {
        if (direction) {
            return (sync.reserve1 * coefficient) / sync.reserve0 <= threshold;
        } else {
            return (sync.reserve0 * coefficient) / sync.reserve1 <= threshold;
        }
    }
}
