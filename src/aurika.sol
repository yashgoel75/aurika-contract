// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Aurika {
    struct Order {
        bool isBuyOrder;
        uint256 quantity;
        uint256 avgPrice;
    }

    struct User {
        uint256 invested;
        uint256 quantity;
        Order[] orders;
    }

    mapping(address => User) public users;

    event OrderPlaced(address indexed user, bool isBuyOrder, uint256 quantity, uint256 avgPrice, uint256 totalPrice);
    event Gifted(address indexed from, address indexed to, uint256 quantity, uint256 avgPrice, uint256 totalPrice);

    function addOrder(bool _isBuyOrder, uint256 _quantity, uint256 _avgPrice) external payable {
        require(_quantity > 0 && _avgPrice > 0, "Invalid inputs");
        uint256 totalPrice = _quantity * _avgPrice;

        Order memory newOrder = Order({
            isBuyOrder: _isBuyOrder,
            quantity: _quantity,
            avgPrice: _avgPrice
        });

        User storage user = users[msg.sender];

        if (_isBuyOrder) {
            require(msg.value == totalPrice, "Incorrect ETH sent for purchase");
            user.invested += totalPrice;
            user.quantity += _quantity;
        } else {
            require(user.quantity >= _quantity, "Not enough quantity to sell");
            user.invested -= totalPrice;
            user.quantity -= _quantity;
            payable(msg.sender).transfer(totalPrice);
        }

        user.orders.push(newOrder);

        emit OrderPlaced(msg.sender, _isBuyOrder, _quantity, _avgPrice, totalPrice);
    }

    function gift(uint256 _quantity, uint256 _avgPrice, address walletAddress) external payable {
        require(_quantity > 0 && _avgPrice > 0, "Invalid input values");

        uint256 totalPrice = _quantity * _avgPrice;
        require(msg.value == totalPrice, "Incorrect ETH sent for gift");

        users[walletAddress].invested += totalPrice;
        users[walletAddress].quantity += _quantity;

        Order memory newOrder = Order({
            isBuyOrder: true,
            quantity: _quantity,
            avgPrice: _avgPrice
        });

        users[walletAddress].orders.push(newOrder);

        emit Gifted(msg.sender, walletAddress, _quantity, _avgPrice, totalPrice);
    }

    function getOrderAt(uint256 index) public view returns (bool, uint256, uint256) {
        Order memory order = users[msg.sender].orders[index];
        return (order.isBuyOrder, order.quantity, order.avgPrice);
    }

    function getOrderCount() public view returns (uint256) {
        return users[msg.sender].orders.length;
    }

    receive() external payable {}
    fallback() external payable {}
}
