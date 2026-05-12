// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IPriceOracle} from "../interfaces/IPriceOracle.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract ChainlinkPriceOracle is IPriceOracle {
    mapping(address => AggregatorV3Interface) public feeds;
    uint256 public constant MAX_STALENESS = 86400;
    address public admin;

    constructor(address admin_) {
        admin = admin_;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "not admin");
        _;
    }

    function setFeed(address asset, address feed) external onlyAdmin {
        feeds[asset] = AggregatorV3Interface(feed);
    }

    function getPrice(address asset) public view override returns (uint256) {
        AggregatorV3Interface feed = feeds[asset];
        require(address(feed) != address(0), "feed not set");
        (, int256 answer, , uint256 updatedAt, ) = feed.latestRoundData();
        require(block.timestamp - updatedAt <= MAX_STALENESS, "stale price");
        require(answer > 0, "negative price");
        return uint256(answer);
    }
}
