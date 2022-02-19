// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Permission.sol";

contract FeeController is Permission {
    uint256 _fee = 1 ether / 100; //0.01$
    uint256 _percentFee = 5;

    modifier payFee() {
        require(msg.value >= _fee, "Fee is to low");
        payable(address(this)).transfer(msg.value);
        _;
    }

    constructor() {}

    function setFee(uint256 newFee) public isAdmin {
        _fee = newFee;
    }

    function setFeePercent(uint256 newFeePercent) public isAdmin {
        _percentFee = newFeePercent;
    }

    function getFees() public payable isAdmin {
        payable(address(msg.sender)).transfer(this.getFeesBalance());
    }

    function getFeesBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
