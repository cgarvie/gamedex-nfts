pragma solidity 0.4.24;

import "./tokens/ERC897434Token.sol";


contract CardOwnership is ERC897434Token {

    /**
    * @dev Constructor function.
    * @param _erc20Address Address of ERC-20 token contract.
    */
    constructor(address _erc20Address) ERC897434Token(_erc20Address) public {
        
    }

    /**
     * @dev Gets a deck.
     * @param _deckId ID of deck.
     * @return address Issuer of deck.
     * @return uint256[] List of token IDs.
     */
    function getDeck(uint256 _deckId) public view returns(address, uint256[]) {
        return (deckRepository.getDeckIssuer(_deckId), deckRepository.getListOfTokenIds(_deckId));
    }

    /**
     * @dev Gets a token.
     * @param _tokenId ID of deck.
     * @return uint256 ID of token.
     * @return uint256 ID of deck the token belongs to.
     * @return address Owner of token.
     * @return uint256 Royalty fee of token.
     */
    function getToken(uint256 _tokenId) public view returns(uint256, uint256, address, uint256) {
        return (_tokenId, cardRepository.getDeckIdOfToken(_tokenId), cardRepository.tokenOwner(_tokenId), cardRepository.getRoyaltyFee(_tokenId));
    }

    /**
     * @dev Issues a new deck.
     * @param _fee Royalty fee of the tokens.
     * @param _numberOfTokens Number of tokens to issue.
     */
    function issueDeck(uint256 _fee, uint256 _numberOfTokens) public whenNotPaused {
        _issue(msg.sender, _fee, _numberOfTokens);
    }

    /**
     * @dev Transfer storage rights to another address.
     * Can only be called by the contract owner.
     * @param _contractAddress address to transfer the rights.
     */
    function transferStorageOwnership(address _contractAddress) public onlyOwner {
        cardRepository.transferOwnership(_contractAddress);
        deckRepository.transferOwnership(_contractAddress);
    }

    /**
     * @dev Kills the contract & Transfers all the funds to the owner.
     * Does not execute if this contract is the owner of the data contracts.
     * Can only be called by the contract owner.
     */
    function killContract() public onlyOwner {
        require(cardRepository.owner() != address(this));

        // Kill the contract now
        selfdestruct(owner);
    }
}