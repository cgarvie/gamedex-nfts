var DeckRepository = artifacts.require("./DeckRepository.sol");
var CardRepository = artifacts.require("./CardRepository.sol");

var GDXDeck = artifacts.require("./GDXDeck.sol");
var Strings = artifacts.require("./strings/Strings.sol");

module.exports = function(deployer) {
    return deployer.deploy(DeckRepository).then(() => {
        return deployer.deploy(CardRepository).then(() => {
            deployer.deploy(Strings);
            deployer.link(Strings, GDXDeck)
            return deployer.deploy(GDXDeck, DeckRepository.address, CardRepository.address)
        });
    });
};