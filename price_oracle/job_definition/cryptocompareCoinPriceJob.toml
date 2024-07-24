type = "directrequest"
schemaVersion = 1
name = "Get > Uint256 - Using Dynamic URL"
forwardingAllowed = false
maxTaskDuration = "0s"
contractAddress = "0x0E9F7697bdd7D16268De7a882A377A0aFEC50Cff"
evmChainID = "11155111"
minIncomingConfirmations = 0
minContractPaymentLinkJuels = "0"
observationSource = """
    decode_log   [type="ethabidecodelog"
                  abi="OracleRequest(bytes32 indexed specId, address requester, bytes32 requestId, uint256 payment, address callbackAddr, bytes4 callbackFunctionId, uint256 cancelExpiration, uint256 dataVersion, bytes data)"
                  data="$(jobRun.logData)"
                  topics="$(jobRun.logTopics)"]

    decode_cbor  [type="cborparse" data="$(decode_log.data)"]

    fetch [type="bridge" name="log_bridge"
                requestData="{ \\"coin\\": $(decode_cbor.coin), \\"path\\": $(decode_cbor.path), \\"times\\": $(decode_cbor.times) }"]

    parse        [type="jsonparse" path="USD" data="$(fetch)"]

    multiply     [type="multiply" input="$(parse)" times="100"]

    encode_data  [type="ethabiencode" abi="(bytes32 requestId, uint256 value, string memory coin)" data="{ \\"requestId\\": $(decode_log.requestId), \\"value\\": $(multiply), \\"coin\\": $(decode_cbor.coin) }"]

    encode_tx    [type="ethabiencode"
                  abi="fulfillOracleRequest2(bytes32 requestId, uint256 payment, address callbackAddress, bytes4 callbackFunctionId, uint256 expiration, bytes calldata data)"
                  data="{\\"requestId\\": $(decode_log.requestId), \\"payment\\":   $(decode_log.payment), \\"callbackAddress\\": $(decode_log.callbackAddr), \\"callbackFunctionId\\": $(decode_log.callbackFunctionId), \\"expiration\\": $(decode_log.cancelExpiration), \\"data\\": $(encode_data)}"]

    submit_tx    [type="ethtx" to="0x0E9F7697bdd7D16268De7a882A377A0aFEC50Cff" data="$(encode_tx)"]

    decode_log -> fetch -> parse -> multiply -> encode_data -> encode_tx -> submit_tx
"""