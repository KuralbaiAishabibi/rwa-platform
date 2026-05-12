// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {InterestMath} from "../../src/lending/libraries/InterestMath.sol";

contract InterestMathTest is Test {
    function testSolidityVersion() public {
        uint256 result = InterestMath.calculateLinearInterestPure(1000e18, 1e16, 365 days);
        assertGt(result, 1000e18);
    }

    function testYulVersion() public {
        uint256 result = InterestMath.calculateLinearInterestYul(1000e18, 1e16, 365 days);
        assertGt(result, 1000e18);
    }

    function testFuzz_EquivalentResults(uint256 principal, uint256 rate, uint256 duration) public {
        principal = bound(principal, 1e18, 1000000e18);
        rate = bound(rate, 1, 1e18);
        duration = bound(duration, 1, 365 days);
        uint256 solidityResult = InterestMath.calculateLinearInterestPure(principal, rate, duration);
        uint256 yulResult = InterestMath.calculateLinearInterestYul(principal, rate, duration);
        assertEq(solidityResult, yulResult, "Yul and Solidity differ");
    }

    function testFuzz_PrincipalPreserved(uint256 principal, uint256 rate, uint256 duration) public {
        principal = bound(principal, 1e18, 1000000e18);
        rate = bound(rate, 1, 1e18);
        duration = bound(duration, 1, 365 days);
        uint256 result = InterestMath.calculateLinearInterestYul(principal, rate, duration);
        assertGe(result, principal, "result less than principal");
    }
}
