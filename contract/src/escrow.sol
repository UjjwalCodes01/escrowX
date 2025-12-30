// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract escrow {
    address public sender;

    mapping(address => uint256) public payer;
    constructor(){
        sender = msg.sender;
    }
    event amountDeposit(address to , uint256 amount);
    event amountWithdrawal(address from , uint256 amount);
    modifier onlySender(){
        require(msg.sender == sender , "you are not the sender");
        _;
    }

    function deposit(address reciever) public payable onlySender {
        uint256 value = msg.value;
        payer[reciever] = payer[reciever] + value;
        emit amountDeposit(reciever, value);
    }

    function withdrawal(address payable reciever) public onlySender {
        uint amount = payer[reciever];
        payer[reciever] =0;
       (bool success ,)  = reciever.call{
            value : amount
        }("");
        require(success , "transfer failed");
        emit amountWithdrawal(reciever, amount);
    }


}