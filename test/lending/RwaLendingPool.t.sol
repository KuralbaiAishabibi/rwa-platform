// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {RwaLendingPool} from "../../src/lending/RwaLendingPool.sol";
import {MockERC20} from "../vault/MockERC20.sol";

contract MockPriceOracle {
    function getPrice(address) external pure returns (uint256) {
        return 1e8;
    }
}

contract RwaLendingPoolTest is Test {
    RwaLendingPool pool;
    MockERC20 stable;
    MockERC20 collateralToken;
    address admin = makeAddr("admin");
    address user = makeAddr("user");
    address liquidator = makeAddr("liquidator");

    function setUp() public {
        stable = new MockERC20("StableCoin", "USDC");
        collateralToken = new MockERC20("Collateral", "COLL");
        MockPriceOracle oracle = new MockPriceOracle();
        
        pool = new RwaLendingPool();
        pool.initialize(address(stable), address(oracle), admin);
        
        vm.prank(admin);
        pool.setCollateralToken(address(collateralToken), true);
        
        stable.transfer(address(pool), 100000e18);
        collateralToken.transfer(user, 1000e18);
        collateralToken.transfer(liquidator, 1000e18);
    }

    function testDepositCollateral() public {
        vm.startPrank(user);
        collateralToken.approve(address(pool), 100e18);
        pool.deposit(address(collateralToken), 100e18);
        vm.stopPrank();
    }

    function testDepositUnsupportedCollateral() public {
        MockERC20 unsupported = new MockERC20("Bad", "BAD");
        unsupported.transfer(user, 100e18);
        vm.startPrank(user);
        unsupported.approve(address(pool), 100e18);
        vm.expectRevert("collateral not supported");
        pool.deposit(address(unsupported), 100e18);
        vm.stopPrank();
    }

    function testBorrow() public {
        vm.startPrank(user);
        collateralToken.approve(address(pool), 100e18);
        pool.deposit(address(collateralToken), 100e18);
        pool.borrow(50e18);
        assertEq(stable.balanceOf(user), 50e18);
        vm.stopPrank();
    }

    function testRepay() public {
        vm.startPrank(user);
        collateralToken.approve(address(pool), 100e18);
        pool.deposit(address(collateralToken), 100e18);
        pool.borrow(50e18);
        stable.approve(address(pool), 50e18);
        pool.repay(50e18);
        vm.stopPrank();
    }

    function testPause() public {
        vm.prank(admin);
        pool.pause();
        vm.prank(user);
        collateralToken.approve(address(pool), 100e18);
        vm.expectRevert();
        pool.deposit(address(collateralToken), 100e18);
    }
}
