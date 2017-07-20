1. Add Plan in DABFormula

2. Split Deposit and Credit Contract into two separate contract for gas limit and simplification.

3. Add token functions to operation controller

4. Add DABDepositAgent.sol DABCreditAgent.sol, DABDepositAgent has depositTokenController,
    DABCreditAgent has CreditTokenController, subCreditTokenController, discreditTokenController.

5. Both of DABDepositAgent.sol and DABCreditAgent.sol are owned by
 DAB

6. DABCreditAgent: Add a API to enable DABDepositAgent to issue creditToken

7. DAB are uniformed interface of DABDepositAgent.sol and DABCreditAgent.sol.

8. DAB are owned by DAO, while DAO is owned by itself.

9. Write DAO and standard Proposal.

10. 10% cash fee should be paid to DepositAgent.

11. time limit of repaying credit token.

