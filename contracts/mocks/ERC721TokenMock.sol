pragma solidity ^0.4.24;

import "../tokens/ERC721Token.sol";


/**
 * @title ERC721TokenMock
 * This mock just provides a public mint and burn functions for testing purposes,
 * and a public setter for metadata URI
 */
contract ERC721TokenMock is ERC721Token {
    
    constructor(address _cardRepo) public ERC721Token(_cardRepo) {

    }

    function mint(address _to, uint256 _tokenId) public {
        super._mint(_to, _tokenId, 0, 0);
    }

    function burn(uint256 _tokenId) public {
        super._burn(ownerOf(_tokenId), _tokenId);
    }

    function removeTokenFrom(address _from, uint256 _tokenId) public {
        super._removeTokenFrom(_from, _tokenId);
    }
}