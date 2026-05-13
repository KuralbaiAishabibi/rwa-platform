// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ChainlinkPriceOracle} from "../../src/oracles/ChainlinkPriceOracle.sol";

contract MockAggregatorV3 {
    int256 price;
    uint256 updatedAt;

    constructor(int256 _price, uint256 _updatedAt) {
        price = _price;
        updatedAt = _updatedAt;
    }

    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80) {
        return (1, price, 0, updatedAt, 1);
    }
}

contract ChainlinkPriceOracleTest is Test {
    ChainlinkPriceOracle oracle;
    address admin = makeAddr("admin");
    address user = makeAddr("user");
    address asset = makeAddr("asset");

    function setUp() public {
        vm.warp(1000000);
        vm.prank(admin);
        oracle = new ChainlinkPriceOracle(admin);
    }

    function testSetFeed() public {
        vm.prank(admin);
        oracle.setFeed(asset, makeAddr("feed"));
    }

    function testSetFeedRevert() public {
        vm.prank(user);
        vm.expectRevert("not admin");
        oracle.setFeed(asset, makeAddr("feed"));
    }

    function testGetPriceRevertForUnknownAsset() public {
        vm.expectRevert("feed not set");
        oracle.getPrice(asset);
    }

    function testGetPriceSuccess() public {
        MockAggregatorV3 mock = new MockAggregatorV3(2000e8, block.timestamp);
        vm.prank(admin);
        oracle.setFeed(asset, address(mock));
        uint256 price = oracle.getPrice(asset);
        assertEq(price, 2000e8);
    }

    function testGetPriceRevertStale() public {
        MockAggregatorV3 mock = new MockAggregatorV3(2000e8, 500000);
        vm.prank(admin);
        oracle.setFeed(asset, address(mock));
        vm.expectRevert("stale price");
        oracle.getPrice(asset);
    }

    function testGetPriceRevertNegative() public {
        MockAggregatorV3 mock = new MockAggregatorV3(-1, block.timestamp);
        vm.prank(admin);
        oracle.setFeed(asset, address(mock));
        vm.expectRevert("negative price");
        oracle.getPrice(asset);
    }
}
