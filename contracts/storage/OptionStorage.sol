pragma solidity ^0.4.18;

contract OptionStorage {
    
    struct OptionsData {
        bool expiryStatus;
        uint256 blockNoExpiry;  // Block No.
        address owner;
    } 

    // mapping to track the list of options created by any writer 
    mapping(address => OptionsData) public listOfOptions;

    mapping(bool => address[]) public optionAddresses;

    /////////////////////////
    /// Set Functions
    ////////////////////////


    ////////////////////////
    /// Get Functions
    ////////////////////////

    function getActiveOptions() view public returns (address[]) {
        return optionAddresses[true];
    }

    function getExpiredOptions() view public returns (address[]) {
        return optionAddresses[false];
    }

}