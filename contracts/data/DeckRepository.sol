pragma solidity 0.4.24;

import "../control/Ownable.sol";
import "../libraries/SafeMath.sol";


contract DeckRepository is Ownable {

    using SafeMath for uint256;

    // uint256 variable to track IDs of decks.
    uint256 public numberOfTotalDecks;

    // Mapping from issuer to list of issued deck IDs.
    mapping(address => uint256[]) public issuerToDecks;

    // Mapping from deck ID to tokens list.
    mapping(uint256 => uint256[]) public deckToTokens;

    // Mapping from deck ID to issuer.
    mapping(uint256 => address) public deckToIssuer;

    /**
     * @dev Gets the total supply of the tokens in a deck.
     * @return uint256 Total supply.
     */
    function getTotalSupply(uint256 _deckId) public view returns (uint256) {
        return deckToTokens[_deckId].length;
    }

    /**
     * @dev Gets the total supply of the tokens in a deck.
     * @return uint256 Total supply.
     */
    function getNextDeckId() public view returns (uint256) {
        return numberOfTotalDecks.add(1);
    }

    /**
     * @dev Adds deck ID to a list of decks issued by address.
     * @param _issuer Address of issuer.
     * @param _tokenId ID of token.
     */
    function setIssuerToDecks(address _issuer, uint256 _tokenId) public onlyOwner {
        issuerToDecks[_issuer].push(_tokenId);
    }

    /**
     * @dev Adds token ID to a list of tokens contained in a deck.
     * @param _deckId ID of deck.
     * @param _tokenId ID of token.
     */
    function setDeckToTokens(uint256 _deckId, uint256 _tokenId) public onlyOwner {
        deckToTokens[_deckId].push(_tokenId);
    }

    /**
     * @dev Adds token ID to a list of tokens contained in a deck.
     * @param _deckId ID of deck.
     * @param _issuer Address of issuer.
     */
    function setDeckToIssuer(uint256 _deckId, address _issuer) public onlyOwner {
        deckToIssuer[_deckId] = _issuer;
    }

    function increaseTotalDecksCount() public onlyOwner {
        numberOfTotalDecks = numberOfTotalDecks.add(1);
    }
}
