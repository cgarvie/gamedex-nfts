pragma solidity 0.4.24;

import "../interfaces/ERC897434.sol";
import "../interfaces/ERC223.sol";
import "./ERC721Token.sol";
import "../data/DeckRepository.sol";
import "../control/Pausable.sol";
import "../libraries/Strings.sol";


/**
 * @title Full ERC897434 Token.
 * This implementation includes all the required and some optional functionality of the ERC897434 standard.
 */
contract ERC897434Token is ERC897434, ERC721Token {

    // Reference to CardRepository storage contract.
    DeckRepository public deckRepository;

    // Reference to ERC-223 token deployed
    ERC223 public erc223;

    /**
    * @dev Constructor function
    */
    constructor(address _erc223, address _deckRepo, address _cardRepo) ERC721Token(_cardRepo) public {
        erc223 = ERC223(_erc223);
        deckRepository = DeckRepository(_deckRepo);
    }

    /**
     * @dev Gets the deck ID at a given index of the decks list of the requested issuer.
     * @param _issuer address issued the decks list to be accessed.
     * @param _index uint256 representing the index to be accessed of the requested decks list.
     * @return uint256 deck ID at the given index of the decks list issued by the requested address.
     */
    function deckOfIssuerByIndex(address _issuer, uint256 _index) public view returns (uint256) {
        require(_index < balanceOf(_issuer));
        return deckRepository.issuedDecks(_issuer, _index);
    }

    /**
     * @dev Gets the deck ID at a given index of all the decks in this contract.
     * Reverts if the index is greater or equal to the total number of decks.
     * @param _index uint256 representing the index to be accessed of the decks list.
     * @return uint256 deck ID at the given index of the decks list.
     */
    function deckByIndex(uint256 _index) public view returns (uint256) {
        return deckRepository.getDeckIdByIndex(_index);
    }

    /**
     * @dev Returns the address of the issuer of the given deck ID.
     * Reverts if the returned address is 0x.
     * @param _deckId uint256 representing the ID of the deck.
     * @return address issuer of the deck.
     */
    function issuerOf(uint256 _deckId) public view returns (address) {
        return deckRepository.getDeckIssuer(_deckId);
    }

    /**
     * @dev Returns the total supply of all the tokens in the deck.
     * @param _deckId uint256 representing the ID of the deck.
     * @return uint256 number of tokens issued in the deck.
     */
    function totalSupplyOf(uint256 _deckId) public view returns (uint256) {
        return deckRepository.getSupplyOfDeck(_deckId);
    }

    /**
     * @dev Returns whether the deck exists.
     * @param _deckId uint256 representing the ID of the deck.
     * @return bool whether the deck exists.
     */
    function deckExists(uint256 _deckId) public view returns (bool) {
        address issuer = deckRepository.deckIssuer(_deckId);
        return issuer != address(0);
    }

    /**
     * @dev Returns the deck ID token.
     * @param _tokenId uint256 representing the ID of the token.
     * @return uint256 ID of the deck.
     */
    function deckIdOf(uint256 _tokenId) public view returns (uint256) {
        return cardRepository.getDeckIdOfToken(_tokenId);
    }

    /**
     * @dev Returns the royalty fee of token in wei.
     * @param _tokenId uint256 representing the ID of the token.
     * @return uint256 royalty fee in wei.
     */
    function royaltyFee(address _buyer, uint256 _tokenId) public view returns (uint256) {
        address issuer = deckRepository.getDeckIssuer(cardRepository.getDeckIdOfToken(_tokenId));
        uint256[] memory tokens = cardRepository.getListOfOwnedTokens(_buyer);
        uint256 matchedTokensCount = 0;

        for (uint256 i = 0; i < tokens.length; i++) {
            if (issuer == deckRepository.getDeckIssuer(cardRepository.getDeckIdOfToken(_tokenId))) {
                matchedTokensCount++;
            }
        }

        uint256 fee = cardRepository.getRoyaltyFee(_tokenId);
        if (matchedTokensCount == 0) {
            return fee;
        }
        return _calculateDiscountedFee(matchedTokensCount, fee);
    }

    /**
     * @dev Issues a new deck.
     * @param _to Issue new deck to address.
     * @param _fee Royalty fee of the tokens.
     * @param _numberOfTokens Number of tokens to issue.
     */
    function issueDeck(address _to, uint256 _fee, uint256 _numberOfTokens) public whenNotPaused {
        require(_to != address(0));
        require(_numberOfTokens != 0);
        
        _issue(_to, _fee, _numberOfTokens);
    }

    /**
     * @dev Transfers the ownership of a given deck ID to another address
     * @param _to address to receive the ownership of the given deck ID
     * @param _deckId uint256 ID of the deck to be transferred
    */
    function transferDeck(address _to, uint256 _deckId) public whenNotPaused {
        require(_isIssuer(msg.sender, _deckId));
        require(_to != address(0));

        _removeDeckFrom(msg.sender, _deckId);
        _addDeckTo(_to, _deckId);
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
     * Requires the msg sender to be the owner, approved, or operator
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _tokenId) public whenNotPaused {
        super.transferFrom(_from, _to, _tokenId);

        require(erc223.transferFrom(_to, _from, royaltyFee(_to, _tokenId)));

        emit Transfer(_from, _to, _tokenId);
    }

    /**
     * @dev Returns whether the given address owns the given deck ID
     * @param _issuer address of the issuer to query
     * @param _deckId uint256 ID of the deck to query
     * @return bool whether the issuer owns the given deck ID,
     */
    function _isIssuer(address _issuer, uint256 _deckId) internal view returns (bool) {
        return _issuer == issuerOf(_deckId);
    }

    /**
     * @dev Internal function to add a token ID to the list of a given address.
     * @param _to address representing the new issuer of the given deck ID.
     * @param _deckId uint256 ID of the deck to be added to the decks list of the given address.
     */
    function _addDeckTo(address _to, uint256 _deckId) internal {
        require(deckRepository.deckIssuer(_deckId) == address(0));

        deckRepository.setDeckIssuer(_to, _deckId);
        deckRepository.increaseIssuedDecksCount(_to);

        uint256 length = deckRepository.getIssuedDecksLength(_to);
        deckRepository.addToIssuedDecks(_to, _deckId);
        deckRepository.setIssuedDecksIndex(_deckId, length);
    }

    /**
     * @dev Internal function to remove a deck ID from the list of a given address
     * @param _from address representing the previous issuer of the given deck ID
     * @param _deckId uint256 ID of the deck to be removed from the decks list of the given address
     */
    function _removeDeckFrom(address _from, uint256 _deckId) internal {
        require(issuerOf(_deckId) == _from);
        deckRepository.decreaseIssuedDecksCount(_from);
        deckRepository.setDeckIssuer(address(0), _deckId);

        // To prevent a gap in the array, we store the last token in the index of the token to delete, and
        // then delete the last slot.
        uint256 deckIndex = deckRepository.issuedDecksIndex(_deckId);
        uint256 lastDeckIndex = deckRepository.getLastIssuedDeckIndex(_from);
        uint256 lastDeck = deckRepository.issuedDecks(_from, lastDeckIndex);

        deckRepository.setIssuedDeckId(_from, deckIndex, lastDeck);
        // This also deletes the contents at the last position of the array
        deckRepository.decreaseIssuedDecksLength(_from);

        // Note that this will handle single-element arrays. In that case, both deckIndex and lastDeckIndex are going to
        // be zero. Then we can make sure that we will remove _deckId from the issuedDecks list since we are first swapping
        // the lastDeck to the first position, and then dropping the element placed in the last position of the list

        deckRepository.setIssuedDecksIndex(_deckId, 0);
        deckRepository.setIssuedDecksIndex(lastDeck, deckIndex);
    }

    /**
     * @dev Internal function to issue a new deck.
     * Reverts if the given deck ID already exists.
     * @param _to address the beneficiary that will own the issued deck.
     * @param _fee uint256 royalty fee for the tokens.
     * @param _numberOfTokens uint256 number of tokens to be minted.
     */
    function _issue(address _to, uint256 _fee, uint256 _numberOfTokens) public {
        require(_to != address(0));

        deckRepository.increaseTotalDecksCount();
        _addDeckTo(_to, deckRepository.numberOfTotalDecks());

        deckRepository.increaseAllDecksIndex();
        deckRepository.increaseAllDeckIds();

        deckRepository.addToDeckStructs(deckRepository.numberOfTotalDecks(), _to);

        for (uint256 i = 0; i < _numberOfTokens; i++) {
            cardRepository.increaseTotalTokensCount();
            _mint(_to, cardRepository.numberOfTotalTokens(), deckRepository.numberOfTotalDecks(), _fee);
            deckRepository.addToDeckTokenIds(deckRepository.numberOfTotalDecks(), cardRepository.numberOfTotalTokens());
        }

        emit DeckIssue(_to, deckRepository.numberOfTotalDecks());
    }

    /**
     * @dev Returns the discounted royalty fee of token in wei.
     * @param _matchedTokensCount uint256 representing the tokens owned by the buyer.
     * @return uint256 standard royalty fee in wei.
     */

    function _calculateDiscountedFee(uint256 _matchedTokensCount, uint256 _standardFee) private pure returns (uint256) {
        uint x = 2 ** (_matchedTokensCount * 100 / 50);
        uint m = (10 ** _matchedTokensCount) / x;
        uint p = m / 2 ** _matchedTokensCount;
        uint c = ceil(p);
        uint fact = c / 1000;
        uint n;
        if (fact == 0) {
            n = 1000 - p;
        } else {
            n = (1000 * fact) - p;
        }

        uint count = Strings.utfStringLength(Strings.uintToString(fact)) - 1;
        return (_standardFee * n) / (1000 * (100 ** count));
    }

    function ceil(uint a) private pure returns (uint) {
        string memory x = Strings.uintToString(a);
        uint256 length = Strings.utfStringLength(x);
        string memory s = "1";
        for (uint i = 0; i < length; i++) {
            s = Strings.strConcat(s, "0");
        }
        uint m = Strings.stringToUint(s);
        return m;
    }
}