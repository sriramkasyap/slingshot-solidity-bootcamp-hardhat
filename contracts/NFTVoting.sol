//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";



contract NFTVoting is ERC721, Ownable, ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private  _voterIds;

    struct Candidate {
        string name;
        uint voteCount;
        bool isValid;
    }
    enum Status { INIT, IN_PROGRESS, COMPLETE }


    // Current election id to track candidates and voters
    uint32 public currentElectionId;
    
    // Mapping electionId => (candidate.name => candidate)
    mapping (uint32 => mapping(string => Candidate)) public candidateResults;
    
    // Mapping electionId => (tokenId => hasVoted)
    mapping (uint32 => mapping (uint => bool)) private voted;
    
    // Enum election status
    Status private electionStatus;
    
    // Mapping Status enum => Human readable status
    mapping(Status => string) internal statusNames;


    constructor() ERC721("VOT", "Voter Id Token") {
        currentElectionId = 0;
        statusNames[Status.INIT] = "Initialized";
        statusNames[Status.IN_PROGRESS] = "Voting in Progress";
        statusNames[Status.COMPLETE] = "Voting is complete. Results available";
    }

    modifier onlyVoter() {
        // check if sender has the NFT voterId
        require(balanceOf(msg.sender)>0, "You need to own a VoterID NFT to vote.");
        _;
    }

    // Check if the election is in specific status
    modifier onlyStatus(Status requiredStatus, string memory errorMessage) {
        require(electionStatus == requiredStatus, errorMessage);
        _;
    }

    // Check if candidate is valid
    modifier onlyValidCandidate(string calldata _candidate) {
        require(candidateResults[currentElectionId][_candidate].isValid, "This candidate is not participating in this election");
        _;
    }

    function registerAsVoter() public  {
        // Mint an NFT and transfer to the sender
        uint  current = _voterIds.current();
        _safeMint(msg.sender, current);
        _voterIds.increment();
    }


    // 
    // Election related functions
    // 

    // Initiate an election
    function initiateElection(string[] memory _candidates) external onlyOwner onlyStatus(Status.INIT, "Voting already in progress") {
        for(uint i = 0; i < _candidates.length; i++) {
            candidateResults[currentElectionId][_candidates[i]]= Candidate(_candidates[i], 0, true);
        }
        electionStatus = Status.IN_PROGRESS;
    }


    // Vote a candidate
    function vote(string calldata _candidate, uint _voterId) external onlyVoter onlyStatus(Status.IN_PROGRESS, "Voting is not active") onlyValidCandidate(_candidate) {
        // check if sender owns the token
        require(ownerOf(_voterId) == msg.sender, "You do not own this voterId");

        // Check if token has not voted
        require(hasVoted(_voterId) == false, "This VoterID has already been used");

        // mark token as voted
        voted[currentElectionId][_voterId] = true;
        
        // increment vote count for candidate
        candidateResults[currentElectionId][_candidate].voteCount++;
    }

    // Is the voterId used in this election
    function hasVoted(uint _voterId) internal view returns(bool) {
        return bool(voted[currentElectionId][_voterId]);
    } 

    // Close Voting
    function closeVoting() external onlyOwner onlyStatus(Status.IN_PROGRESS, "Voting hasn't begun yet") {
        electionStatus = Status.COMPLETE;
    }


    // Reset Voting
    function resetVoting() external onlyOwner onlyStatus(Status.COMPLETE, "Voting isn't complete yet!") {
        electionStatus = Status.INIT;
        currentElectionId++;
    }

    // Get voting status
    function getVotingStatus() external view returns (string memory) {
        return statusNames[electionStatus];
    }

    // Get candidate vote count
    function getVoteCount(string calldata _candidate) public view onlyValidCandidate(_candidate) returns(uint) {
        return candidateResults[currentElectionId][_candidate].voteCount;
    }

    // Get tokens owned by owner
    function tokensOfOwner(address  _owner) external view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        uint[] memory tokensOwned = new uint[](tokenCount);
        for(uint i=0; i < tokenCount; i++) {
            tokensOwned[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensOwned;
    }

    // Avoid same sender having multiple voterIds
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        require(balanceOf(to) == 0, "You can register only once");
        super._beforeTokenTransfer(from,  to, tokenId);
    }

    // Dummy Overrides 
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    

}