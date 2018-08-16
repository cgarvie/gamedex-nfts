const { shouldBehaveLikeERC721BasicToken } = require('./ERC721BasicToken.behavior');
const { shouldBehaveLikeMintAndBurnERC721Token } = require('./ERC721MintBurn.behavior');

const BigNumber = web3.BigNumber;
const CardRepository = artifacts.require('CardRepository.sol');
const ERC721TokenMock = artifacts.require('ERC721TokenMock.sol');

const creator = web3.eth.accounts[0]

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('ERC721TokenMock', function (accounts) {
  beforeEach(async function () {
    this.cardRepo = await CardRepository.new({ from: creator });
    this.token = await ERC721TokenMock.new(this.cardRepo.address, { from: creator });
    await this.cardRepo.transferOwnership(this.token.address, { from: creator })
  });

  shouldBehaveLikeERC721BasicToken(accounts);
  shouldBehaveLikeMintAndBurnERC721Token(accounts);
});
