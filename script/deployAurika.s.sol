//SPDX-License-Identifier:MIT

pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import {Aurika} from "../src/aurika.sol";

contract deployAurika is Script {
    function run() public returns(Aurika) {
        vm.startBroadcast();
        Aurika aurika = new Aurika();
        vm.stopBroadcast();
        return aurika;
    }
}