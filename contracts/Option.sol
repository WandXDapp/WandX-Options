pragma solidity ^0.4.18;

import './interfaces/IOption.sol';
import './interfaces/IERC20.sol';

contract Option is IOption, IERC20 {

    address public writer;

// Constructor
    function Option( 
        address baseToken, 
        address quoteToken, 
        uint256 strikePrice,
        uint256 expirationDate,
        address writer
        ) public 
    {
        //
    }

    function setOptionBehaviour(uint8 _behaviour) public returns (bool) {
        //
    }  
    
    function exerciseOption() public returns (bool) {
        //
    }

    



}