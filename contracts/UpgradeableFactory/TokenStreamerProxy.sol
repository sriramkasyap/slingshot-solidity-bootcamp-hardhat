pragma solidity ^0.8.9;

import './TokenStreamerFactory.sol';

contract TokenStreamerProxy {
    // Proxy Contract

        address public master;
        address public owner;
        address public constant factoryAddress = 0xf02A102153DDf132032B7De5D19F43aA049052Dd;

        
        fallback() external payable {
            master = TokenStreamerFactory(factoryAddress).masterStreamer();
            assembly {
                let _impl := sload(0)
                let ptr := mload(0x40)

                // (1) copy incoming call data
                calldatacopy(ptr, 0, calldatasize())

                // (2) forward call to logic contract
                let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
                let size := returndatasize()

                // (3) retrieve return data
                returndatacopy(ptr, 0, size)

                // (4) forward return data back to caller
                switch result
                case 0 { revert(ptr, size) }
                default { return(ptr, size) }
            }
        }
        
        
}