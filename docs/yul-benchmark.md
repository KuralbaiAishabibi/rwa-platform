# Yul vs Solidity Gas Benchmark

## Test Setup

The benchmark compares two implementations of linear interest calculation in the InterestMath library:
- calculateLinearInterestPure written in pure Solidity
- calculateLinearInterestYul written in inline Yul assembly

## Results

| Implementation | Gas Used |
|---------------|----------|
| Pure Solidity | 647 |
| Yul Assembly | 281 |

## Analysis

The Yul implementation reduces gas consumption by approximately 56.6 percent (647 to 281 gas units). This is achieved by avoiding Solidity bounds-checking arithmetic and using direct EVM opcodes for multiplication and division.

## Conclusion

The Yul implementation is used in production for all interest calculations to minimize gas costs for users.
