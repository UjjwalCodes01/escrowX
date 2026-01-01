// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Escrow.sol";

contract EscrowTest is Test {
    Escrow escrow;
    address client;
    address freelancer;

    function setUp() public {
        escrow = new Escrow();
        client = makeAddr("client");
        freelancer = makeAddr("freelancer");
    }

    function testcreateEscrow() public {
        vm.prank(client);
        escrow.createEscrow(freelancer);
        assertEq(escrow.escrowCount(),1);
        (address _client , address _freelancer , uint256 _fund , Escrow.State _status) = escrow.getEscrow(1);
        assertEq(_client , client);
        assertEq(_freelancer , freelancer);
        assertEq(_fund , 0);
        assertEq(uint(_status) , uint(Escrow.State.created));
    }

    function testDeposit() public {
        vm.prank(client);
        escrow.createEscrow(freelancer);
        uint amount = 2 ether;
        vm.deal(client , amount);
        vm.prank(client);
        escrow.deposit{
            value : amount
        }(1);
        (address _client , address _freelancer , uint256 _fund , Escrow.State _status) = escrow.getEscrow(1);
        assertEq(uint(_status) , uint(Escrow.State.funded));
        assertEq(_fund , amount);
    }

    function testworksubmission() public {
        vm.prank(client);
        escrow.createEscrow(freelancer);
        uint256 amount = 2 ether;
        vm.deal(client , amount);
        vm.prank(client);
        escrow.deposit{
            value : amount
        }(1);
        vm.prank(freelancer);
        escrow.workSubmission(1);
        (address _client , address _freelancer , uint256 _fund , Escrow.State _status) = escrow.getEscrow(1);
        assertEq(uint(_status) , uint(Escrow.State.submitted));
    }

     function testworksubmissionbyclient() public {
        vm.prank(client);
        escrow.createEscrow(freelancer);
        uint256 amount = 2 ether;
        vm.deal(client , amount);
        vm.prank(client);
        escrow.deposit{
            value : amount
        }(1);
        vm.prank(client);
        vm.expectRevert();
        escrow.workSubmission(1);
    }

    function testclientApproved() public {
        vm.prank(client);
        escrow.createEscrow(freelancer);
        uint256 amount = 2 ether;
        vm.deal(client , amount);
        vm.prank(client);
        escrow.deposit{
            value : amount
        }(1);
        vm.prank(freelancer);
        escrow.workSubmission(1);
        vm.prank(client);
        escrow.clientApproved(1);
        (address _client , address _freelancer , uint256 _fund , Escrow.State _status) = escrow.getEscrow(1);
        assertEq(uint(_status) , uint(Escrow.State.approved));
    }

    function testclientApprovedbyfreelancer() public {
        vm.prank(client);
        escrow.createEscrow(freelancer);
        uint256 amount = 2 ether;
        vm.deal(client , amount);
        vm.prank(client);
        escrow.deposit{
            value : amount
        }(1);
        vm.prank(freelancer);
        escrow.workSubmission(1);
        vm.prank(freelancer);
        vm.expectRevert();
        escrow.clientApproved(1);
    }

    function testWithdrawal() public {
        vm.prank(client);
        escrow.createEscrow(freelancer);
        uint256 amount = 2 ether;
        vm.deal(client , amount);
        vm.prank(client);
        escrow.deposit{
            value : amount
        }(1);
        vm.prank(freelancer);
        escrow.workSubmission(1);
        vm.prank(client);
        escrow.clientApproved(1);
        vm.prank(freelancer);
        escrow.withdrawal(1);
        (address _client , address _freelancer , uint256 _fund , Escrow.State _status) = escrow.getEscrow(1);
        assertEq(_fund , 0);
        assertEq(uint(_status) , uint(Escrow.State.finished));
    }

    function testWithdrawalbyclient() public {
        vm.prank(client);
        escrow.createEscrow(freelancer);
        uint256 amount = 2 ether;
        vm.deal(client , amount);
        vm.prank(client);
        escrow.deposit{
            value : amount
        }(1);
        vm.prank(freelancer);
        escrow.workSubmission(1);
        vm.prank(client);
        escrow.clientApproved(1);
        vm.prank(client);
        vm.expectRevert();
        escrow.withdrawal(1);
    }

    function testrevertMoneybeforeworksubmit() public {
        vm.prank(client);
        escrow.createEscrow(freelancer);
        uint256 amount = 2 ether;
        vm.deal(client , amount);
        vm.prank(client);
        escrow.deposit{
            value : amount
        }(1);
        vm.prank(client);
        escrow.cancelDeal(1);
        vm.prank(client);
        escrow.revertMoney(1);
        (address _client , address _freelancer , uint256 _fund , Escrow.State _status) = escrow.getEscrow(1);
        assertEq(_fund , 0);
        assertEq(uint(_status) , uint(Escrow.State.finished));
    }

    function testrevertMoneyafterworksubmit() public {
        vm.prank(client);
        escrow.createEscrow(freelancer);
        uint256 amount = 2 ether;
        vm.deal(client , amount);
        vm.prank(client);
        escrow.deposit{
            value : amount
        }(1);
        vm.prank(freelancer);
        escrow.workSubmission(1);
        vm.prank(client);
        escrow.cancelDeal(1);
         vm.prank(client);
        escrow.revertMoney(1);
        ( , , uint256 _Fund , Escrow.State _Status) = escrow.getEscrow(1);
        assertEq(_Fund , 0);
        assertEq(uint(_Status) , uint(Escrow.State.finished));
    }
}