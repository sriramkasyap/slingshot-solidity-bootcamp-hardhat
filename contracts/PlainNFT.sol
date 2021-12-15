//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";



contract PlainNFT is ERC721, ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private  tokens;

    
    constructor(string memory _symbol, string memory _name) ERC721(_symbol, _name) {
    }

    function mintNFT() external {
        uint tokenId = tokens.current();
        _safeMint(msg.sender,tokenId);
        tokens.increment();
    }

    // Avoid same sender having multiple voterIds
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from,  to, tokenId);
    }

    // Dummy Overrides 
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    

}