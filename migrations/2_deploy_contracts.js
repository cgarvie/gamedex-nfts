var ERC897434Token = artifacts.require("./ERC897434Token.sol");
var Strings = artifacts.require("./strings/Strings.sol");

module.exports = function(deployer) {
    deployer.deploy(Strings);
    deployer.link(Strings, ERC897434Token)
    return deployer.deploy(ERC897434Token);
};