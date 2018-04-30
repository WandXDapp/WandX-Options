pragma solidity ^0.4.23;

interface IDerivativeFactory {

/**
 * @dev Function use to create the new option contract
 * @param _baseToken Address of the Base token
 * @param _quoteToken Address of the Quote token
 * @param _strikePrice Price at which buyer will obligate to buy the base token
 * @param _blockTimestamp Unix timestamp to expire the option
 */
function createNewOption(
    address _baseToken,
    address _quoteToken,
    uint256 _strikePrice,
    uint256 _blockTimestamp
) 
external;

}