//var CardOwnership = artifacts.require("./CardOwnership.sol");
//
//var deckId
//var numberOfCardsIssued = 10
//var royaltyFee = 1000000000000000
//var tokenId = 1
//
//contract('CardOwnership', function(accounts) {
//  it("should issue a deck", function() {
//    var contractInstance;
//    return CardOwnership.deployed().then(function(instance) {
//      contractInstance = instance;
//      return contractInstance.issueDeck(royaltyFee, numberOfCardsIssued, {
//        from: accounts[0]
//      });
//    }).then(function(result) {
//      assert.equal(result.logs[numberOfCardsIssued].event, "DeckIssue", "Event emitted should be Issue")
//      deckId = result.logs[numberOfCardsIssued].args._deckId.toNumber()
//    })
//  });
//
//  it("should get a deck", function() {
//      var contractInstance;
//      return CardOwnership.deployed().then(function(instance) {
//        contractInstance = instance;
//        return contractInstance.getDeck(deckId, {
//          from: accounts[0]
//        });
//      }).then(function(result) {
//        assert.equal(result[1].length, numberOfCardsIssued, "Deck should have " + numberOfCardsIssued + " cards")
//        assert.equal(result[0], accounts[0], "The issuer address should be " + accounts[0])
//      })
//    });
//
//    it("should get token", function() {
//        var contractInstance;
//        return CardOwnership.deployed().then(function(instance) {
//            contractInstance = instance;
//            return contractInstance.getToken(tokenId, {
//              from: accounts[0]
//            });
//        }).then(function(result) {
//            console.log(result)
//        })
//    });
//});