# DAB
### Testing

Tests are included and can be run on using [truffle](https://github.com/trufflesuite/truffle) and [testrpc](https://github.com/ethereumjs/testrpc).

    brew install npm
    npm install -g truffle
    npm install -g ethereumjs-testrpc

#### Prerequisites

    node v8.1.3+
    npm v5.3.0+
    truffle v3.4.5+
    testrpc v4.0.1+


#### Test and Migration on Different Ethereum Clients

##### Testrpc

Test in the development period.

To run the test, execute the following commands from the project's root folder.

    npm start
    npm test

##### Dev(Private Network)

Alpha test on private network.

To deploy, execute the following commands from the project's truffle folder.

    geth --dev --rpc --rpcport 8545 --rpcaddr 127.0.0.1 --rpcapi="eth,net,web3" --mine --minerthreads=1 --unlock <Account>
    truffle migrate --network dev

##### Rinkeby

Beta test on Rinkeby network.

To deploy, execute the following commands from the project's truffle folder.

    geth --rinkeby --rpc --rpcport 8545 --rpcaddr 127.0.0.1 --rpcapi="eth,net,web3" --unlock <Account>
    truffle migrate --network rinkeby

You can get the Ether from [https://www.rinkeby.io](https://www.rinkeby.io)

##### Live

To operate on the main net of Ethereum.

To deploy, execute the following commands from the project's truffle folder.

    geth --rpc --rpcport 8545 --rpcaddr 127.0.0.1 --rpcapi="eth,net,web3" --unlock <Account>
    truffle migrate --network live

### Configuration

The deployer does some configurations after migration, the logic is like codes below.

        // Configure for Tokens
        await DepositToken.transferOwnership(DepositTokenController.address);
        await DepositTokenController.acceptTokenOwnership();
        await CreditToken.transferOwnership(CreditTokenController.address);
        await CreditTokenController.acceptTokenOwnership();
        await SubCreditToken.transferOwnership(SubCreditTokenController.address);
        await SubCreditTokenController.acceptTokenOwnership();
        await DiscreditToken.transferOwnership(DiscreditTokenController.address);
        await DiscreditTokenController.acceptTokenOwnership();

        // Configure for Controllers
        await DepositTokenController.transferOwnership(DABDepositAgent.address);
        await DABDepositAgent.acceptDepositTokenControllerOwnership();
        await CreditTokenController.transferOwnership(DABCreditAgent.address);
        await DABCreditAgent.acceptCreditTokenControllerOwnership();
        await SubCreditTokenController.transferOwnership(DABCreditAgent.address);
        await DABCreditAgent.acceptSubCreditTokenControllerOwnership();
        await DiscreditTokenController.transferOwnership(DABCreditAgent.address);
        await DABCreditAgent.acceptDiscreditTokenControllerOwnership();

        // Configure for Agents, WalletFactory and DAB
        await DABCreditAgent.setDepositAgent(DABDepositAgent.address);
        await DABDepositAgent.transferOwnership(DAB.address);
        await DAB.acceptDepositAgentOwnership();
        await DABCreditAgent.transferOwnership(DAB.address);
        await DAB.acceptCreditAgentOwnership();
        await DABWalletFactory.transferOwnership(DAB.address);
        await DAB.setDABWalletFactory(DABWalletFactory.address);
        await DAB.acceptDABWalletFactoryOwnership();
        await DAB.addLoanPlanFormula(HalfAYearLoanPlanFormula.address);
        await DAB.addLoanPlanFormula(AYearLoanPlanFormula.address);
        await DAB.addLoanPlanFormula(TwoYearLoanPlanFormula.address);
        await DAB.activate();
