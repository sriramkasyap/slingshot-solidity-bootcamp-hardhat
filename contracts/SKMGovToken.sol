//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";



contract SKMGovToken is ERC20, AccessControl {
    uint public constant MAX_SUPPLY = 1000 * 10**18;
    bytes32 public constant TEAM_MEMBER_ROLE = keccak256("TEAM_MEMBER_ROLE");

    constructor(uint _initialSupply) ERC20("Sriram Governance Token", "SKMGOV") {
        require(_initialSupply <= MAX_SUPPLY, "Initial Supply cannot be greater than Max Supply");
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(TEAM_MEMBER_ROLE, msg.sender);
        _mint(msg.sender, _initialSupply);
    }

    function rewardToken(address _recipient, uint amount) public onlyRole(TEAM_MEMBER_ROLE) {
        require(totalSupply() + amount <= MAX_SUPPLY, "You have reached the maximum supply of this token");
        _mint(_recipient, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 value) internal virtual override {
        require(hasRole(TEAM_MEMBER_ROLE, msg.sender), "Only Team members can transfer tokens");
        super._beforeTokenTransfer(from, to, value);
    }

    function addMember(address _member) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(TEAM_MEMBER_ROLE, _member);
    }

    function removeMember(address _member) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(TEAM_MEMBER_ROLE, _member);
    }

}