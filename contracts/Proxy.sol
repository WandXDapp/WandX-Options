pragma solidity ^0.4.18;

import './interfaces/IERC20.sol';
import './interfaces/IProxy.sol';
import './interfaces/IOptionDumper.sol';
import './interfaces/IOption.sol';
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Proxy is IProxy {

    using SafeMath for uint256;

    IOptionDumper public optionDumper;
    address public optionAddress;


    modifier onlyOption() {
        require(msg.sender == optionAddress);
        _;
    }

    /**
     * @dev Constructor
     * @param _dumper Address of the contract that use to dump the option assets
     */
    constructor (address _dumper) public {
        optionAddress = msg.sender;
        optionDumper = IOptionDumper(_dumper);
    }

    /**
     * @dev `distributeStakes` Use to settle down the excersice request of the option
     * @param _to Address of the seller
     * @param _amount Number of the assets seller want to excercised
     * @return bool success
     */
    function distributeStakes(address _to, uint256 _amount) onlyOption public returns (bool success) {
        address baseToken;
        address quoteToken;
        address buyer;
        uint256 strikePrice;
        (buyer,baseToken,quoteToken,,strikePrice,,,,) = IOption(optionAddress).getOptionDetails();

        uint256 _baseAmount = _amount.mul(10 ** uint256(IERC20(baseToken).decimals()));
        uint256 _quoteAmount = strikePrice.mul(_amount.mul(10 ** uint256(IERC20(quoteToken).decimals())));

        require(IERC20(quoteToken).transfer(_to, _quoteAmount));
        require(IERC20(baseToken).transferFrom(_to, buyer, _baseAmount));

        return true; 
    }

    /**
     * @dev withdraw the unused base token and quote token only by owner
     * @return bool success    
     */
    function withdrawal() onlyOption public returns (bool success) {
        address baseToken;
        address quoteToken;
        address buyer;
        uint256 optionsExpiry;
        (buyer,baseToken,quoteToken,,,,optionsExpiry,,) = IOption(optionAddress).getOptionDetails();
        require(block.number > optionsExpiry);

        require(IERC20(baseToken).transfer(buyer, IERC20(baseToken).balanceOf(address(this))));
        require(IERC20(quoteToken).transfer(buyer, IERC20(quoteToken).balanceOf(address(this))));

        require(optionDumper.dumpOption());
        return true;
    }

}