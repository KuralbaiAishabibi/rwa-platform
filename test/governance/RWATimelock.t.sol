// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {RWATimelock} from "../../src/governance/RWATimelock.sol";

contract RWATimelockTest is Test {
    RWATimelock timelock;
    address admin = makeAddr("admin");

    function setUp() public {
        address[] memory proposers = new address[](1);
        proposers[0] = admin;
        address[] memory executors = new address[](1);
        executors[0] = admin;
        vm.prank(admin);
        timelock = new RWATimelock(172800, proposers, executors, admin);
    }

    function testMinDelay() public view {
        assertEq(timelock.getMinDelay(), 172800);
    }

    function testTimelockDeployed() public view {
        assertGt(uint256(uint160(address(timelock))), 0);
    }
}
