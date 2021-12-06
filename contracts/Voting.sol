//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.6;

contract Voting {
        enum Status { INIT, IN_PROGRESS, COMPLETE }
        struct Candidate {
            string name;
            uint voteCount;
            bool isValid;
        }

        Status private votingStatus;
        string[] private candidateNames;
        mapping (string => Candidate) private candidates;
        mapping (address => bool) private voted;
        address public initiator;
        mapping(Status => string) internal statusNames;

        constructor() {
            statusNames[Status.INIT] = "Initialized";
            statusNames[Status.IN_PROGRESS] = "Voting in Progress";
            statusNames[Status.COMPLETE] = "Voting is complete. Results available";
        }
    

        modifier onlyInitiator() {
            require(msg.sender==initiator, "You are not authorized to perform this action");
            _;
        }

        modifier onlyStatus(Status requiredStatus, string memory errorMessage) {
            require(votingStatus == requiredStatus, errorMessage);
            _;
        }

        function initiate(string[] calldata _names) external onlyStatus(Status.INIT, "Voting already in progress") {
            for(uint i=0; i < _names.length; i++) {
                candidates[_names[i]]= Candidate(_names[i], 0, true);
                candidateNames.push(_names[i]);
            }
            votingStatus = Status.IN_PROGRESS;
            initiator = msg.sender;
        }

        function vote(string calldata _candidate) external onlyStatus(Status.IN_PROGRESS, "Voting is not active") {
            require(hasVoted(msg.sender) == false, "You can only vote once");
            require(candidates[_candidate].isValid , "This Candidate is not listed");
            candidates[_candidate].voteCount++;
            voted[msg.sender]=true;
        }

        function hasVoted(address _voter) public view returns(bool) {
            return bool(voted[_voter]);
        } 

        function closeVoting() external onlyInitiator onlyStatus(Status.IN_PROGRESS, "Voting hasn't begun yet") {
            votingStatus = Status.COMPLETE;
        }

        function resetVoting() external onlyInitiator onlyStatus(Status.COMPLETE, "Voting isn't complete yet!") {
            votingStatus = Status.INIT;
            delete initiator;
            for(uint i = 0; i < candidateNames.length; i++) {
                candidates[candidateNames[i]].voteCount = 0;
                candidates[candidateNames[i]].isValid = false;
                delete candidates[candidateNames[i]];
            }
            delete candidateNames;
        }

        function getVotingStatus() external view returns (string memory) {
            return statusNames[votingStatus];
        }

        function getVotes(string calldata _candidate) external view returns (uint){
            require(candidates[_candidate].isValid , "This Candidate is not listed");
            return candidates[_candidate].voteCount;
        }

}