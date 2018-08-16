pragma solidity 0.4.24;

import "./tokens/ERC897434Token.sol";


contract GDXDeck is ERC897434Token {

    /**
    * @dev Constructor function.
    * @param _deckRepo Address of storage contract DeckRepository.
    * @param _cardRepo Address of storage contract CardRepository.
    */
    constructor(address _erc223, address _deckRepo, address _cardRepo) ERC897434Token(_erc223, _deckRepo, _cardRepo) public {
        
    }

    /**
     * @dev Issues a new deck.
     * @param _fee Royalty fee of the tokens.
     * @param _numberOfTokens Number of tokens to issue.
     */
    function issueDeck(address _to, uint256 _fee, uint256 _numberOfTokens) public whenNotPaused {
        _issue(_to, _fee, _numberOfTokens);
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