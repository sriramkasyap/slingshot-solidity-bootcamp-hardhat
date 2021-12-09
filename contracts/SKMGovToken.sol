//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";



contract SKMGovToken is ERC20, Ownable, AccessControl {
    uint public constant MAX_SUPPLY = 1000 * 10**18;
    bytes32 public constant TEAM_MEMBER_ROLE = keccak256("TEAM_MEMBER_ROLE");

    constructor(uint initialSupply) ERC20("Sriram Governance Token", "SKMGOV") {
        _setupRole(TEAM_MEMBER_ROLE, msg.sender);
        _mint(msg.sender, initialSupply);
    }

    function rewardToken(address _recipient, uint amount) public onlyRole(TEAM_MEMBER_ROLE) {
        require(totalSupply() + amount <= MAX_SUPPLY, "You have reached the maximum supply of this token");
        _mint(_recipient, amount);
    }

    function unMintedTokenCount() public view returns(uint) {
        return MAX_SUPPLY - totalSupply();
    }

    function _beforeTokenTransfer(address from, address to, uint256 value) internal virtual override {
        require(hasRole(TEAM_MEMBER_ROLE, msg.sender), "Only Team members can transfer tokens");
        super._beforeTokenTransfer(from, to, value);
    }

    function addMember(address _member) external onlyOwner {
        _setupRole(TEAM_MEMBER_ROLE, _member);
    }

    function removeMember(address _member) external onlyOwner {
        _revokeRole(TEAM_MEMBER_ROLE, _member);
    }

}