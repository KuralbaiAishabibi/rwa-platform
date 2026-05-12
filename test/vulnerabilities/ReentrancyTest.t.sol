// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ReentrancyVulnerable} from "./ReentrancyVulnerable.sol";
import {Attacker} from "./Attacker.sol";

contract ReentrancyTest is Test {
    ReentrancyVulnerable victim;
    Attacker attacker;

    function setUp() public {
        victim = new ReentrancyVulnerable();
        vm.deal(address(victim), 10 ether);
        attacker = new Attacker(address(victim));
    }

    function testReentrancyAttack() public {
        vm.deal(address(attacker), 1 ether);
        uint256 balanceBefore = address(attacker).balance;
        attacker.attack{value: 1 ether}();
        uint256 balanceAfter = address(attacker).balance;
        assertGt(balanceAfter, balanceBefore + 1 ether, "Reentrancy attack failed");
    }
}
