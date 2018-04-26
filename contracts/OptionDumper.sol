pragma solidity ^0.4.23;

contract OptionDumper {

    constructor () public {
    } 

   function dumpOption () public returns(bool) {
        // Selfdestruct  
        selfdestruct(address(this));
        return true;
    }
}