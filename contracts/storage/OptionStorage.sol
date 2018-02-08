pragma solidity ^0.4.18;

contract OptionStorage {
    
    mapping (bytes32 => uint256) public localUintVariables;
    mapping (bytes32 => address) public localAddressVariables;

    struct OptionsData {
        bool expiryStatus;
        uint256 blockNoExpiry;  // Block No.
        address owner;
    } 

    // mapping to track the list of options created by any writer 
    mapping(address => OptionsData) public listOfOptions;


    /////////////////////////
    /// Set Functions
    ////////////////////////

    function setUintValues(bytes32 _name, uint256 _value) public {
        localUintVariables[_name] = _value;
    }

    function setAddressValues(bytes32 _name, address _value) public {
        localAddressVariables[_name] = _value;
    }

    function setOptionFactoryData(bool _status, uint256 _blockNoExpiry, address _owner, address _optionAddress) public {
        listOfOptions[_optionAddress] = OptionsData(_status, _blockNoExpiry, _owner);
    }

    ////////////////////////
    /// Get Functions
    ////////////////////////

    function getUintValues(bytes32 _name) public returns(uint256) {
        return localUintVariables[_name];
    }

    function getAddressValues(bytes32 _name) public returns(address) {
        return localAddressVariables[_name];
    }


}