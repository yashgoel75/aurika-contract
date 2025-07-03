// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./getPrice.sol";

contract Aurika {
    struct Order {
        string orderType; // Buy/Sell/Gift
        uint256 quantity; // in micrograms (μg)
        uint256 avgPrice; // μg per ETH * 1000
    }

    struct User {
        uint256 invested; // in wei
        uint256 quantity; // in micrograms (μg)
        Order[] orders;
    }

    mapping(address => User) public users;

    event Buy(address indexed user, uint256 quantity, uint256 value);
    event Sell(address indexed user, uint256 quantity, uint256 value);
    event Gift(
        address indexed from,
        address indexed to,
        uint256 quantity,
        uint256 value
    );

    function getAveragePrice() public view returns (uint256) {
        uint256 ethUsd = getPrice.getEthUsd(); // 18 decimals
        uint256 xauUsd = getPrice.getXauUsd(); // 18 decimals
        return (ethUsd * 31103500) / xauUsd; // result in μg per ETH * 1000
    }

    function buyOrder() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 avgPrice = getAveragePrice(); // μg per ETH * 1000
        uint256 quantity = (msg.value * avgPrice) / 1e18; // μg

        User storage user = users[msg.sender];
        user.invested += msg.value;
        user.quantity += quantity;

        user.orders.push(Order("Buy", quantity, avgPrice));
        emit Buy(msg.sender, quantity, msg.value);
    }

    function sellOrder(uint256 quantity) external {
        User storage user = users[msg.sender];
        require(user.quantity >= quantity, "Insufficient gold");

        uint256 avgPrice = getAveragePrice(); // μg per ETH * 1000
        uint256 refund = (quantity * 1e18) / avgPrice;

        user.quantity -= quantity;
        if (user.invested >= refund) {
            user.invested -= refund;
        } else {
            user.invested = 0;
        }

        user.orders.push(Order("Sell", quantity, avgPrice));
        payable(msg.sender).transfer(refund);

        emit Sell(msg.sender, quantity, refund);
    }

    function gift(address recipient) external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 avgPrice = getAveragePrice();
        uint256 quantity = (msg.value * avgPrice) / 1e18;

        User storage user = users[recipient];
        user.invested += msg.value;
        user.quantity += quantity;
        user.orders.push(Order("Gift", quantity, avgPrice));

        emit Gift(msg.sender, recipient, quantity, msg.value);
    }

    function getOrderAt(
        uint256 index
    ) public view returns (string memory, uint256, uint256) {
        Order memory order = users[msg.sender].orders[index];
        return (order.orderType, order.quantity, order.avgPrice);
    }

    function getOrderCount() public view returns (uint256) {
        return users[msg.sender].orders.length;
    }
}
