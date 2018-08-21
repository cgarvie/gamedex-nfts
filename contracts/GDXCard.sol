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