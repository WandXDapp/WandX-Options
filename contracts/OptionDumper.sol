pragma solidity ^0.4.18;

contract OptionDumper {
    
    address public proxyContract;

    function OptionDumper(address _proxy) public {
        require(_proxy != address(0));
        proxyContract = _proxy;
    } 

   function dumpOption () public {
        require(proxyContract == msg.sender);
        // Selfdestruct  
        selfdestruct(address(this));
    }
}