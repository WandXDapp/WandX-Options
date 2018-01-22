pragma solidity ^0.4.18;

interface IDerivativeFactory {

// function to create the options
    function createNewOption(address _baseToken, address _quoteToken, uint256 _strikePrice, uint256 _blockNoExpiry) 
    public 
    returns (bool); 

}