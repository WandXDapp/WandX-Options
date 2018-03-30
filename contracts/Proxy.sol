pragma solidity ^0.4.18;

import './interfaces/IERC20.sol';
import './interfaces/IProxy.sol';
import './interfaces/IOptionDumper.sol';
import './interfaces/IOption.sol';
import './helpers/math/SafeMath.sol';

contract Proxy is IProxy {

    using SafeMath for uint256;

    IERC20 public BT;
    IERC20 public QT;
    IOption public option;
    IOptionDumper public optionDumper;
    address public optionAddress;
    address public buyer;
    uint256 public optionsExpiry;
    uint256 public strikePrice;


    modifier onlyOption() {
        require(msg.sender == optionAddress);
        _;
    }

    /**
     * @dev Constructor
     * @param _baseToken Address of the Base token
     * @param _quoteToken Address of the Quote token
     * @param _expiry Unix timestamp to expire the option
     * @param _strikePrice Price at which buyer will obligate to buy the base token
     * @param _buyer Address of the buyer
     * @param _dumper Address of the contract that use to dump the option assets
     */
    function Proxy(address _baseToken, address _quoteToken, uint256 _expiry, uint256 _strikePrice, address _buyer, address _dumper) public {
        optionAddress = msg.sender;
        option = IOption(optionAddress);
        BT = IERC20(_baseToken);
        QT = IERC20(_quoteToken); 
        optionDumper = IOptionDumper(_dumper);
        optionsExpiry = _expiry;
        strikePrice = _strikePrice;
        buyer = _buyer;
    }

    /**
     * @dev `distributeStakes` Use to settle down the excersice request of the option
     * @param _to Address of the seller
     * @param _amount Number of the assets seller want to excercised
     * @return bool success
     */
    function distributeStakes(address _to, uint256 _amount) onlyOption public returns (bool success) {
        var (b,q) = option.getOptionTokenDecimals();
        uint256 _baseAmount = _amount.mul(10 ** uint256(b));
        uint256 _quoteAmount = strikePrice.mul(_amount.mul(10 ** uint256(q)));
        require(QT.transfer(_to, _quoteAmount));
        require(BT.transferFrom(_to, buyer, _baseAmount));
        return true; 
    }

    /**
     * @dev withdraw the unused base token and quote token only by owner
     * @return bool success    
     */
    function withdrawal() onlyOption public returns (bool success) {
        require(block.number > optionsExpiry);
        require(BT.transfer(buyer, BT.balanceOf(address(this))));
        require(QT.transfer(buyer, QT.balanceOf(address(this))));
        require(optionDumper.dumpOption());
        return true;
    }

}