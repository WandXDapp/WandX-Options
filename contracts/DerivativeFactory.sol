// Governanace of this contract need to be decided whether it be operated by the single wandx entity
// or it will be more decentralized by adding the vote scheme for the changes in the operator contract
// suggestion are present in the dydx white paper 

pragma solidity ^0.4.18;

import './interfaces/IDerivativeFactory.sol';
import './interfaces/IOption.sol';
import './Option.sol';

contract DerivativeFactory is IDerivativeFactory {

    IOption public callOption;

    struct OptionsData {
        bool expiryStatus;
        uint256 expirationDate;
        address owner;
    } 

    // mapping to track the list of options created by any writer 
    mapping(address => OptionsData) public listOfOptions;

    event OptionCreated(address _baseToken, address _quoteToken, uint256 _expirationDate, address indexed _creator);
    // constructor for the derivative contract
    function DerivativeFactory(address _callOptionAddress) public {
        require(_callOptionAddress != address(0));
        callOption = IOption(_callOptionAddress);
    }

    function createNewOption(address _baseToken, address _quoteToken, uint256 _strikePrice, uint256 _expirationDate) 
    public 
    returns (bool) 
    {
        require(_expirationDate > now);
        // Before creation creator should have to pay the service fee to wandx Platform
        address optionAddress = new Option(_baseToken, _quoteToken, _strikePrice, _expirationDate, msg.sender);    
        listOfOptions[optionAddress] = OptionsData(false,_expirationDate,msg.sender);
    }

// // function to add the new clones of the options before the expiration time
//     function generateCloneOption(address _optionAddress, uint256 _number) public returns (bool){

//     }

}