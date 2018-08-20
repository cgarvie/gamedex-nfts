pragma solidity 0.4.24;

import "./ERC721.sol";


/**
 * @title ERC897434 Token Standard basic interface
 */
contract ERC897434 is ERC721 {
    event DeckIssue(address indexed _issuer, uint256 indexed _deckId);
    event DeckTransfer(address indexed _from, address indexed _to, uint256 indexed _deckId);

    function issuerOf(uint256 _deckId) public view returns (address);
    function totalSupplyOf(uint256 _deckId) public view returns (uint256);
    function deckExists(uint256 _deckId) public view returns (bool);
    function deckIdOf(uint256 _tokenId) public view returns (uint256);
    function royaltyFee(address _buyer, uint256 _tokenId) public view returns (uint256);
    function issueDeck(address _to, uint256 _fee, uint256 _numberOfTokens) public;
    function transferDeck(address _to, uint256 _deckId) public;
}