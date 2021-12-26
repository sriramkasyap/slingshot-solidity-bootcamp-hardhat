//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import './CloneFactory.sol';
// import './TokenStreamerProxy.sol';
// import "@openzeppelin/contracts/ownership/Ownable.sol";


contract TokenStreamerFactory is CloneFactory, Ownable {
    // Factory Contract

        // Inherits
            // Ownable

        // Storage
            // List of Child Streamer Contracts (Proxy)
            // TokenStreamerProxy[] childContracts;            
            // Address of Master Streamer Contract Proxy;
            address public masterStreamerProxy;
            // Address of the target Contract code
            address public masterStreamer = 0x16500370A61d015f025e4C74dAdb972042567d9a;


        // Functions
        // Initialize (MasterContractAddress, TargetContractAddress) - Set - OnlyOwner
        function initialize(address _masterContract, address, _masterContractProxy) external onlyOwner{
            
        }
        // UpdateMaster (MasterContractAddress) - Set - OnlyOwner
        // UpdateTarget (TargetContractAddress) - Set - OnlyOwner
        // Deploy (...StreamerContractVars) - Create child and update List - Anyone - Payable
}

