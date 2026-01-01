// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Escrow} from "../src/Escrow.sol";

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

    function testDeposit(uint256 amount) public {     
        vm.assume(amount > 0 && amount < 100 ether);
        vm.prank(client);
        escrow.createEscrow(freelancer);
        vm.deal(client , amount);
        vm.prank(client);
        escrow.deposit{
            value : amount
        }(1);
        assertEq(address(escrow).balance, amount);
        ( , , uint256 _fund , Escrow.State _status) = escrow.getEscrow(1);
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
        ( ,  ,  , Escrow.State _status) = escrow.getEscrow(1);
        assertEq(uint(_status) , uint(Escrow.State.submitted));
    }

     function testworksubmissionbyclient(uint amount) public {      
        vm.assume(amount > 0 && amount < 100 ether);
        vm.prank(client);
        escrow.createEscrow(freelancer);
        vm.deal(client , amount);
        vm.prank(client);
        escrow.deposit{
            value : amount
        }(1);
        vm.prank(client);
        vm.expectRevert();
        escrow.workSubmission(1);
    }

    function testclientApproved(uint256 amount) public {
        vm.assume(amount > 0 && amount < 100 ether);
        vm.prank(client);
        escrow.createEscrow(freelancer);
        vm.deal(client , amount);
        vm.prank(client);
        escrow.deposit{
            value : amount
        }(1);
        vm.prank(freelancer);
        escrow.workSubmission(1);
        vm.prank(client);
        escrow.clientApproved(1);
        ( , ,  , Escrow.State _status) = escrow.getEscrow(1);
        assertEq(uint(_status) , uint(Escrow.State.approved));
    }

    function testclientApprovedbyfreelancer(uint256 amount) public {
        vm.assume(amount > 0 && amount < 100 ether);
        vm.prank(client);
        escrow.createEscrow(freelancer);
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

    function testWithdrawal(uint256 amount) public {
        vm.assume(amount > 0 && amount < 100 ether);
        vm.prank(client);
        escrow.createEscrow(freelancer);
        vm.deal(client , amount);
        vm.prank(client);
        escrow.deposit{
            value : amount
        }(1);
        vm.prank(freelancer);
        escrow.workSubmission(1);
        vm.prank(client);
        escrow.clientApproved(1);
        uint256 freelancerbalancebefore = freelancer.balance;
        uint256 escrowbalancebefore = address(escrow).balance;
        vm.prank(freelancer);
        escrow.withdrawal(1);
        uint256 freelancerbalanceafter = freelancer.balance;
        uint256 escrowbalanceafter = address(escrow).balance;
        assertEq(escrowbalancebefore , amount);
        assertEq(escrowbalanceafter,0);
        assertEq(freelancerbalanceafter - freelancerbalancebefore , amount);
        ( ,  , uint256 _fund , Escrow.State _status) = escrow.getEscrow(1);
        assertEq(_fund , 0);
        assertEq(uint(_status) , uint(Escrow.State.finished));
    }

    function testWithdrawalbyclient(uint256 amount) public {     
        vm.assume(amount > 0 && amount < 100 ether);
        vm.prank(client);
        escrow.createEscrow(freelancer);
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

    function testrevertMoneybeforeworksubmit(uint256 amount) public {
        vm.assume(amount > 0 && amount < 100 ether);
        vm.prank(client);
        escrow.createEscrow(freelancer);
        vm.deal(client , amount);
        vm.prank(client);
        escrow.deposit{
            value : amount
        }(1);
        vm.prank(client);
        escrow.cancelDeal(1);
        vm.prank(client);
        uint256 escrowbalancebefore = address(escrow).balance;
        uint256 clientbalancebefore = client.balance;
        escrow.revertMoney(1);
        uint256 escrowbalanceafter = address(escrow).balance;
        uint256 clientbalanceafter = client.balance;
        assertEq(escrowbalancebefore , amount);
        assertEq(escrowbalanceafter , 0);
        assertEq(clientbalanceafter - clientbalancebefore , amount);
        ( ,  , uint256 _fund , Escrow.State _status) = escrow.getEscrow(1);
        assertEq(_fund , 0);
        assertEq(uint(_status) , uint(Escrow.State.finished));
    }

    function testrevertMoneyafterworksubmit(uint amount) public {
        vm.assume(amount > 0 && amount < 100 ether);
        vm.prank(client);
        escrow.createEscrow(freelancer);
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
        uint256 escrowbalancebefore = address(escrow).balance;
        uint256 clientbalancebefore = client.balance;
        escrow.revertMoney(1);
        uint256 escrowbalanceafter = address(escrow).balance;
        uint256 clientbalanceafter = client.balance;
        assertEq(escrowbalancebefore , amount);
        assertEq(escrowbalanceafter , 0);
        assertEq(clientbalanceafter - clientbalancebefore , amount);
        ( , , uint256 _fund , Escrow.State _status) = escrow.getEscrow(1);
        assertEq(_fund , 0);
        assertEq(uint(_status) , uint(Escrow.State.finished));
    }
}