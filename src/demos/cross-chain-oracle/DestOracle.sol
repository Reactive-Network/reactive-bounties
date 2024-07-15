// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract DestOracle {
    address private callback_sender;
    uint256 public data;
    event DataUpdated(uint256 indexed newData);

    constructor(address _callback_sender) {
      callback_sender = _callback_sender;
    }

    modifier onlyReactive() {
        if (callback_sender != address(0)) {
            require(msg.sender == callback_sender, 'Unauthorized');
        }
        _;
    }

    function updateData(uint256 _data) public onlyReactive {
        data = _data;
        emit DataUpdated(_data);
    }

    function getData() public view returns (uint256) {
        return data;
    }
}
