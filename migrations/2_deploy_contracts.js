var DeckRepository = artifacts.require("./DeckRepository.sol");
var CardRepository = artifacts.require("./CardRepository.sol");

var GDXCard = artifacts.require("./GDXCard.sol");
var Strings = artifacts.require("./strings/Strings.sol");

module.exports = function(deployer) {
    return deployer.deploy(DeckRepository).then(() => {
        return deployer.deploy(CardRepository).then(() => {
            return deployer.deploy(Strings).then(() => {
                deployer.link(Strings, GDXCard);
                return deployer.deploy(GDXCard, DeckRepository.address, CardRepository.address)
            });
        });
    });
};