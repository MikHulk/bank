// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/Bank.sol";


contract Reverter {
    receive() external payable {
        revert("ERROR");
    }
}


contract BankTest is Test {
    address owner = makeAddr("user1");
    address rober = makeAddr("user2");
    Bank bank;
    
    function setUp() public {
        vm.prank(owner);
        bank = new Bank();
    }

    function test_deposit(uint ammount) public {
        console.logAddress(owner);
        vm.deal(owner, ammount);
        assertEq(owner.balance, ammount);
        if(ammount < 0.1 ether) {
            vm.expectRevert();
        }
        vm.prank(owner);
        bank.deposit{value: ammount}();
    }

    function test_withdraw(uint ammount) public {
        if (ammount < 0.1 ether) {
            vm.expectRevert();
            vm.prank(owner);
            bank.deposit{value: ammount}();
            return;
        }
        console.logAddress(owner);
        vm.deal(owner, ammount);
        assertEq(owner.balance, ammount);
        vm.startPrank(owner);
        bank.deposit{value: ammount}();
        assertEq(owner.balance, 0);
        vm.expectRevert();
        bank.withdraw(ammount + 1);
        bank.withdraw(ammount);
        assertEq(owner.balance, ammount);
    }

    function test_error_on_sender_call() public {
        Reverter r = new Reverter();
        address user = address(r);
        vm.prank(user);
        Bank _bank = new Bank();
        uint ammount = 100 ether;
        console.logAddress(user);
        vm.deal(user, ammount);
        assertEq(user.balance, ammount);
        vm.startPrank(user);
        _bank.deposit{value: ammount}();
        assertEq(user.balance, 0);
        vm.expectRevert();
        _bank.withdraw(ammount);
        
    }
}
