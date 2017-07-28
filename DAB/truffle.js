module.exports = {
  networks: {
    rinkeby: {
      host: "localhost",
      port: 8545,
      network_id: "*",
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
      network_id: "*"
    },

    testrpc: {
      host: "localhost",
      port: 8545,
      network_id: 10,
      gasPrice: 24000000000
    }
  }
};
