pragma solidity ^0.4.0;

import './DAB.sol';
import './Proposal.sol';

contract DAO is Owned{

    struct ProposalRecord{
        string proposalDecalre;
        string proposedDAOFunction;
        string proposedContractAddress;
        uint256 vote;
    }

    struct Vote{
        bool voted = false;
    }

    bool public isActive;
    DAB public dab;

    address[] registeredProposal;

    mapping (address => ProposalRecord) public proposalRecords;

    mapping (address => (address => Vote)) voteRecords;

    function DAO(DAB _dab){
        dab = _dab;
    }

    modifier active(){
        require(isActive == true);
        _;
    }

    modifier inactive(){
        require(isActive == false);
        _;
    }

    function activate() ownerOnly{
        dab.activate();
        trasferOwnership(this);
        acceptOwenership();
        isActive = true;
    }


    modifier validProposal(address _proposal){
    // check if _proposal is in registered proposal list
    }

    modifier dao(address _proposal, uint8 _supportRate){
    // get total vote
    // get vote for proposal
    // compare with _supportRate
    _;
    }

    function register(Proposal _proposal){
    // destroy 100 DPT in _proposal, error if not sufficient DPT in _proposal contract.
    // add to registered proposal list
    // a proposal only used for
        proposalRecords[_proposal].proposalDecalre = _proposal.proposalDecalre();
        proposalRecords[_proposal].proposedDAOFunction = _proposal.proposedDAOFunction();
        proposalRecords[_proposal].proposedContractAddress = _proposal.proposedContractAddress();
    }

    function transferDABOwnership(Proposal _proposal)
    valid(proposal)
    dao(address _proposal, uint8(80))
    {
        string proposedDAOFunction = _proposal.proposedDAOFunction();
        require(proposedDAOFunction == 'transferDABOwnership');
        address proposedContractAddress = _proposal.proposedContractAddress();
        DAB.transferOwnership(proposedContractAddress);
    }

    function setDABFormula(Proposal _proposal)
    valid(proposal)
    dao(address _proposal, uint8(80))
    {
        string proposedDAOFunction = _proposal.proposedDAOFunction();
        require(proposedDAOFunction == 'setDABFormula');
        address proposedContractAddress = _proposal.proposedContractAddress();
        dab.setDABFormula(proposedContractAddress);

    }


    function addLoanPlanFormula(Proposal _proposal)
    valid(proposal)
    dao(address _proposal, uint8(80))
    {
        string proposedDAOFunction = _proposal.proposedDAOFunction();
        require(proposedDAOFunction == 'addLoanPlanFormula');
        address proposedContractAddress = _proposal.proposedContractAddress();
        dab.addLoanPlanFormula(proposedContractAddress);

    }

    function vote(Proposal _proposal){
    // DPT balance of msg sender
    // can not vote twice
    // add to vote\[_proposal][]
        if (voteRecords[msg.sender][_proposal].voted == false){
            proposalRecords.vote += balanceOf(msg.sender);

        }

    }

    function acceptOwnership(Proposal _proposal)
    dao(address _proposal, uint8(50))
    {
        string proposedDAOFunction = _proposal.proposedDAOFunction();
        require(proposedDAOFunction == 'acceptOwnership');
        dab.acceptOwnership();
    }


}
