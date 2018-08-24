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
    constructor(address _deckRepo, address _cardRepo) ERC721Token(_cardRepo) public {
        deckRepository = DeckRepository(_deckRepo);
    }

    /**
     * @dev Returns the address of the issuer of the given deck ID.
     * Reverts if the returned address is 0x.
     * @param _deckId uint256 representing the ID of the deck.
     * @return address issuer of the deck.
     */
    function issuerOf(uint256 _deckId) public view returns (address) {
        return deckRepository.deckToIssuer(_deckId);
    }

    /**
     * @dev Returns the total supply of all the tokens in the deck.
     * @param _deckId uint256 representing the ID of the deck.
     * @return uint256 number of tokens issued in the deck.
     */
    function totalSupplyOf(uint256 _deckId) public view returns (uint256) {
        return deckRepository.getTotalSupply(_deckId);
    }

    /**
     * @dev Returns whether the deck exists.
     * @param _deckId uint256 representing the ID of the deck.
     * @return bool whether the deck exists.
     */
    function deckExists(uint256 _deckId) public view returns (bool) {
        address issuer = deckRepository.deckToIssuer(_deckId);
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
        address issuer = deckRepository.deckToIssuer(cardRepository.getDeckIdOfToken(_tokenId));
        uint256[] memory tokens = cardRepository.getListOfOwnedTokens(_buyer);
        uint256 matchedTokensCount = 0;

        for (uint256 i = 0; i < tokens.length; i++) {
            if (issuer == deckRepository.deckToIssuer(cardRepository.getDeckIdOfToken(_tokenId))) {
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
     * @dev Transfers the ownership of a given token ID to another address
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
     * Requires the msg sender to be the owner, approved, or operator
     * Requires the buyer of the card to first approve the same the number of GDX tokens as the royalty fee of the card to this contract.
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
     */
    function _addDeckTo(address _to) internal {
        require(deckRepository.deckToIssuer(deckRepository.getNextDeckId()) == address(0));

        deckRepository.increaseTotalDecksCount();
        deckRepository.setDeckToIssuer(deckRepository.numberOfTotalDecks(), _to);
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