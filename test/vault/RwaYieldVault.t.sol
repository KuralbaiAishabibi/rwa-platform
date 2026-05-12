// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {RwaYieldVault} from "../../src/vault/RwaYieldVault.sol";
import {MockERC20} from "./MockERC20.sol";

contract RwaYieldVaultTest is Test {
    MockERC20 asset;
    RwaYieldVault vault;
    address owner = makeAddr("owner");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    function setUp() public {
        asset = new MockERC20("Mock Stable", "MSTBL");
        vm.prank(owner);
        vault = new RwaYieldVault(asset, owner);
        asset.transfer(user1, 10000e18);
        asset.transfer(user2, 10000e18);
    }

    function testDeposit() public {
        vm.startPrank(user1);
        asset.approve(address(vault), 100e18);
        uint256 shares = vault.deposit(100e18, user1);
        assertGt(shares, 0);
        assertEq(vault.totalAssets(), 100e18);
        assertEq(vault.balanceOf(user1), shares);
    }

    function testWithdraw() public {
        vm.startPrank(user1);
        asset.approve(address(vault), 100e18);
        vault.deposit(100e18, user1);
        uint256 assets = vault.redeem(vault.balanceOf(user1), user1, user1);
        assertEq(assets, 100e18);
        assertEq(vault.totalAssets(), 0);
    }

    function testMultipleDeposits() public {
        vm.prank(user1);
        asset.approve(address(vault), 100e18);
        vm.prank(user1);
        vault.deposit(100e18, user1);
        vm.prank(user2);
        asset.approve(address(vault), 200e18);
        vm.prank(user2);
        vault.deposit(200e18, user2);
        assertEq(vault.totalAssets(), 300e18);
    }

    function testMaxDeposit() public {
        vm.prank(user1);
        asset.approve(address(vault), type(uint256).max);
        uint256 max = vault.maxDeposit(user1);
        assertGt(max, 0);
    }
}
