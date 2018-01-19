pragma solidity ^0.4.18;

import './IERC20.sol';

interface IOption {

    // function to complete the option
    function exerciseOption(address _trader, uint256 _amount) external returns (bool);

} 