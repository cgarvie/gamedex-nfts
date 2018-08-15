pragma solidity 0.4.24;

import "./ERC721BasicToken.sol";
import "../interfaces/ERC721Enumerable.sol";
import "../interfaces/ERC721Metadata.sol";
import "../libraries/Strings.sol";
import "../interfaces/SupportsInterfaceWithLookup.sol";


/**
 * @title Full ERC721 Token
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Token is ERC721BasicToken, ERC721Enumerable, ERC721Metadata  {

     /**
    * @dev Constructor function.
    */
    constructor() public {
        // register the supported interfaces to conform to ERC721 via ERC165.
        // _registerInterface(cardRepository.InterfaceId_ERC721Enumerable());
        // _registerInterface(cardRepository.InterfaceId_ERC721Metadata());
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
        return Strings.strConcat(
            cardRepository.tokenMetadataBaseURI(),
            Strings.uint2str(_tokenId));
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
     * @dev Internal function to add a token ID to the list of a given address.
     * @param _to address representing the new owner of the given token ID.
     * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address.
     */
    function _addTokenTo(address _to, uint256 _tokenId) internal {
        super._addTokenTo(_to, _tokenId);
        cardRepository.addToken(_to, _tokenId);
    }

    /**
     * @dev Internal function to remove a token ID from the list of a given address.
     * @param _from address representing the previous owner of the given token ID.
     * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address.
     */
    function _removeTokenFrom(address _from, uint256 _tokenId) internal {
        super._removeTokenFrom(_from, _tokenId);
        cardRepository.removeToken(_from, _tokenId);
    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param _to address the beneficiary that will own the minted token.
     * @param _tokenId uint256 ID of the token to be minted by the msg.sender.
     */
    function _mint(address _to, uint256 _tokenId, uint256 _deckId, uint256 _royaltyFee) internal {
        _mint(_to, _tokenId);
        cardRepository.mintToken(_tokenId, _deckId, _royaltyFee);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * @param _owner owner of the token to burn.
     * @param _tokenId uint256 ID of the token being burned by the msg.sender.
     */
    function _burn(address _owner, uint256 _tokenId) internal {
        super._burn(_owner, _tokenId);
        cardRepository.burnToken(_tokenId);
    }
}