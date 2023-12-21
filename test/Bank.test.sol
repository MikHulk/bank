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
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address user4 = makeAddr("user4");
    address user5 = makeAddr("user5");
    address user6 = makeAddr("user6");
    address user7 = makeAddr("user7");
    Bank bank;
    
    function setUp() public {
        bank = new Bank();
    }

    function test_deposit(uint ammount) public {
        address user =
            [user1, user2, user3, user4, user5, user6, user7][ammount % 7];
        console.logAddress(user);
        vm.deal(user, ammount);
        assertEq(user.balance, ammount);
        assertEq(bank.getBalance(user), 0);
        if(ammount < 1) {
            vm.expectRevert();
        }
        vm.prank(user);
        bank.sendEthers{value: ammount}();
    }

    function test_withdraw(uint ammount) public {
        address user =
            [user1, user2, user3, user4, user5, user6, user7][ammount % 7];
        if (ammount == 0 || ammount == 2 ^ 256 - 1) {
            vm.expectRevert();
            vm.prank(user);
            bank.sendEthers{value: ammount}();
            return;
        }
        console.logAddress(user);
        vm.deal(user, ammount);
        assertEq(user.balance, ammount);
        vm.startPrank(user);
        bank.sendEthers{value: ammount}();
        assertEq(user.balance, 0);
        vm.expectRevert();
        bank.withdraw(ammount + 1);
        bank.withdraw(ammount);
        assertEq(user.balance, ammount);
    }

    function test_error_on_sender_call() public {
        Reverter r = new Reverter();
        address user = address(r);
        uint ammount = 100 ether;
        console.logAddress(user);
        vm.deal(user, ammount);
        assertEq(user.balance, ammount);
        vm.startPrank(user);
        bank.sendEthers{value: ammount}();
        assertEq(user.balance, 0);
        vm.expectRevert();
        bank.withdraw(ammount);
        
    }
}
