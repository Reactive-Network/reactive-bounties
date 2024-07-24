// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Chainlink, ChainlinkClient} from "../lib/chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import {ConfirmedOwner} from "../lib/chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {LinkTokenInterface} from "../lib/chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";


/**
 * @title PriceOracle
 * @dev This contract interacts with Chainlink oracles to fetch cryptocurrency prices.
 */
contract PriceOracle is ChainlinkClient, ConfirmedOwner {
        using Chainlink for Chainlink.Request; // Allows the contract to use Chainlink library functions for building and sending requests.

    /**
     * @dev Struct to store the details of a cross-chain price request.
     * @param rpcUrl The RPC URL of the target blockchain.
     * @param priceFeedContract The address of the price feed contract on the target blockchain.
     */
    struct ChainlinkCrossChainCoinPriceRequest {
        string rpcUrl;
        string priceFeedContract;
    }

    uint256 private requestPrice = (1 * LINK_DIVISIBILITY) / 10; // 0.1 Oracle token, amount to be paid for each request.
    address public oracle; // Address of the Chainlink Operator.
    mapping(uint => string) public requestTypeToJobID; // Mapping from request type to Chainlink node job ID.

    /**
     * @dev Event emitted when a price request for a specific coin is made.
     * @param requestId The ID of the request.
     * @param coin The symbol of the coin for which the price is requested.
     */
    event CryptocompareCoinPriceRequested(
        bytes32 indexed requestId,
        string coin
    );

    /**
     * @dev Event emitted when the price request is fulfilled.
     * @param requestId The ID of the request.
     * @param price The price of Ethereum in USD.
     * @param coin The symbol of the coin (Ethereum in this case).
     */
    event RequestCryptocompareCoinPriceFulfilled(
        bytes32 indexed requestId,
        uint256 price,
        string coin
    );

    /**
     * @dev Event emitted when a cross-chain price request is made.
     * @param requestId The ID of the request.
     */
    event CrossChainPriceRequested(
        bytes32 indexed requestId
    );

    /**
     * @dev Event emitted when the cross-chain price request is fulfilled.
     * @param requestId The ID of the request.
     * @param chain The ID of the blockchain.
     * @param price The price fetched from the blockchain.
     */
    event RequestCrossChainPriceFulfilled(
        bytes32 indexed requestId,
        uint256 chain,
        uint256 price
    );

    /**
     * @dev Event emitted when a request is canceled.
     * @param requestId The ID of the request.
     */
    event CanceledRequest(
        bytes32 indexed requestId
    );


    /**
     * @dev Modifier to charge a fee in Oracle token for requests.
     */
    modifier chargeFee() {
        LinkTokenInterface oracleToken = LinkTokenInterface(_chainlinkTokenAddress());
        require(
            oracleToken.transferFrom(msg.sender, address(this), requestPrice),
            "Unable to transfer fee"
        );
        _;
    }

    /**
     * @dev Constructor to set the Oracle token and Operator addresses.
     * @param _oracleToken Address of the Oracle token.
     * @param _oracle Address of the Chainlink Operator.
     */
    constructor(address _oracleToken, address _oracle) ConfirmedOwner(msg.sender) {
        _setChainlinkToken(_oracleToken);
        oracle = _oracle;
    }

    /**
     * @dev Sets the request price in Oracle tokens.
     * @param _requestPrice The new request price.
     */
    function setRequestPrice(uint256 _requestPrice) external onlyOwner {
        requestPrice = _requestPrice;
    }

    /**
     * @dev Sets the address of the Chainlink Operator.
     * @param _oracle The address of the new Chainlink Operator.
     */
    function setOracleAddress(address _oracle) external onlyOwner {
        require(_oracle != address(0), "Oracle address cannot be zero address");
        oracle = _oracle;
    }


    /**
     * @dev Sets the node job ID for a specific request type.
     * @param _jobId Node Job ID to set.
     * @param _requestType Request type to associate with the job ID.
     */
    function setJobIDToRequestType(string memory _jobId, uint _requestType) external onlyOwner {
        require(bytes(_jobId).length > 0, "Job ID cannot be empty");
        requestTypeToJobID[_requestType] = _jobId;
    }

    /**
     * @dev Requests the ETH price in USD from Cryptocompare.
     */
    function requestCryptocompareETHPrice() public chargeFee {
        uint requestType = 1;
        string memory jobId = requestTypeToJobID[requestType];
        require(bytes(jobId).length > 0, "Job ID not set for requestType");

        Chainlink.Request memory req = _buildChainlinkRequest(
            stringToBytes32(requestTypeToJobID[requestType]),
            address(this),
            this.fulfillCryptocompareCoinPrice.selector
        );
        req._add("coin", "ETH");
        req._add("path", "USD");
        req._addInt("times", 100);

        bytes32 requestID = _sendChainlinkRequestTo(oracle, req, requestPrice);

        emit CryptocompareCoinPriceRequested(requestID, "ETH");
    }

    /**
     * @dev Requests the price of a specified coin in USD from Cryptocompare.
     * @param _coin The coin symbol to fetch the price for (e.g., "BTC", "ETH").
     */
    function requestCryptocompareCoinPrice(string calldata _coin) public chargeFee {
        uint requestType = 1;
        string memory jobId = requestTypeToJobID[requestType];
        require(bytes(jobId).length > 0, "Job ID not set for requestType");

        Chainlink.Request memory req = _buildChainlinkRequest(
            stringToBytes32(requestTypeToJobID[requestType]),
            address(this),
            this.fulfillCryptocompareCoinPrice.selector
        );
        req._add("coin", _coin);
        req._add("path", "USD");
        req._addInt("times", 100);

        bytes32 requestID = _sendChainlinkRequestTo(oracle, req, requestPrice);

        emit CryptocompareCoinPriceRequested(requestID, _coin);
    }

    /**
     * @dev Callback function to handle the fulfillment of a price request.
     * @param _requestId The ID of the request.
     * @param _price The price of the coin in USD.
     * @param _coin The coin symbol.
     */
    function fulfillCryptocompareCoinPrice(
        bytes32 _requestId,
        uint256 _price,
        string memory _coin
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestCryptocompareCoinPriceFulfilled(_requestId, _price, _coin);
    }

    /**
     * @dev Requests cross-chain coin prices.
     * @param _request Array of ChainlinkCrossChainCoinPriceRequest structs containing RPC URLs and price feed contracts.
     */
    function requestCrossChainCoinPrice(ChainlinkCrossChainCoinPriceRequest[3] calldata _request) public chargeFee {
        uint requestType = 2;
        string memory jobId = requestTypeToJobID[requestType];
        require(bytes(jobId).length > 0, "Job ID not set for requestType");

        Chainlink.Request memory req = _buildChainlinkRequest(
            stringToBytes32(requestTypeToJobID[requestType]),
            address(this),
            this.fulfillCrossChainCoinPrice.selector
        );

        req._add("chain1RPC", _request[0].rpcUrl);
        req._add("chain1Contract", _request[0].priceFeedContract);

        req._add("chain2RPC", _request[1].rpcUrl);
        req._add("chain2Contract", _request[1].priceFeedContract);

        req._add("chain3RPC", _request[2].rpcUrl);
        req._add("chain3Contract", _request[2].priceFeedContract);

        bytes32 requestID = _sendChainlinkRequestTo(oracle, req, requestPrice);

        emit CrossChainPriceRequested(requestID);
    }

    /**
     * @dev Callback function to handle the fulfillment of cross-chain coin price requests.
     * @param _requestId The ID of the request.
     * @param _prices Array of prices from different chains.
     * @param _chains Array of chain IDs corresponding to the prices.
     */
    function fulfillCrossChainCoinPrice(
        bytes32 _requestId,
        uint256[3] calldata _prices,
        uint256[3] calldata _chains
    ) public recordChainlinkFulfillment(_requestId) {
        for (uint256 i = 0; i < _prices.length; i++) {
            emit RequestCrossChainPriceFulfilled(_requestId, _chains[i], _prices[i]);
        }
    }

    /**
     * @dev Returns the address of the Chainlink token.
     * @return The address of the Chainlink token.
     */
    function getOracleToken() public view returns (address) {
        return _chainlinkTokenAddress();
    }

    /**
     * @dev Cancels an outstanding Chainlink request.
     * @param _requestId The ID of the request to cancel.
     * @param _payment The payment amount for the request.
     * @param _callbackFunctionId The callback function ID.
     * @param _expiration The expiration time of the request.
     */
    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunctionId,
        uint256 _expiration
    ) public onlyOwner {
        _cancelChainlinkRequest(
            _requestId,
            _payment,
            _callbackFunctionId,
            _expiration
        );
        emit CanceledRequest(_requestId);
    }

    /**
     * @dev Converts a string to bytes32.
     * @param source The string to convert.
     * @return result The bytes32 representation of the string.
     */
    function stringToBytes32(
        string memory source
    ) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}
