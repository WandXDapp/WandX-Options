pragma solidity ^0.4.18;

interface IDerivativeOperator {

// function to create the options
    function createNewOption(
        address baseToken, 
        address quoteToken, 
        uint256 strikePrice,
        uint256 expirationDate
    ) public returns (bool);

// function to add the new clones of the options before the expiration time
    function generateCloneOption(address _optionAddress, uint256 _number) public returns (bool);


}