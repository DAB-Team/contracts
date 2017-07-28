module.exports = {
  networks: {
    rinkeby: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      gasPrice: 20000000000
    },

    main: {
      host: "localhost",
      port: 8545,
      network_id: 1
    },

    testrpc: {
      host: "localhost",
      port: 8545,
      network_id: 10,
      gasPrice: 24000000000
    }
  }
};
