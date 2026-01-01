// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {Escrow} from "../src/Escrow.sol";

contract EscrowScript is Script {
    function run() public {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);

        Escrow escrow = new Escrow();

        vm.stopBroadcast();
    }
}
