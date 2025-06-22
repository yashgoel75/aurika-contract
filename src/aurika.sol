// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Aurika {
    struct Order {
        string date;
        string time;
        bool isBuyOrder; // true = buy, false = sell
        uint256 gram;
        uint256 avgPrice;
        string txhash;
        string ipfsPdfReceipt;
    }

    struct User {
        uint256 invested;
        uint256 grams;
        Order[] orders;
    }

    mapping(address => User) public users;

    event OrderPlaced(
        address indexed user,
        bool isBuyOrder,
        uint256 gram,
        uint256 avgPrice,
        uint256 totalPrice,
        string txhash,
        string ipfsPdfReceipt
    );

    function addOrder(
        string memory _date,
        string memory _time,
        bool _isBuyOrder,
        uint256 _gram,
        uint256 _avgPrice,
        string memory _txhash,
        string memory _ipfsPdfReceipt
    ) external payable {
        uint256 totalPrice = _gram * _avgPrice;

        Order memory newOrder = Order({
            date: _date,
            time: _time,
            isBuyOrder: _isBuyOrder,
            gram: _gram,
            avgPrice: _avgPrice,
            txhash: _txhash,
            ipfsPdfReceipt: _ipfsPdfReceipt
        });

        if (_isBuyOrder) {
            require(msg.value == totalPrice, "Incorrect ETH sent for purchase");
            users[msg.sender].invested += totalPrice;
            users[msg.sender].grams += _gram;
        } else {
            require(users[msg.sender].grams >= _gram, "Not enough grams to sell");
            users[msg.sender].invested -= totalPrice;
            users[msg.sender].grams -= _gram;

            require(address(this).balance >= totalPrice, "Contract doesn't have enough ETH");
            payable(msg.sender).transfer(totalPrice);
        }

        users[msg.sender].orders.push(newOrder);

        emit OrderPlaced(
            msg.sender,
            _isBuyOrder,
            _gram,
            _avgPrice,
            totalPrice,
            _txhash,
            _ipfsPdfReceipt
        );
    }

    function getOrders() public view returns (Order[] memory) {
        return users[msg.sender].orders;
    }

    receive() external payable {}
    fallback() external payable {}
}