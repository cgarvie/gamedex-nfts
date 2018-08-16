pragma solidity 0.4.24;

import "../control/Ownable.sol";
import "../libraries/SafeMath.sol";


contract CardRepository is Ownable {

    using SafeMath for uint256;

    // Card struct
    struct Card {
        uint256 id;
        uint256 deckId;
        uint256 royaltyFee;
    }

    // Token name.
    string public name_ = "GDXCard";

    // Token symbol.
    string public symbol_ = "GDXC";

    // Token metadata base URI.
    string public tokenMetadataBaseURI = "https://www.api.gamedex.com/";

    // uint256 variable to track IDs of tokens.
    uint256 public numberOfTotalTokens;

    // Array with all token ids, used for enumeration.
    uint256[] public allTokens;

    // Mapping from token ID to token struct.
    mapping(uint256 => Card) public tokenStructs;

    // Mapping from token ID to owner.
    mapping(uint256 => address) public tokenOwner;

    // Mapping from token ID to approved address.
    mapping(uint256 => address) public tokenApprovals;

    // Mapping from owner to number of owned token.
    mapping(address => uint256) public ownedTokensCount;

    // Mapping from owner to operator approvals.
    mapping(address => mapping(address => bool)) public operatorApprovals;

    // Mapping from owner to list of owned token IDs.
    mapping(address => uint256[]) public ownedTokens;

    // Mapping from token ID to index of the owner tokens list.
    mapping(uint256 => uint256) public ownedTokensIndex;

    // Mapping from token id to position in the allTokens array.
    mapping(uint256 => uint256) public allTokensIndex;

    // Optional mapping for token URIs.
    mapping(uint256 => string) public tokenURIs;

    /**
     * @dev Gets the total supply of the tokens.
     * @return uint256 Total supply.
     */
    function getTotalSupply() public view returns (uint256) {
        return allTokens.length;
    }

    /**
     * @dev Gets total count of ownedTokens array.
     * @param _owner Owner of the token.
     * @return uint256 Owned tokens.
     */
    function getOwnedTokensCount(address _owner) public view returns (uint256) {
        return ownedTokens[_owner].length;
    }

    /**
     * @dev Gets last index of ownedTokens array.
     * @param _owner Owner of the token.
     * @return uint256 Index of token.
     */
    function getLastOwnedTokensIndex(address _owner) public view returns (uint256) {
        return ownedTokens[_owner].length.sub(1);
    }

    /**
     * @dev Gets last index of allTokens array.
     * @return uint256 Index of token.
     */
    function getLastAllTokensIndex() public view returns (uint256) {
        return allTokens.length.sub(1);
    }

    /**
     * @dev Gets ID of the deck the token belongs to.
     * @param _tokenId ID of token.
     * @return uint256 Deck ID.
     */
    function getDeckIdOfToken(uint256 _tokenId) public view returns (uint256) {
        return tokenStructs[_tokenId].deckId;
    }

    /**
     * @dev Gets royalty fee of the token.
     * @param _tokenId ID of token.
     * @return uint256 Royalty fee.
     */
    function getRoyaltyFee(uint256 _tokenId) public view returns (uint256) {
        return tokenStructs[_tokenId].royaltyFee;
    }

    /**
     * @dev Gets list of IDs of owned tokens.
     * @param _owner Owner of token.
     * @return uint256[] List of IDs of tokens.
     */
    function getListOfOwnedTokens(address _owner) public view returns (uint256[]) {
        return ownedTokens[_owner];
    }

    /**
     * @dev Sets name of the token.
     * @param _name Name of token.
     */
    function setName(string _name) public onlyOwner {
        name_ = _name;
    }

    /**
     * @dev Sets symbol of the token.
     * @param _symbol Symol of token.
     */
    function setSymbol(string _symbol) public onlyOwner {
        symbol_ = _symbol;
    }

    /**
     * @dev Sets spending approval for a token.
     * @param _to Address of spender.
     * @param _tokenId ID of token.
     */
    function setTokenApproval(address _to, uint256 _tokenId) public onlyOwner {
        tokenApprovals[_tokenId] = _to;
    }

    /**
     * @dev Sets operator approvals.
     * @param _from Address of token owner.
     * @param _to Address the approval is granted to.
     * @param _approved whether approved or not.
     */
    function setOperatorApproval(address _from, address _to, bool _approved) public onlyOwner {
        operatorApprovals[_from][_to] = _approved;
    }

    /**
     * @dev Sets owner of token.
     * @param _owner Address of token owner.
     * @param _tokenId Token ID to set the ownership of.
     */
    function setTokenOwner(address _owner, uint256 _tokenId) public onlyOwner {
        tokenOwner[_tokenId] = _owner;
    }

    /**
     * @dev Sets URI of token.
     * @param _tokenId ID of token to set URI of.
     * @param _uri URI to set.
     */
    function setTokenURI(uint256 _tokenId, string _uri) public onlyOwner {
        tokenURIs[_tokenId] = _uri;
    }

    /**
     * @dev Sets base URI of token.
     * @param _uri Base URI to set.
     */
    function setTokenMetadataBaseURI(string _uri) public onlyOwner {
        tokenMetadataBaseURI = _uri;
    }

    /**
     * @dev Sets owned token index.
     * @param _tokenId ID of token.
     * @param _index Index to set.
     */
    function setOwnedTokenIndex(uint256 _tokenId, uint256 _index) public onlyOwner {
        ownedTokensIndex[_tokenId] = _index;
    }

    /**
     * @dev Sets owned token ID.
     * @param _owner Owner of token.
     * @param _index Index of token.
     * @param _tokenId ID to set.
     */
    function setOwnedTokenId(address _owner, uint256 _index, uint256 _tokenId) public onlyOwner {
        ownedTokens[_owner][_index] = _tokenId;
    }

    /**
     * @dev Sets ID of all tokens.
     * @param _index Index of token.
     * @param _tokenId ID to set.
     */
    function setAllTokenId(uint256 _index, uint256 _tokenId) public onlyOwner {
        allTokens[_index] = _tokenId;
    }

    /**
     * @dev Sets index of all tokens.
     * @param _tokenId ID of token.
     * @param _index Index to set.
     */
    function setAllTokenIndex(uint256 _tokenId, uint256 _index) public onlyOwner {
        allTokensIndex[_tokenId] = _index;
    }

    /**
     * @dev Increases count of owned tokens.
     * @param _owner Address to increase the count for.
     */
    function increaseOwnedTokensCount(address _owner) public onlyOwner {
        ownedTokensCount[_owner] = ownedTokensCount[_owner].add(1);
    }

    /**
     * @dev Increases index of allTokensIndex array.
     * @param _tokenId .
     */
    function increaseAllTokensIndex(uint256 _tokenId) public onlyOwner {
        allTokensIndex[_tokenId] = allTokens.length;
    }

    /**
     * @dev Increases total number of tokens.
     */
    function increaseTotalTokensCount() public onlyOwner {
        numberOfTotalTokens = numberOfTotalTokens.add(1);
    }

    /**
     * @dev Decreases count of owned tokens.
     * @param _owner Address to decrease the count for.
     */
    function decreaseOwnedTokensCount(address _owner) public onlyOwner {
        ownedTokensCount[_owner] = ownedTokensCount[_owner].sub(1);
    }

    /**
     * @dev Decreases length of owned tokens.
     * @param _owner Address to decrease the length for.
     */
    function decreaseOwnedTokensLength(address _owner) public onlyOwner {
        ownedTokens[_owner].length--;
    }

    /**
     * @dev Decreases length of all tokens.
     */
    function decreaseAllTokensLength() public onlyOwner {
        allTokens.length--;
    }

    /**
     * @dev Adds to ownedTokens array.
     * @param _owner Address of owner.
     * @param _tokenId Token ID to add.
     */
    function addToOwnedTokens(address _owner, uint256 _tokenId) public onlyOwner {
        ownedTokens[_owner].push(_tokenId);
    }

    /**
     * @dev Adds to allTokens array.
     * @param _tokenId Token ID to add.
     */
    function addToAllTokens(uint256 _tokenId) public onlyOwner {
        allTokens.push(_tokenId);
    }

    /**
     * @dev Adds to tokenStructs array.
     * @param _tokenId Token ID to add.
     * @param _deckId Deck ID to add.
     * @param _royaltyFee Token royalty fee to add.
     */
    function addToTokenStructs(uint256 _tokenId, uint256 _deckId, uint256 _royaltyFee) public onlyOwner {
        tokenStructs[_tokenId] = Card(_tokenId, _deckId, _royaltyFee);
    }

    /**
     * @dev Adds token.
     * @param _owner Owner of token.
     * @param _tokenId Token ID to add.
     */
    function addToken(address _owner, uint256 _tokenId) public onlyOwner {
        uint256 length = getOwnedTokensCount(_owner);
        addToOwnedTokens(_owner, _tokenId);
        setOwnedTokenIndex(_tokenId, length);
    }

    /**
     * @dev Deletes token's metadata.
     * @param _tokenId ID of token.
     */
    function deleteTokenURI(uint256 _tokenId) public onlyOwner {
        if (bytes(tokenURIs[_tokenId]).length != 0) {
            delete tokenURIs[_tokenId];
        }
    }

    /**
     * @dev Deletes token in tokenStructs array.
     * @param _tokenId ID of token.
     */
    function deleteTokenStruct(uint256 _tokenId) public onlyOwner {
        delete tokenStructs[_tokenId];
    }
}