// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library getPrice {

    address constant ethUsdFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address constant xauUsdFeedAddress = 0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea;

    function getEthUsd() internal view returns (uint256) {
        AggregatorV3Interface feed = AggregatorV3Interface(ethUsdFeedAddress);
        (, int256 ethUsd,,,) = feed.latestRoundData();
        require(ethUsd > 0, "Invalid price feed");
        return uint256(ethUsd) * 1e10; // scale from 8 to 18 decimals
    }

    function getXauUsd() internal view returns (uint256) {
        AggregatorV3Interface feed = AggregatorV3Interface(xauUsdFeedAddress);
        (, int256 xauUsd,,,) = feed.latestRoundData();
        require(xauUsd > 0, "Invalid price feed");
        return uint256(xauUsd) * 1e10; // scale from 8 to 18 decimals
    }
}
