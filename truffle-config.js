module.exports = {
  networks: {
      development: {
          host: "localhost",
          port: 8545, // Using ganache as development network
          network_id: "*",
          gas: 4698712,
          gasPrice: 25000000000
      }
  },
  solc: {
      optimizer: {
          enabled: true,
          runs: 200
      }
  }
};