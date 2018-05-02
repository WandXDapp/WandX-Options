pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract OptionStorage is Ownable {
    
    address public optionFactory;

    // mapping to track the list of options created by any writer 
    mapping(address => address) public listOfOptions;
    mapping (bytes32 => uint256) public localUintVariables;
    mapping (bytes32 => address) public localAddressVariables;

    modifier onlyOptionFactory() {
        require(msg.sender == optionFactory);
        _;
    }

    constructor (address _ownerAddress) public {
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

    function setOptionFactoryData(address _owner, address _optionAddress) public {
        listOfOptions[_optionAddress] = _owner;
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