//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import './CloneFactory.sol';

contract EscrowFactory is CloneFactory{

    EscrowHolder[] public escrows;
    address masterContract;


    constructor(address _masterContractAddress) {
        masterContract = _masterContractAddress;
    }

    function createEscrowAccount(address _userA, address _userB, uint _amount) external payable returns(uint) {
        address cloned = createClone(masterContract);
        EscrowHolder escrow = EscrowHolder(cloned);
        escrow.initiate{value: msg.value}(_userA, _userB, _amount);
        escrows.push(escrow);
        return escrows.length - 1;
    }

    function getContracts() external view returns(EscrowHolder[] memory) {
        return escrows;
    }

    function reportCompletion(uint contractIndex) external {
        escrows[contractIndex].reportCompletion(msg.sender);
    }

    function approveFunding(uint contractIndex) external {
        escrows[contractIndex].approveFunding(msg.sender);
    }

    function getBalance(uint contractIndex) external view returns(uint) {
        return escrows[contractIndex].getBalance();
    }
}


contract EscrowHolder {
    address public user_A;
    address public user_B;
    uint public amount;
    bool public isTaskComplete = false;

    modifier shoulBeSentBy(address _required_initiator, address _initiator) {
        require(_required_initiator == _initiator, "You are not authorized to perform this action");
        _;
    }

    function initiate(address _sender, address _recipient, uint _amount) external payable {
        require(_amount == msg.value, "Amount is not equal to the supplied balance");

        user_A = _sender;
        user_B = _recipient;
        amount = _amount;
    }

    function reportCompletion(address _msgsender) external shoulBeSentBy(user_B, _msgsender) {
        isTaskComplete = true;
    }

    function approveFunding(address _msgsender) external shoulBeSentBy(user_A, _msgsender)  {
        require(isTaskComplete == true, "Task hasn't been reported as complete by recipient");
        isTaskComplete = false;
        payable(user_B).transfer(amount);
    }

    function getBalance() public view returns (uint){
        return address(this).balance;
    }

}