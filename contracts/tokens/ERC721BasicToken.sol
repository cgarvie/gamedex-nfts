pragma solidity 0.4.24;

import "../data/CardRepository.sol";
import "../interfaces/ERC721.sol";
import "../interfaces/ERC721Receiver.sol";
import "../libraries/AddressUtils.sol";
import "../interfaces/SupportsInterfaceWithLookup.sol";
import "../control/Pausable.sol";


/**
 * @title ERC721 Non-Fungible Token Standard basic implementation.
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721BasicToken is ERC721, Pausable, SupportsInterfaceWithLookup {

    using AddressUtils for address;

    // Reference to CardRepository storage contract.
    CardRepository public cardRepository;

    /**
    * @dev Constructor function.
    */
    constructor() public {
         cardRepository = new CardRepository();

         // register the supported interfaces to conform to ERC721 via ERC165.
         _registerInterface(cardRepository.InterfaceId_ERC721());
         _registerInterface(cardRepository.InterfaceId_ERC721Exists());
    }

    /**
     * @dev Guarantees msg.sender is owner of the given token.
     * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender.
     */
    modifier onlyOwnerOf(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender);
        _;
    }

    /**
     * @dev Checks msg.sender can transfer a token, by being owner, approved, or operator.
     * @param _tokenId uint256 ID of the token to validate.
     */
    modifier canTransfer(uint256 _tokenId) {
        require(isApprovedOrOwner(msg.sender, _tokenId));
        _;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner address to query the balance of.
     * @return uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0));
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
     * @dev Returns whether the given spender can transfer a given token ID.
     * @param _spender address of the spender to query.
     * @param _tokenId uint256 ID of the token to be transferred.
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
     * @dev Approves another address to transfer the given token ID.
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param _to address to be approved for the given token ID.
     * @param _tokenId uint256 ID of the token to be approved.
     */
    function approve(address _to, uint256 _tokenId) public {
        address owner = ownerOf(_tokenId);
        require(_to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        cardRepository.setTokenApproval(_to, _tokenId);
        emit Approval(owner, _to, _tokenId);
    }

    /**
     * @dev Sets or unsets the approval of a given operator.
     * An operator is allowed to transfer all tokens of the sender on their behalf.
     * @param _to operator address to set the approval.
     * @param _approved representing the status of the approval to be set.
     */
    function setApprovalForAll(address _to, bool _approved) public {
        require(_to != msg.sender);
        cardRepository.setOperatorApproval(msg.sender, _to, _approved);
        emit ApprovalForAll(msg.sender, _to, _approved);
    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param _to The address that will own the minted token.
     * @param _tokenId uint256 ID of the token to be minted by the msg.sender.
     */
    function _mint(address _to, uint256 _tokenId) internal {
        require(_to != address(0));
        _addTokenTo(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * @param _tokenId uint256 ID of the token being burned by the msg.sender.
     */
    function _burn(address _owner, uint256 _tokenId) internal {
        _clearApproval(_owner, _tokenId);
        _removeTokenFrom(_owner, _tokenId);
        emit Transfer(_owner, address(0), _tokenId);
    }

    /**
     * @dev Internal function to clear current approval of a given token ID.
     * Reverts if the given address is not indeed the owner of the token.
     * @param _owner owner of the token.
     * @param _tokenId uint256 ID of the token to be transferred.
     */
    function _clearApproval(address _owner, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _owner);
        if (cardRepository.tokenApprovals(_tokenId) != address(0)) {
            cardRepository.setTokenApproval(address(0), _tokenId);
            emit Approval(_owner, address(0), _tokenId);
        }
    }

    /**
     * @dev Internal function to add a token ID to the list of a given address.
     * @param _to address representing the new owner of the given token ID.
     * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address.
     */
    function _addTokenTo(address _to, uint256 _tokenId) internal {
        require(cardRepository.tokenOwner(_tokenId) == address(0));
        cardRepository.setTokenOwner(_to, _tokenId);
        cardRepository.increaseOwnedTokensCount(_to);
    }

    /**
     * @dev Internal function to remove a token ID from the list of a given address.
     * @param _from address representing the previous owner of the given token ID.
     * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address.
     */
    function _removeTokenFrom(address _from, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from);
        cardRepository.decreaseOwnedTokensCount(_from);
        cardRepository.setTokenOwner(address(0), _tokenId);
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target address.
     * The call is not executed if the target address is not a contract.
     * @param _from address representing the previous owner of the given token ID.
     * @param _to target address that will receive the tokens.
     * @param _tokenId uint256 ID of the token to be transferred.
     * @param _data bytes optional data to send along with the call.
     * @return whether the call correctly returned the expected magic value.
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
            _from, _tokenId, _data);
        return (retval == cardRepository.ERC721_RECEIVED());
    }
}