// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {GovernanceToken} from "../../src/tokens/GovernanceToken.sol";

contract GovernanceTokenTest is Test {
    GovernanceToken public token;
    address public owner = makeAddr("owner");
    address public user = makeAddr("user");
    uint256 constant INITIAL_SUPPLY = 1_000_000e18;

    function setUp() public {
        vm.prank(owner);
        token = new GovernanceToken(owner, INITIAL_SUPPLY);
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function testDelegation() public {
        vm.prank(owner);
        token.delegate(owner);
        assertEq(token.getVotes(owner), INITIAL_SUPPLY);
    }

    function testTransferUpdatesVotingPower() public {
        vm.startPrank(owner);
        token.delegate(owner);
        uint256 amount = 1000e18;
        token.transfer(user, amount);
        vm.stopPrank();
        assertEq(token.getVotes(owner), INITIAL_SUPPLY - amount);
    }

    function testFuzzDelegation(uint256 amount) public {
        amount = bound(amount, 1, INITIAL_SUPPLY);
        vm.prank(owner);
        token.transfer(user, amount);
        vm.prank(user);
        token.delegate(user);
        assertEq(token.getVotes(user), amount);
    }
}
