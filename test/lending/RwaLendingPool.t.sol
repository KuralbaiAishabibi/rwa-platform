// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {RwaLendingPool} from "../../src/lending/RwaLendingPool.sol";
import {MockERC20} from "../vault/MockERC20.sol";

contract MockPriceOracle {
    int256 public price = 1e8;

    function getPrice(address) external view returns (uint256) {
        return uint256(price);
    }

    function setPrice(int256 _price) external {
        price = _price;
    }
}

contract RwaLendingPoolTest is Test {
    RwaLendingPool pool;
    MockERC20 stable;
    MockERC20 collateralToken;
    MockPriceOracle oracle;
    address admin = makeAddr("admin");
    address user = makeAddr("user");
    address user2 = makeAddr("user2");

    function setUp() public {
        stable = new MockERC20("StableCoin", "USDC");
        collateralToken = new MockERC20("Collateral", "COLL");
        oracle = new MockPriceOracle();
        
        pool = new RwaLendingPool();
        pool.initialize(address(stable), address(oracle), admin);
        
        vm.prank(admin);
        pool.setCollateralToken(address(collateralToken), true);
        
        stable.transfer(address(pool), 100000e18);
        collateralToken.transfer(user, 1000e18);
        collateralToken.transfer(user2, 1000e18);
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
        pool.borrow(30e18);
        uint256 balBefore = stable.balanceOf(user);
        stable.approve(address(pool), 30e18);
        pool.repay(30e18);
        assertLt(stable.balanceOf(user), balBefore);
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

    function testUnpause() public {
        vm.prank(admin);
        pool.pause();
        vm.prank(admin);
        pool.unpause();
        vm.startPrank(user);
        collateralToken.approve(address(pool), 100e18);
        pool.deposit(address(collateralToken), 100e18);
        vm.stopPrank();
    }

    function testHealthFactorNoDebt() public view {
        uint256 hf = pool.healthFactor(user);
        assertEq(hf, type(uint256).max);
    }

    function testLiquidate() public {
        vm.startPrank(user);
        collateralToken.approve(address(pool), 100e18);
        pool.deposit(address(collateralToken), 100e18);
        vm.stopPrank();
        
        vm.startPrank(user);
        pool.borrow(50e18);
        vm.stopPrank();

        oracle.setPrice(0.1e8);

        vm.prank(user2);
        pool.liquidate(user, address(collateralToken));
    }
}
