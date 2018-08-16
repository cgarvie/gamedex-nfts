pragma solidity ^0.4.24;

import "../interfaces/ERC721.sol";
import "../interfaces/ERC721Receiver.sol";
import "../libraries/SafeMath.sol";
import "../libraries/AddressUtils.sol";
import "../interfaces/SupportsInterfaceWithLookup.sol";
import "../data/CardRepository.sol";
import "../control/Pausable.sol";
import "../libraries/Strings.sol";


/**
 * @title Full ERC721 Token
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Token is ERC721, Pausable, SupportsInterfaceWithLookup {

    using AddressUtils for address;

    // Reference to CardRepository storage contract.
    CardRepository public cardRepository;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

    /**
     * @dev Constructor function
     */
    constructor(address _cardRepo) public {
        cardRepository = CardRepository(_cardRepo);

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(InterfaceId_ERC721);
        _registerInterface(InterfaceId_ERC721Enumerable);
        _registerInterface(InterfaceId_ERC721Metadata);
    }
    
    /**
    * @notice Gets the name of the token.
    * @return string representing the name of the token.
    */
    function name() external view returns (string) {
        return cardRepository.name_();
    }

    /**
    * @notice Gets the symbol of the token.
    * @return string representing the symbol of the token.
    */
    function symbol() external view returns (string) {
        return cardRepository.symbol_();
    }

    /**
    * @notice Gets the total amount of tokens stored by the contract.
    * @return uint256 representing the total amount of tokens.
    */
    function totalSupply() public view returns (uint256) {
        return cardRepository.getTotalSupply();
    }

    /**
     * @dev Returns an URI for a given token ID.
     * Throws if the token ID does not exist. May return an empty string.
     * @param _tokenId uint256 ID of the token to query.
     */
    function tokenURI(uint256 _tokenId) public view returns (string) {
        require(exists(_tokenId));
        return Strings.strConcat(cardRepository.tokenMetadataBaseURI(), cardRepository.tokenURIs(_tokenId));
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner address to query the balance of.
     * @return uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != 0);
        return cardRepository.ownedTokensCount(_owner);
    }

    /**
     * @dev Gets the owner of the specified token ID.
     * @param _tokenId uint256 ID of the token to query the owner of.
     * @return owner address currently marked as the owner of the given token ID.
     */
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = cardRepository.tokenOwner(_tokenId);
        require(owner != address(0));
        return owner;
    }

    /**
     * @dev Returns whether the specified token exists.
     * @param _tokenId uint256 ID of the token to query the existence of.
     * @return whether the token exists.
     */
    function exists(uint256 _tokenId) public view returns (bool) {
        address owner = cardRepository.tokenOwner(_tokenId);
        return owner != address(0);
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set.
     * @param _tokenId uint256 ID of the token to query the approval of.
     * @return address currently approved for the given token ID.
     */
    function getApproved(uint256 _tokenId) public view returns (address) {
        return cardRepository.tokenApprovals(_tokenId);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID
     * @param _spender address of the spender to query
     * @param _tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     *  is an operator of the owner, or is the owner of the token
     */
    function isApprovedOrOwner(
        address _spender,
        uint256 _tokenId
    )
    internal
    view
    returns (bool)
    {
        address owner = ownerOf(_tokenId);
        // Disable solium check because of
        // https://github.com/duaraghav8/Solium/issues/175
        // solium-disable-next-line operator-whitespace
        return (
        _spender == owner ||
        getApproved(_tokenId) == _spender ||
        isApprovedForAll(owner, _spender)
        );
    }

    /**
     * @dev Tells whether an operator is approved by a given owner.
     * @param _owner owner address which you want to query the approval of.
     * @param _operator operator address which you want to query the approval of.
     * @return bool whether the given operator is approved by the given owner.
     */
    function isApprovedForAll(
        address _owner,
        address _operator
    )
    public
    view
    returns (bool)
    {
        return cardRepository.operatorApprovals(_owner, _operator);
    }

    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner.
     * @param _owner address owning the tokens list to be accessed.
     * @param _index uint256 representing the index to be accessed of the requested tokens list.
     * @return uint256 token ID at the given index of the tokens list owned by the requested address.
     */
    function tokenOfOwnerByIndex(
        address _owner,
        uint256 _index
    )
    public
    view
    returns (uint256)
    {
        require(_index < balanceOf(_owner));
        return cardRepository.ownedTokens(_owner, _index);
    }

    /**
     * @dev Gets the token ID at a given index of all the tokens in this contract.
     * Reverts if the index is greater or equal to the total number of tokens.
     * @param _index uint256 representing the index to be accessed of the tokens list.
     * @return uint256 token ID at the given index of the tokens list.
     */
    function tokenByIndex(uint256 _index) public view returns (uint256) {
        require(_index < totalSupply());
        return cardRepository.allTokens(_index);
    }

    /**
     * @dev Function to update tokenMetadataBaseURI.
     * @param _newBaseURI Updated URI.
     */
    function setTokenMetadataBaseURI(string _newBaseURI) external onlyOwner {
        cardRepository.setTokenMetadataBaseURI(_newBaseURI);
    }

    /**
     * @dev Internal function to set the token URI for a given token.
     * Reverts if the token ID does not exist.
     * @param _tokenId uint256 ID of the token to set its URI.
     * @param _uri string URI to assign.
     */
    function setTokenURI(uint256 _tokenId, string _uri) public onlyOwner {
        require(exists(_tokenId));
        cardRepository.setTokenURI(_tokenId, _uri);
    }

    /**
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param _to address to be approved for the given token ID
     * @param _tokenId uint256 ID of the token to be approved
     */
    function approve(address _to, uint256 _tokenId) public {
        address owner = ownerOf(_tokenId);
        require(_to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        cardRepository.setTokenApproval(_to, _tokenId);
        emit Approval(owner, _to, _tokenId);
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf
     * @param _to operator address to set the approval
     * @param _approved representing the status of the approval to be set
     */
    function setApprovalForAll(address _to, bool _approved) public {
        require(_to != msg.sender);
        cardRepository.setOperatorApproval(msg.sender, _to, _approved);
        emit ApprovalForAll(msg.sender, _to, _approved);
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
     * Requires the msg sender to be the owner, approved, or operator
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
    */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    public
    {
        require(isApprovedOrOwner(msg.sender, _tokenId));
        require(_to != address(0));

        _clearApproval(_from, _tokenId);
        _removeTokenFrom(_from, _tokenId);
        _addTokenTo(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     *
     * Requires the msg sender to be the owner, approved, or operator
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
    */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    public
    {
        // solium-disable-next-line arg-overflow
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg sender to be the owner, approved, or operator
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
    public
    {
        transferFrom(_from, _to, _tokenId);
        // solium-disable-next-line arg-overflow
        require(_checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target address
     * The call is not executed if the target address is not a contract
     * @param _from address representing the previous owner of the given token ID
     * @param _to target address that will receive the tokens
     * @param _tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return whether the call correctly returned the expected magic value
     */
    function _checkAndCallSafeTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
    internal
    returns (bool)
    {
        if (!_to.isContract()) {
            return true;
        }
        bytes4 retval = ERC721Receiver(_to).onERC721Received(
            msg.sender, _from, _tokenId, _data);
        return (retval == ERC721_RECEIVED);
    }

    /**
     * @dev Internal function to clear current approval of a given token ID
     * Reverts if the given address is not indeed the owner of the token
     * @param _owner owner of the token
     * @param _tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(address _owner, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _owner);
        if (cardRepository.tokenApprovals(_tokenId) != address(0)) {
            cardRepository.setTokenApproval(address(0), _tokenId);
        }
    }

    /**
     * @dev Internal function to add a token ID to the list of a given address
     * @param _to address representing the new owner of the given token ID
     * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenTo(address _to, uint256 _tokenId) internal {
        require(cardRepository.tokenOwner(_tokenId) == address(0));
        cardRepository.setTokenOwner(_to, _tokenId);
        cardRepository.increaseOwnedTokensCount(_to);

        uint256 length = cardRepository.getOwnedTokensCount(_to);
        cardRepository.addToOwnedTokens(_to, _tokenId);
        cardRepository.setOwnedTokenIndex(_tokenId, length);
    }

    /**
     * @dev Internal function to remove a token ID from the list of a given address
     * @param _from address representing the previous owner of the given token ID
     * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFrom(address _from, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from);
        cardRepository.decreaseOwnedTokensCount(_from);
        cardRepository.setTokenOwner(address(0), _tokenId);

        // To prevent a gap in the array, we store the last token in the index of the token to delete, and
        // then delete the last slot.
        uint256 tokenIndex = cardRepository.ownedTokensIndex(_tokenId);
        uint256 lastTokenIndex = cardRepository.getLastOwnedTokensIndex(_from);
        uint256 lastToken = cardRepository.ownedTokens(_from, lastTokenIndex);

        cardRepository.setOwnedTokenId(_from, tokenIndex, lastToken);
        // This also deletes the contents at the last position of the array
        cardRepository.decreaseOwnedTokensLength(_from);

        // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
        // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
        // the lastToken to the first position, and then dropping the element placed in the last position of the list

        cardRepository.setOwnedTokenIndex(_tokenId, 0);
        cardRepository.setOwnedTokenIndex(lastToken, tokenIndex);
    }

    /**
     * @dev Internal function to mint a new token
     * Reverts if the given token ID already exists
     * @param _to address the beneficiary that will own the minted token
     * @param _tokenId uint256 ID of the token to be minted by the msg.sender
     */
    function _mint(address _to, uint256 _tokenId, uint256 _deckId, uint256 _royaltyFee) internal {
        require(_to != address(0));
        _addTokenTo(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);

        cardRepository.increaseAllTokensIndex(_tokenId);
        cardRepository.addToAllTokens(_tokenId);
        cardRepository.addToTokenStructs(_tokenId, _deckId, _royaltyFee);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * @param _owner owner of the token to burn
     * @param _tokenId uint256 ID of the token being burned by the msg.sender
     */
    function _burn(address _owner, uint256 _tokenId) internal {
        _clearApproval(_owner, _tokenId);
        _removeTokenFrom(_owner, _tokenId);
        emit Transfer(_owner, address(0), _tokenId);

        // Clear metadata (if any)
        cardRepository.deleteTokenURI(_tokenId);

        // Delete struct.
        cardRepository.deleteTokenStruct(_tokenId);

        // Reorg all tokens array
        uint256 tokenIndex = cardRepository.allTokensIndex(_tokenId);
        uint256 lastTokenIndex = cardRepository.getLastAllTokensIndex();
        uint256 lastToken = cardRepository.allTokens(lastTokenIndex);

        cardRepository.setAllTokenId(tokenIndex, lastToken);
        cardRepository.setAllTokenId(lastTokenIndex, 0);

        cardRepository.decreaseAllTokensLength();
        cardRepository.setAllTokenIndex(_tokenId, 0);
        cardRepository.setAllTokenIndex(lastToken, tokenIndex);
    }
}
