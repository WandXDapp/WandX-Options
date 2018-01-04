// Governanace of this contract need to be decided whether it be operated by the single wandx entity
// or it will be more decentralized by adding the vote scheme for the changes in the operator contract
// suggestion are present in the dydx white paper 

pragma solidity ^0.4.18;

import './interfaces/IDerivativeOperator.sol';

contract DerivativeOperator is IDerivativeOperator {

    struct OptionsData {
        bool status;
        uint256 expirationDate;
    } 

    // mapping to track the list of options created by any writer 
    mapping(address => OptionsData) optionsForWriter;

    // constructor for the derivative contract
    function DerivativeOperator() {
        // ...
    }

     function createNewOption(
        address baseToken, 
        address quoteToken, 
        uint256 strikePrice,
        uint256 expirationDate
    ) public 
      returns (bool) 
      {
          //
      }

// function to add the new clones of the options before the expiration time
    function generateCloneOption(address _optionAddress, uint256 _number) public returns (bool);

}