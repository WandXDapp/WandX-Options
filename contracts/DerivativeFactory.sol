pragma solidity ^0.4.18;

/**
 * @notice  Governanace of this contract need to be decided whether it be operated by the single wandx entity
            or it will be more decentralized by adding the vote scheme for the changes in the operator contract
 */

import './libraries/LDerivativeFactory.sol';
import './interfaces/IERC20.sol';
import './Option.sol';
import './helpers/Ownable.sol';

contract DerivativeFactory is Ownable {

    using LDerivativeFactory for address;
    string public version = "0.1";
    address DT_Store;
    IERC20 WAND;

    // Notifications
    event OptionCreated(address _baseToken, address _quoteToken, uint256 _blockTimestamp, address indexed _creator);

    /**
     * @dev Constructor
     * @param _storageAddress Address of the storage contract
     * @param _tokenAddress Address of the token which used as the transaction fee    
     */
    function DerivativeFactory(address _storageAddress, address _tokenAddress) public {
       DT_Store = _storageAddress;
       WAND = IERC20(_tokenAddress);
       DT_Store.setNewOptionFee(100 * 10 ** 18);
       owner = msg.sender;
    }

    /**
     * @dev Function use to create the new option contract
     * @param _baseToken Address of the Base token
     * @param _quoteToken Address of the Quote token
     * @param _strikePrice Price at which buyer will obligate to buy the base token
     * @param _blockTimestamp Unix timestamp to expire the option
     * @return bool
     */
    function createNewOption(address _baseToken, address _quoteToken, uint256 _strikePrice, uint256 _blockTimestamp) 
    external 
    returns (bool) 
    {   
        address orgAccount = DT_Store.getOrgAccount();
        uint256 _fee = DT_Store.getNewOptionFee();
        // Before creation creator should have to pay the service fee to wandx Platform
        require(WAND.transferFrom(msg.sender, orgAccount, _fee));
        address _optionAddress = new Option(_baseToken, _quoteToken, _strikePrice, _blockTimestamp, msg.sender);    
        DT_Store.setOptionFactoryData(false, _blockTimestamp, msg.sender, _optionAddress);
        return true;
    }

    function changeNewOptionFee(uint256 _newFee) onlyOwner public {
        DT_Store.setNewOptionFee(_newFee);
    }

    function setOrgAddress(address _orgAddress) onlyOwner public {
        DT_Store.setOrgAddress(_orgAddress);
    }

    function getOrgAccount() public view returns(address) {
        return DT_Store.getOrgAccount();
    }

    function getOptionFee() public view returns(uint256) {
        return DT_Store.getNewOptionFee();
    }

}