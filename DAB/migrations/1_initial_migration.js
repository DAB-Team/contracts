var Migrations = artifacts.require("./helper/Migrations.sol");

module.exports = function(deployer) {

  deployer.deploy(Migrations, {gas: 4700000});
};
