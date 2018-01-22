pragma solidity ^0.4.18;

import './IERC20.sol';

interface IOption {

    function issueOption(uint256 _optionsOffered, uint256 _premium, uint256 _expiry) public;

    function incOffering(uint256 _extraOffering) public;

    function tradeOption(address _trader, uint256 _amount) external returns (bool);
    
    // function to complete the option
    function exerciseOption(address _trader, uint256 _amount) external returns (bool);

    function transfer(address _to, uint256 _value) public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    function balanceOf(address _owner) public view returns (uint256 balance);

    function approve(address _spender, uint256 _value) public returns (bool);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

} 