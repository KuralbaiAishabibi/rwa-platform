// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AssetCertificate} from "../../src/tokens/AssetCertificate.sol";

contract AssetCertificateTest is Test {
    AssetCertificate cert;
    address admin = makeAddr("admin");
    address issuer = makeAddr("issuer");
    address user = makeAddr("user");
    bytes32 constant ISSUER_ROLE = keccak256("ISSUER_ROLE");

    function setUp() public {
        cert = new AssetCertificate(admin);
        vm.prank(admin);
        cert.grantRole(ISSUER_ROLE, issuer);
    }

    function testSafeMint() public {
        vm.prank(issuer);
        uint256 tokenId = cert.safeMint(user);
        assertEq(cert.ownerOf(tokenId), user);
    }

    function testRevertMintByNonIssuer() public {
        vm.prank(user);
        vm.expectRevert();
        cert.safeMint(user);
    }

    function testTokenIdIncrements() public {
        vm.startPrank(issuer);
        uint256 id1 = cert.safeMint(user);
        uint256 id2 = cert.safeMint(admin);
        vm.stopPrank();
        assertEq(id1, 0);
        assertEq(id2, 1);
    }

    function testBalanceOf() public {
        vm.prank(issuer);
        cert.safeMint(user);
        assertEq(cert.balanceOf(user), 1);
    }
}
