pragma solidity 0.4.24;

import "./tokens/ERC897434Token.sol";


contract GDXCard is ERC897434Token {

    /**
    * @dev Constructor function.
    * @param _deckRepo Address of storage contract DeckRepository.
    * @param _cardRepo Address of storage contract CardRepository.
    */
    constructor(address _deckRepo, address _cardRepo) ERC897434Token(_deckRepo, _cardRepo) public {
        
    }

    /**
     * @dev Function to issue a new deck.
     * Can only be executed by the owner of the contract.
     * @param _to address the beneficiary that will own the issued deck.
     * @param _fee uint256 royalty fee for the tokens.
     * @param _numberOfTokens uint256 number of tokens to be minted.
     */
    function issue(address _to, uint256 _fee, uint256 _numberOfTokens) public onlyOwner {
        require(_to != address(0));

        _addDeckTo(_to);

        for (uint256 i = 0; i < _numberOfTokens; i++) {
            cardRepository.increaseTotalTokensCount();
            _mint(_to, cardRepository.numberOfTotalTokens(), deckRepository.numberOfTotalDecks(), _fee);
            deckRepository.setDeckToTokens(deckRepository.numberOfTotalDecks(), cardRepository.numberOfTotalTokens());
        }

        emit DeckIssue(_to, deckRepository.numberOfTotalDecks());
    }

    /**
     * @dev Transfer storage rights to another address.
     * Can only be called by the contract owner.
     * @param _address address to transfer the rights.
     */
    function transferStorageOwnership(address _address) public onlyOwner {
        cardRepository.transferOwnership(_address);
        deckRepository.transferOwnership(_address);
    }

    /**
     * @dev Update address of ERC223 GDX contract address.
     * Can only be called by the contract owner.
     * @param _erc223 address of the GDX token.
     */
    function updateERC223TokenAddress(address _erc223) public onlyOwner {
        erc223 = ERC223(_erc223);
    }

    /**
     * @dev Kills the contract & Transfers all the funds to the owner.
     * Does not execute if this contract is the owner of the data contracts.
     * Can only be called by the contract owner.
     */
    function killContract() public onlyOwner {
        require(cardRepository.owner() != address(this));
        require(deckRepository.owner() != address(this));

        // Kill the contract now.
        selfdestruct(owner);
    }
}