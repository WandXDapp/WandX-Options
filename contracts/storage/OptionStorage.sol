pragma solidity ^0.4.18;

import '../helpers/Ownable.sol';

contract OptionStorage is Ownable {
    
    address public optionFactory;

    struct OptionsData {
        bool expiryStatus;
        uint256 blockNoExpiry;  // Block No.
        address owner;
    } 

    // mapping to track the list of options created by any writer 
    mapping(address => OptionsData) public listOfOptions;
    mapping (bytes32 => uint256) public localUintVariables;
    mapping (bytes32 => address) public localAddressVariables;

    modifier onlyOptionFactory() {
        require(msg.sender == optionFactory);
        _;
    }

    function OptionStorage(address _ownerAddress) public {
        owner = _ownerAddress;
    }

    /////////////////////////
    /// Set Functions
    ////////////////////////

    function setUintValues(bytes32 _name, uint256 _value) public {
        localUintVariables[_name] = _value;
    }

    function setAddressValues(bytes32 _name, address _value) public {
        localAddressVariables[_name] = _value;
    }

    function setOptionFactoryData(bool _status, uint256 _blockTimestamp, address _owner, address _optionAddress) onlyOptionFactory public {
        listOfOptions[_optionAddress] = OptionsData(_status, _blockTimestamp, _owner);
    }

    function setOptionFactoryAddress(address _optionFactory) onlyOwner public {
        optionFactory = _optionFactory;
    }

    ////////////////////////
    /// Get Functions
    ////////////////////////

    function getUintValues(bytes32 _name) public view returns(uint256) {
        return localUintVariables[_name];
    }

    function getAddressValues(bytes32 _name) public view returns(address) {
        return localAddressVariables[_name];
    }


}