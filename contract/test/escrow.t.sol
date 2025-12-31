// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Escrow.sol";

contract EscrowTest is Test {
    Escrow escrow;
    address client;
    address freelancer;
    address attacker;

    function setUp() public {
        escrow = new Escrow();
        client = makeAddr("client");
        freelancer = makeAddr("freelancer");
    }

    function testcreateEscrow() public {
        
    }
}