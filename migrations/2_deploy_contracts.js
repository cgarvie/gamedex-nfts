var CardOwnership = artifacts.require("./ERC897434Token.sol");
var Strings = artifacts.require("./strings/Strings.sol");

module.exports = function(deployer) {
    deployer.deploy(Strings);
    deployer.link(Strings, CardOwnership)
    return deployer.deploy(CardOwnership, "0x946b22d69d3407c2e30309587a8234940d47befe");
};