// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ERC4907.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// contract RimeRent is ERC4907 {
//     using Counters for Counters.Counter;
//     Counters.Counter private _tokenIds;

//     constructor() ERC4907("RimeRent", "RIMER") {}

//     function mint(string memory _tokenURI) public {
//     _tokenIds.increment();
//     uint256 newTokenId = _tokenIds.current();
//     _safeMint(msg.sender, newTokenId);
//     _setTokenURI(newTokenId, _tokenURI);
//     }

//     function burn(uint256 tokenId) public {
//     _burn(tokenId);
//     }
// }

contract RimeRent is ERC4907 {
    uint256 public tokenCounter;
    uint256 public MAX_TOKENS = 1000; // maximum supply

    constructor() ERC4907("RimeRent", "RIMER") {
        tokenCounter = 0;
    }

    function mint(string memory _tokenUri) public payable { //Creation and transfer to the wallet
        require(tokenCounter < MAX_TOKENS, "ERC4907: Max supply");
        _safeMint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, _tokenUri);
        tokenCounter = tokenCounter + 1;
    }
}
