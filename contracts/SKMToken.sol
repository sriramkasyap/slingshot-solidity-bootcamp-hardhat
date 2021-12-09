//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


contract SKMToken is ERC20, Ownable {
    uint public constant MAX_SUPPLY = 1000 * 10**18;

    constructor(uint initialSupply) ERC20("Sriram's Token", "SKM") {
        _mint(msg.sender, initialSupply);
    }

    function rewardAnyone(address _recipient, uint amount) public onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "You have reached the maximum supply of this token");
        _mint(_recipient, amount);
    }

    function unMintedTokenCount() public view returns(uint) {
        return MAX_SUPPLY - totalSupply();
    }

}