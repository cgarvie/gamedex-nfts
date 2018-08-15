pragma solidity 0.4.24;

import "../interfaces/ERC897434.sol";
import "./ERC721Token.sol";
import "../interfaces/ERC20.sol";
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

    // Reference to GDX ERC20 contract.
    ERC20 public erc20Token;

    /**
    * @dev Constructor function
    * @param _erc20Address Address of ERC-20 token contract
    */
    constructor(address _erc20Address) ERC721Token() public {
        // deckRepository = new DeckRepository();
        // erc20Token = ERC20(_erc20Address);
    }

    /**
     * @dev Checks msg.sender can transfer a deck, by being issuer.
     * @param _deckId uint256 ID of the deck to validate.
     */
    modifier canTransferDeck(uint256 _deckId) {
        require(issuerOf(_deckId) == msg.sender);
        _;
    }

    /**
     * @dev Gets the deck ID at a given index of the decks list of the requested issuer.
     * @param _issuer address issued the decks list to be accessed.
     * @param _index uint256 representing the index to be accessed of the requested decks list.
     * @return uint256 deck ID at the given index of the decks list issued by the requested address.
     */
    function deckOfIssuerByIndex(
        address _issuer,
        uint256 _index
    )
    public
    view
    returns (uint256)
    {
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
        return calculateDiscountedFee(matchedTokensCount, fee);
    }

    /**
     * @dev Returns the discounted royalty fee of token in wei.
     * @param _matchedTokensCount uint256 representing the tokens owned by the buyer.
     * @return uint256 standard royalty fee in wei.
     */

    function calculateDiscountedFee(uint256 _matchedTokensCount, uint256 _standardFee) public pure returns (uint256) {
        uint x = 2 ** (_matchedTokensCount * 100 / 50);
        uint m = (10 ** _matchedTokensCount) / x;
//        uint p = 10 * m / 2 ** ++matchedTokensCount;
        uint p = m / 2 ** _matchedTokensCount;
        uint c = ceil(p);
        uint fact = c / 1000;
        uint n;
        if (fact == 0) {
            n = 1000 - p;
        } else {
            n = (1000 * fact) - p;
        }

        uint count = Strings.utfStringLength(Strings.uint2str(fact)) - 1;
        return (_standardFee * n) / (1000 * (100 ** count));
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible.
     * Requires the msg sender to be the owner, approved, or operator.
     * @param _from current owner of the token.
     * @param _to address to receive the ownership of the given token ID.
     * @param _tokenId uint256 ID of the token to be transferred.
    */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    public whenNotPaused
    canTransfer(_tokenId)
    {
        require(_from != address(0));
        require(_to != address(0));
        // Check to make sure the buyer has approved the GDX tokens for owner of the token.
        // uint256 tokensAllowed = erc20Token.allowance(_to, _from);
        // require(tokensAllowed >= royaltyFee(_to, _tokenId));

        _clearApproval(_from, _tokenId);
        _removeTokenFrom(_from, _tokenId);
        _addTokenTo(_to, _tokenId);

        // Transfer the royalty fee to the issuer of the token.
        // address issuer = deckRepository.getDeckIssuer(cardRepository.getDeckIdOfToken(_tokenId));
        // erc20Token.transferFrom(_from, issuer, tokensAllowed);

        emit Transfer(_from, _to, _tokenId);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address.
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     *
     * Requires the msg sender to be the owner, approved, or operator.
     * @param _from current owner of the token.
     * @param _to address to receive the ownership of the given token ID.
     * @param _tokenId uint256 ID of the token to be transferred.
    */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    public whenNotPaused
    canTransfer(_tokenId)
    {
        // solium-disable-next-line arg-overflow
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address.
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg sender to be the owner, approved, or operator.
     * @param _from current owner of the token.
     * @param _to address to receive the ownership of the given token ID.
     * @param _tokenId uint256 ID of the token to be transferred.
     * @param _data bytes data to send along with a safe transfer check.
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
    public whenNotPaused
    canTransfer(_tokenId)
    {
        transferFrom(_from, _to, _tokenId);
        // solium-disable-next-line arg-overflow
        require(_checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
    }

    /**
     * @dev Transfers the ownership of a given deck ID to another address.
     * Requires the msg sender to be the issuer.
     * @param _from current owner of the deck.
     * @param _to address to receive the ownership of the given deck ID.
     * @param _deckId uint256 ID of the deck to be transferred.
    */
    function transferDeck(
        address _from,
        address _to,
        uint256 _deckId
    )
    public whenNotPaused
    canTransferDeck(_deckId)
    {
        require(_from != address(0));
        require(_to != address(0));

        _removeDeckFrom(_from, _deckId);
        _addDeckTo(_to, _deckId);

        emit DeckTransfer(_from, _to, _deckId);
    }

    /**
     * @dev Internal function to add a token ID to the list of a given address.
     * @param _to address representing the new issuer of the given deck ID.
     * @param _deckId uint256 ID of the deck to be added to the decks list of the given address.
     */
    function _addDeckTo(address _to, uint256 _deckId) internal {
        deckRepository.addDeck(_deckId, _to);
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
     * @dev Internal function to remove a deck ID from the list of a given address.
     * @param _from address representing the previous issuer of the given deck ID.
     * @param _deckId uint256 ID of the deck to be removed from the decks list of the given address.
     */
    function _removeDeckFrom(address _from, uint256 _deckId) internal {
        deckRepository.removeDeckFrom(_from, _deckId);
    }

    /**
     * @dev Internal function to discard a specific deck.
     * Reverts if the deck does not exist.
     * @param _issuer issuer of the deck to discard.
     * @param _deckId uint256 ID of the deck being discarded by the msg.sender.
     */
    function _discard(address _issuer, uint256 _deckId) internal {
        _removeDeckFrom(_issuer, _deckId);
        emit DeckTransfer(_issuer, address(0), _deckId);

        deckRepository.discardDeck(_deckId);
    }

    function ceil(uint a) private pure returns (uint) {
        string memory x = Strings.uint2str(a);
        uint256 length = Strings.utfStringLength(x);
        string memory s = "1";
        for (uint i = 0; i < length; i++) {
            s = Strings.strConcat(s, "0");
        }
        uint m = Strings.stringToUint(s);
        return m;
    }
}