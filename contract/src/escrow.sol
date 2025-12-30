// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract escrow {
    address public sender;

    mapping(address => uint256) public payer;
    constructor(){
        sender = msg.sender;
    }

    modifier onlySender(){
        require(msg.sender == sender , "you are not the sender");
        _;
    }

    function deposit(address reciever) public payable onlySender {
        payer[reciever] = payer[reciever] + msg.value;
    }

    function withdrawal(address payable reciever) public onlySender {
        
    }

}