pragma solidity ^0.4.18;

import './IERC20.sol';

interface IOption {

// function to set the behaviour of the option -- 1 for call 0 for put 
    function setOptionBehaviour(uint8 _behaviour) public returns (bool);

    // function to complete the option
    function exerciseOption() external returns (bool);

} 