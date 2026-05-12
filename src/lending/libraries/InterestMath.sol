// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library InterestMath {
    function calculateLinearInterestPure(uint256 principal, uint256 ratePerSecond, uint256 duration) internal pure returns (uint256) {
        return principal + (principal * ratePerSecond * duration) / 1e18;
    }

    function calculateLinearInterestYul(uint256 principal, uint256 ratePerSecond, uint256 duration) internal pure returns (uint256 result) {
        assembly {
            let tmp := mul(principal, ratePerSecond)
            tmp := mul(tmp, duration)
            tmp := div(tmp, 1000000000000000000)
            result := add(principal, tmp)
        }
    }
}
