pragma solidity ^0.4.18;

/**
 * @notice  Governanace of this contract need to be decided whether it be operated by the single wandx entity
            or it will be more decentralized by adding the vote scheme for the changes in the operator contract
 */

import './interfaces/IDerivativeFactory.sol';
import './interfaces/IOption.sol';
import './Option.sol';
import './storage/OptionStorage.sol';
import './helpers/Ownable.sol';

contract DerivativeFactory is IDerivativeFactory, Ownable {

    OptionStorage Storage;

    event OptionCreated(address _baseToken, address _quoteToken, uint256 _blockNoExpiry, address indexed _creator);
    // constructor for the derivative contract
    function DerivativeFactory(address _storageAddress) public {
       Storage = OptionStorage(_storageAddress);
    }

    function createNewOption(address _baseToken, address _quoteToken, uint256 _strikePrice, uint256 _blockNoExpiry) 
    public 
    returns (bool) 
    {
        require(_blockNoExpiry > now);
        // Before creation creator should have to pay the service fee to wandx Platform
        address _optionAddress = new Option(_baseToken, _quoteToken, _strikePrice, _blockNoExpiry, msg.sender);    
        Storage.listOfOptions[_optionAddress] = Storage.OptionsData(false,_blockNoExpiry,msg.sender);
        return true;
    }

}