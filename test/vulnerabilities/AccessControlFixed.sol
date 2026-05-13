// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AccessControlSafe {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address newOwner) external {
        require(msg.sender == owner, "not owner");
        owner = newOwner;
    }
}
