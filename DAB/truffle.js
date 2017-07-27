module.exports = {
  networks: {
    rinkeby: {
      host: "localhost",
      port: 8545,
      network_id: 4,
      from: "0xa91ffe3ff91c784d871a800c291395d9ebb02f59"
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
