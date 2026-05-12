// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AssetToken} from "../../src/tokens/AssetToken.sol";

contract AssetTokenTest is Test {
    AssetToken token;
    address admin = makeAddr("admin");
    address issuer = makeAddr("issuer");
    address user = makeAddr("user");
    bytes32 constant ISSUER_ROLE = keccak256("ISSUER_ROLE");

    function setUp() public {
        token = new AssetToken("Asset Token", "ATK", admin);
        vm.prank(admin);
        token.grantRole(ISSUER_ROLE, issuer);
    }

    function testMintByIssuer() public {
        vm.prank(issuer);
        token.mint(user, 1e18);
        assertEq(token.balanceOf(user), 1e18);
    }

    function testRevertMintByNonIssuer() public {
        vm.prank(user);
        vm.expectRevert();
        token.mint(user, 1e18);
    }

    function testBurn() public {
        vm.prank(issuer);
        token.mint(user, 1e18);
        vm.prank(user);
        token.burn(0.5e18);
        assertEq(token.balanceOf(user), 0.5e18);
    }

    function testTransfer() public {
        vm.prank(issuer);
        token.mint(user, 100e18);
        vm.prank(user);
        token.transfer(admin, 40e18);
        assertEq(token.balanceOf(admin), 40e18);
        assertEq(token.balanceOf(user), 60e18);
    }

    function testTotalSupply() public {
        vm.prank(issuer);
        token.mint(user, 500e18);
        vm.prank(issuer);
        token.mint(admin, 500e18);
        assertEq(token.totalSupply(), 1000e18);
    }

    function testGrantIssuerRole() public {
        address newIssuer = makeAddr("newIssuer");
        vm.prank(admin);
        token.grantRole(ISSUER_ROLE, newIssuer);
        assertTrue(token.hasRole(ISSUER_ROLE, newIssuer));
    }
}
