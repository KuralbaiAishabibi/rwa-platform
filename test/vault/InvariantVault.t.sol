// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {RwaYieldVault} from "../../src/vault/RwaYieldVault.sol";
import {MockERC20} from "../vault/MockERC20.sol";

contract VaultInvariantTest is Test {
    RwaYieldVault vault;
    MockERC20 asset;

    function setUp() public {
        asset = new MockERC20("USDC", "USDC");
        vault = new RwaYieldVault(asset, address(this));
    }

    function invariant_TotalAssetsEqualsBalance() public {
        assertEq(vault.totalAssets(), asset.balanceOf(address(vault)));
    }
}
