pragma solidity ^0.4.0;

import './Owned.sol';
import './Math.sol';
import './interfaces/IDABFormula.sol';

contract DABAgent is Owned, Math{
    struct Reserve {
    uint256 balance;
    }

    struct Token {
    uint256 supply;         // total supply = issue - destroy
    uint256 circulation;    // supply minus those in contract
    uint256 price;          // price of token
    uint256 balance;    // virtual balance = (supply-circulation) * price
    uint256 currentCRR;  // current cash ratio of the token

    bool isReserved;   // true if reserve is enabled, false if not
    bool isPurchaseEnabled;         // is purchase of the smart token enabled with the reserve, can be set by the token owner
    bool isSet;                     // used to tell if the mapping element is defined
    }

    string public version = '0.1';

    uint256 maxStream = 100 ether;

    bool public isActive = false;

    address[] public tokenSet;

    mapping (address => Token) public tokens;   //  token addresses -> token data

    IDABFormula public formula;

    function DABAgent(IDABFormula _formula){
        formula = _formula;
    }


// validates a token address - verifies that the address belongs to one of the changeable tokens
    modifier validToken(address _address) {
        require(tokens[_address].isSet);
        _;
    }


// verifies that an amount is greater than zero
    modifier active() {
        require(isActive == true);
        _;
    }

// verifies that an amount is greater than zero
    modifier inactive() {
        require(isActive == false);
        _;
    }

// verifies that an amount is greater than zero
    modifier validAmount(uint256 _amount) {
        require(_amount > 0);
        _;
    }

// validates an address - currently only checks that it isn't null
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }


// verifies that the address is different than this contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }


/*
    @dev allows the owner to update the formula contract address

    @param _formula    address of a bancor formula contract
*/
    function setFormula(IDABFormula _formula)
    public
    ownerOnly
    notThis(_formula)
    validAddress(_formula)
    {
        require(_formula != formula);
        formula = _formula;
    }
}
