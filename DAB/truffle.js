module.exports = {
  networks: {
    rinkeby: {
      host: "localhost",
      port: 8545,
      network_id: "4",
      gasPrice: 20000000000
    },

    live: {
      host: "localhost",
      port: 8545,
      network_id: 1
    },

    dev: {
      host: "localhost",
      port: 8545,
      network_id: "1"
    },

    testrpc: {
      host: "localhost",
      port: 8545,
      network_id: 10,
      gasPrice: 24000000000
    }
  }
};
