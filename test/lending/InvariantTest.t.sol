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

contract LendingInvariantTest is Test {
    RwaLendingPool pool;
    MockERC20 stable;
    MockERC20 collateral;

    function setUp() public {
        stable = new MockERC20("USDC", "USDC");
        collateral = new MockERC20("COLL", "COLL");
        MockPriceOracle oracle = new MockPriceOracle();
        pool = new RwaLendingPool();
        pool.initialize(address(stable), address(oracle), address(this));
        pool.setCollateralToken(address(collateral), true);
    }

    function invariant_StableBalanceNotNegative() public {
        uint256 balance = stable.balanceOf(address(pool));
        assertGe(balance, 0);
    }
}
