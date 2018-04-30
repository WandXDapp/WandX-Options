pragma solidity ^0.4.23;

import '../storage/OptionStorage.sol';

library LDerivativeFactory {
    function getOrgAccount(address _storageContract) public view returns(address _orgAccount) {
        return OptionStorage(_storageContract).getAddressValues(keccak256("ORG_ACCOUNT"));
    }

    function getNewOptionFee(address _storageContract) public view returns(uint256 _fee) {
        return OptionStorage(_storageContract).getUintValues(keccak256("fee"));
    }

    function setOptionFactoryData(address _storageContract, address _owner, address _optionAddress) public {
        OptionStorage(_storageContract).setOptionFactoryData(_owner, _optionAddress);
    }

    function setNewOptionFee(address _storageContract, uint256 _fee) public {
        OptionStorage(_storageContract).setUintValues(keccak256("fee"), _fee);
    }

    function setOrgAddress(address _storageContract, address _orgAddress) public {
        OptionStorage(_storageContract).setAddressValues(keccak256("ORG_ACCOUNT"), _orgAddress);
    }
}