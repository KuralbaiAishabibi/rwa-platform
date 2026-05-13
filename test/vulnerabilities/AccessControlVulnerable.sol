// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AccessControlVulnerable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address newOwner) external {
        require(tx.origin == owner, "not owner");
        owner = newOwner;
    }
}
