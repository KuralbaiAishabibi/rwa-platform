// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AccessControlVulnerable} from "./AccessControlVulnerable.sol";
import {AccessControlSafe} from "./AccessControlFixed.sol";

contract AccessControlAttackTest is Test {
    AccessControlVulnerable vulnerable;
    AccessControlSafe safe;
    address alice = makeAddr("alice");
    address eve = makeAddr("eve");

    function setUp() public {
        vm.prank(alice);
        vulnerable = new AccessControlVulnerable();
        vm.prank(alice);
        safe = new AccessControlSafe();
    }

    function testVulnerableTxOriginAttack() public {
        assertEq(vulnerable.owner(), alice);
        vm.prank(eve);
        vm.expectRevert("not owner");
        vulnerable.changeOwner(eve);
    }

    function testSafeAccessControlBlocked() public {
        vm.prank(eve);
        vm.expectRevert("not owner");
        safe.changeOwner(eve);
        assertEq(safe.owner(), alice);
    }
}
