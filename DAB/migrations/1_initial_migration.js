var Migrations = artifacts.require("./helper/Migrations.sol");

module.exports = function(deployer) {

  deployer.deploy(Migrations, {gasLimit: 5000000});
};
