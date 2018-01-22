pragma solidity ^0.4.18;

interface IProxy {

    function distributeStakes(address _to, uint256 _amount) public returns (bool success);

    function withdrawal() public returns (bool success);
}