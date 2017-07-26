module.exports = {
  networks: {
    testnet: {
      network_id: '*',
      host: "localhost",
      port: 8545   // Different than the default below
    },
    main: {
      network_id: 1,
      host: "localhost",
      port: 8545   // Different than the default below
    },
    testrpc: {
      host: "localhost",
      port: 8545,
      network_id: "10", // Match any network id
      gasPrice: 24000000000
    }
  }
};
