// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

contract ForkTest is Test {
    function testForkEthBlockNumber() public {
        string memory rpcUrl = vm.envOr("ETH_RPC_URL", string(""));
        if (bytes(rpcUrl).length == 0) {
            return;
        }
        uint256 forkId = vm.createFork(rpcUrl);
        vm.selectFork(forkId);
        assertGt(block.number, 0);
    }

    function testForkChainlinkPrice() public {
        string memory rpcUrl = vm.envOr("ETH_RPC_URL", string(""));
        if (bytes(rpcUrl).length == 0) {
            return;
        }
        uint256 forkId = vm.createFork(rpcUrl);
        vm.selectFork(forkId);
        address ethUsdFeed = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
        (, int256 price, , , ) = AggregatorV3Interface(ethUsdFeed).latestRoundData();
        assertGt(price, 0);
    }
}

interface AggregatorV3Interface {
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
}
