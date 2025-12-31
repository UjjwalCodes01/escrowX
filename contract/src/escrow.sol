// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    
    uint256 public escrowCount;
    mapping(uint256 => escrow) public getEscrow;

    enum State{
        created ,
        funded,
        submitted,
        approved ,
        cancelled,
        finished
    }

    struct escrow{
        address client;
        address freelancer;
        uint256 fund;
        State status;
    }



    function createEscrow(address freelancer) public {
        escrowCount++;

        getEscrow[escrowCount] = escrow({
            client : msg.sender,
            freelancer : freelancer,
            fund : 0,
            status : State.created
        });
    }

    

    event amountDeposited(address into , uint256 amount);
    event amountWithdrawaled(address from , uint256 amount);
    event workSubmitted(address by , address Of);
    event freelancerHired(address by , address freelancer);
    event failed(address by);
    event revertedmoney(address on , uint256 amount);

    function workSubmission(uint id) public {
        require(getEscrow[id].client != address(0), "invalid escrow id");
        require(getEscrow[id].status == State.funded , "you are not hired");
        require(msg.sender == getEscrow[id].freelancer , "you are not freelancer");
        getEscrow[id].status = State.submitted;
        emit workSubmitted(getEscrow[id].freelancer, getEscrow[id].client);
    }

    function clientApproved(uint id) public {
        require(getEscrow[id].client != address(0), "invalid escrow id");
        require(getEscrow[id].status == State.submitted , "work is pending");
        require(msg.sender == getEscrow[id].client , "you are not client");
        getEscrow[id].status = State.approved;
        emit workSubmitted(getEscrow[id].freelancer , getEscrow[id].client);
    }

   
    
    function deposit (uint id) public payable{
        require(getEscrow[id].client != address(0), "invalid escrow id");
        require(getEscrow[id].status == State.hired , "freelancer are not approved by client");
        require(msg.sender == getEscrow[id].client , "you are not client");
        uint256 value = msg.value;
        require(value > 0, "value must be greater than 0 eth");
        getEscrow[id].fund = getEscrow[id].fund + value;
        getEscrow[id].status = State.funded;
        emit amountDeposited(getEscrow[id].freelancer, value);
    }

    function withdrawal( uint id) public {
        require(getEscrow[id].client != address(0), "invalid escrow id");
        require(getEscrow[id].status == State.approved , "work is not approved or in pending");
        require(msg.sender == getEscrow[id].freelancer , "you are not client");
        uint amount = getEscrow[id].fund;
        getEscrow[id].fund = 0;
       (bool success ,)  = getEscrow[id].freelancer.call{
            value : amount
        }("");
        require(success , "transfer failed");
        getEscrow[id].status = State.finished;
        emit amountWithdrawaled(getEscrow[id].freelancer, amount);
    }

    function ifFailed(uint256 id) public {
        require(getEscrow[id].client != address(0), "invalid escrow id");
        require(msg.sender == getEscrow[id].client , "you are not client");
        require(getEscrow[id].status == State.funded, "not funded");
        getEscrow[id].status = State.cancelled;
        emit failed(getEscrow[id].client);
    }

    function revertMoney( uint256 id) public payable {
        require(getEscrow[id].client != address(0), "invalid escrow id");
        require(msg.sender == getEscrow[id].client , "you are not client");
        require(getEscrow[id].status == State.cancelled , "contract is not canceled");
        uint amount = getEscrow[id].fund;
        getEscrow[id].fund = 0;
        (bool success , ) = getEscrow[id].client.call{
            value : amount
        }("");
        require(success , "revert failed");
        getEscrow[id].status = State.finished;
        emit revertedmoney(getEscrow[id].client, amount);
    }
}