pragma solidity ^0.4.18;

contract OptionDumper {

    function OptionDumper() public {
    } 

   function dumpOption () public returns(bool) {
        // Selfdestruct  
        selfdestruct(address(this));
        return true;
    }
}