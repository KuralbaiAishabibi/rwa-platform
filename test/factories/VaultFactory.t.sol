// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {VaultFactory} from "../../src/factories/VaultFactory.sol";
import {RwaYieldVault} from "../../src/vault/RwaYieldVault.sol";
import {MockERC20} from "../vault/MockERC20.sol";

contract VaultFactoryTest is Test {
    VaultFactory factory;
    MockERC20 asset;
    address owner = makeAddr("owner");

    function setUp() public {
        factory = new VaultFactory();
        asset = new MockERC20("Test", "TST");
    }

    function testCreateVault() public {
        RwaYieldVault vault = factory.createVault(asset, owner);
        assertGt(uint256(uint160(address(vault))), 0);
    }

    function testCreateVaultReturnsDifferentAddresses() public {
        RwaYieldVault v1 = factory.createVault(asset, owner);
        RwaYieldVault v2 = factory.createVault(asset, owner);
        assertTrue(address(v1) != address(v2));
    }

    function testPredictAddress() public {
        address predicted = factory.predictAddress(asset, owner, 456);
        assertGt(uint256(uint160(predicted)), 0);
    }

    function testPredictAddressDifferentSalts() public {
        address p1 = factory.predictAddress(asset, owner, 111);
        address p2 = factory.predictAddress(asset, owner, 222);
        assertTrue(p1 != p2);
    }
}
