// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract GoldCalculator {
    AggregatorV3Interface private ethUsdPriceFeed;
    AggregatorV3Interface private xauUsdPriceFeed;

    constructor() {
        // Sepolia ETH/USD Price Feed
        ethUsdPriceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        // Sepolia XAU/USD Price Feed
        xauUsdPriceFeed = AggregatorV3Interface(0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea);
    }

    /**
     * @notice Calculates how many grams of gold can be bought for a given ETH amount (in wei)
     * @param ethAmount Amount of ETH in wei
     * @return gramsOfGold Number of grams of gold purchasable (with 8 decimal places of precision)
     */
    function getGoldGramsForEth(uint256 ethAmount) external view returns (uint256 gramsOfGold) {
        require(ethAmount > 0, "ETH amount must be greater than 0");

        uint256 ethPriceUsd = getLatestPrice(ethUsdPriceFeed); // 8 decimals
        uint256 xauPriceUsd = getLatestPrice(xauUsdPriceFeed); // 8 decimals

        // Convert ETH (wei) to USD (in 8 decimals)
        uint256 ethInUsd = (ethAmount * ethPriceUsd) / 1e18;

        // Calculate ounces of gold = USD / (XAU/USD price)
        // Then convert ounces to grams (1 ounce = 31.1035 grams)
        // To retain precision, multiply before dividing
        gramsOfGold = (ethInUsd * 311035) / xauPriceUsd;

        // Result has 8 decimal places due to Chainlink price feed decimals
        return gramsOfGold;
    }

    /// @notice Internal utility to fetch latest price from Chainlink feed
    function getLatestPrice(AggregatorV3Interface feed) internal view returns (uint256) {
        (, int256 price,,,) = feed.latestRoundData();
        require(price > 0, "Invalid price feed response");
        return uint256(price); // 8 decimals
    }
}
