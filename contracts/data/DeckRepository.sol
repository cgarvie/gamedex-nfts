pragma solidity 0.4.24;

import "../control/Ownable.sol";
import "../libraries/SafeMath.sol";


contract DeckRepository is Ownable {

    using SafeMath for uint256;

    // Deck struct
    struct Deck {
        uint256 id;
        address issuer;
        uint256[] tokenIds;
    }

    // uint256 variable to track IDs of decks.
    uint256 public numberOfTotalDecks = 0;

    // Array with all deck IDs, used for enumeration.
    uint256[] public allDecks;

    // Mapping from deck ID to Deck struct.
    mapping(uint256 => Deck) public deckStructs;

    // Mapping from deck ID to issuer.
    mapping(uint256 => address) public deckIssuer;

    // Mapping from issuer to number of issued decks.
    mapping(address => uint256) public issuedDecksCount;

    // Mapping from issuer to list of issued deck IDs.
    mapping(address => uint256[]) public issuedDecks;

    // Mapping from deck ID to index of the issuer decks list.
    mapping(uint256 => uint256) public issuedDecksIndex;

    // Mapping from deck id to position in the allDecks array.
    mapping(uint256 => uint256) public allDecksIndex;

    /**
     * @dev Gets list of issused deck IDs.
     * @param _issuer Address of issuer.
     * @return uint256[] List of deck IDs.
     */
    function getListOfIssuedDeckIds(address _issuer) public view returns (uint256[]) {
        return issuedDecks[_issuer];
    }

    /**
     * @dev Gets list of token IDs in a deck.
     * @param _deckId ID of deck.
     * @return uint256[] List of token IDs.
     */
    function getListOfTokenIds(uint256 _deckId) public view returns (uint256[]) {
        return deckStructs[_deckId].tokenIds;
    }

    /**
     * @dev Gets count of allDecks array.
     * @return uint256 Count of all decks in the allDecks array.
     */
    function getAllDecksCount() public view returns (uint256) {
        return allDecks.length;
    }

    /**
     * @dev Gets ID of a deck by its index in allDecks array.
     * @param _index Index of deck.
     * @return ID of deck.
     */
    function getDeckIdByIndex(uint256 _index) public view returns (uint256) {
        require(_index < allDecks.length);
        return allDecks[_index];
    }

    /**
     * @dev Gets address of issuer by deck ID.
     * @param _deckId ID of deck.
     * @return Issuer of deck.
     */
    function getDeckIssuer(uint256 _deckId) public view returns (address) {
        return deckIssuer[_deckId];
    }

    /**
     * @dev Gets supply of tokens in a deck.
     * @param _deckId ID of deck.
     * @return Supply of tokens.
     */
    function getSupplyOfDeck(uint256 _deckId) public view returns (uint256) {
        return deckStructs[_deckId].tokenIds.length;
    }

    /**
     * @dev Gets length of issuedDecks array.
     * @param _issuer Address of issuer.
     * @return Length of array.
     */
    function getIssuedDecksLength(address _issuer) public view returns (uint256) {
        return issuedDecks[_issuer].length;
    }

    /**
     * @dev Gets last index of issuedDecks array.
     * @param _issuer Address of issuer.
     * @return Last index.
     */
    function getLastIssuedDeckIndex(address _issuer) public view returns (uint256) {
        return issuedDecks[_issuer].length.sub(1);
    }

    /**
     * @dev Gets last index of issuedDecks array.
     * @return Last index.
     */
    function getLastAllDeckIndex() public view returns (uint256) {
        return allDecks.length.sub(1);
    }

    /**
     * @dev Sets issuer in deckIssuer mapping.
     * @param _issuer Address of issuer.
     * @param _deckId ID of deck.
     */
    function setDeckIssuer(address _issuer, uint256 _deckId) public onlyOwner {
        deckIssuer[_deckId] = _issuer;
    }

    /**
     * @dev Sets Deck ID in issuedDecks mapping.
     * @param _issuer Address of issuer.
     * @param _deckId ID of deck.
     * @param _index Index of deck.
     */
    function setIssuedDecks(address _issuer, uint256 _deckId, uint256 _index) public onlyOwner {
        issuedDecks[_issuer][_index] = _deckId;
    }

    /**
     * @dev Sets Deck ID in allDecks array.
     * @param _deckId ID of deck.
     * @param _index Index of deck.
     */
    function setAllDeckId(uint256 _deckId, uint256 _index) public onlyOwner {
        allDecks[_index] = _deckId;
    }

    /**
     * @dev Sets index in issuedDecksIndex mapping.
     * @param _deckId ID of deck.
     * @param _index Index of deck.
     */
    function setIssuedDecksIndex(uint256 _deckId, uint256 _index) public onlyOwner {
        issuedDecksIndex[_deckId] = _index;
    }

    /**
     * @dev Sets index in allDecksIndex mapping.
     * @param _deckId ID of deck.
     * @param _index Index of deck.
     */
    function setAllDecksIndex(uint256 _deckId, uint256 _index) public onlyOwner {
        allDecksIndex[_deckId] = _index;
    }

    /**
     * @dev Increases count of issuedDecksCount.
     * @param _issuer Address of Issuer.
     */
    function increaseIssuedDecksCount(address _issuer) public onlyOwner {
        issuedDecksCount[_issuer] = issuedDecksCount[_issuer].add(1);
    }

    /**
     * @dev Increases total decks count.
     */
    function increaseTotalDecksCount() public onlyOwner {
        numberOfTotalDecks = numberOfTotalDecks.add(1);
    }

    /**
     * @dev Increases index of allDecksIndex mapping.
     */
    function increaseAllDecksIndex() public onlyOwner {
        allDecksIndex[numberOfTotalDecks] = allDecks.length;
    }

    /**
     * @dev Increases Deck ID in allDecks array.
     */
    function increaseAllDeckIds() public onlyOwner {
        allDecks.push(numberOfTotalDecks);
    }

    /**
     * @dev Decreases count of issuedDecksCount.
     * @param _issuer Address of Issuer.
     */
    function decreaseIssuedDecksCount(address _issuer) public onlyOwner {
        issuedDecksCount[_issuer] = issuedDecksCount[_issuer].sub(1);
    }

    /**
     * @dev Decreases deck count of issuer in issuedDecks.
     * @param _issuer Address of Issuer.
     */
    function decreaseIssuedDecksLength(address _issuer) public onlyOwner {
        issuedDecks[_issuer].length--;
    }

    /**
     * @dev Decreases length of allDecks array.
     */
    function decreaseAllDecksLength() public onlyOwner {
        allDecks.length--;
    }

    /**
     * @dev Adds Deck Id to issuedDecks array.
     * @param _issuer Address of Issuer.
     * @param _deckId ID of deck.
     */
    function addToIssuedDecks(address _issuer, uint256 _deckId) public onlyOwner {
        issuedDecks[_issuer].push(_deckId);
    }

    /**
     * @dev Adds deck in deckStructs array.
     * @param _deckId ID of deck.
     * @param _issuer Address of Issuer.
     */
    function addToDeckStructs(uint256 _deckId, address _issuer) public onlyOwner {
        Deck memory _deck;
        _deck.id = _deckId;
        _deck.issuer = _issuer;
        deckStructs[_deckId] = _deck;
    }

    /**
     * @dev Adds token ID in deckStructs array.
     * @param _deckId ID of deck.
     * @param _tokenId ID of token.
     */
    function addToDeckTokenIds(uint256 _deckId, uint256 _tokenId) public onlyOwner {
        deckStructs[_deckId].tokenIds.push(_tokenId);
    }

    /**
     * @dev Deletes deck struct.
     * @param _deckId ID of deck to delete.
     */
    function deleteDeckStruct(uint256 _deckId) public onlyOwner {
        delete deckStructs[_deckId];
    }
}
