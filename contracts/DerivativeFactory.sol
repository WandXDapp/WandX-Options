pragma solidity ^0.4.18;

/**
 * @notice  Governanace of this contract need to be decided whether it be operated by the single wandx entity
            or it will be more decentralized by adding the vote scheme for the changes in the operator contract
 */

import './interfaces/IDerivativeFactory.sol';
import './interfaces/IOption.sol';
import './Option.sol';

contract DerivativeFactory is IDerivativeFactory {

    struct OptionsData {
        bool expiryStatus;
        uint256 blockNoExpiry;  // Block No.
        address owner;
    } 

    // mapping to track the list of options created by any writer 
    mapping(address => OptionsData) public listOfOptions;

    event OptionCreated(address _baseToken, address _quoteToken, uint256 _blockNoExpiry, address indexed _creator);
    // constructor for the derivative contract
    function DerivativeFactory() public {
       
    }

    function createNewOption(address _baseToken, address _quoteToken, uint256 _strikePrice, uint256 _blockNoExpiry) 
    public 
    returns (bool) 
    {
        require(_blockNoExpiry > now);
        // Before creation creator should have to pay the service fee to wandx Platform
        address optionAddress = new Option(_baseToken, _quoteToken, _strikePrice, _blockNoExpiry, msg.sender);    
        listOfOptions[optionAddress] = OptionsData(false,_blockNoExpiry,msg.sender);
        return true;
    }

}