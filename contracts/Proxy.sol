pragma solidity ^0.4.18;

import './interfaces/IERC20.sol';
import './interfaces/IProxy.sol';
import './interfaces/IOptionDumper.sol';

contract Proxy is IProxy {

    IERC20 public BT;
    IERC20 public QT;
    IOptionDumper public optionDumper;
    address public option;
    address public buyer;
    uint256 public optionsExpiry;
    uint256 public strikePrice;


    modifier onlyOption() {
        require(msg.sender == option);
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
        option = msg.sender;
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
        uint256 amount = _amount * strikePrice;
        require(QT.transfer(_to, amount));
        require(BT.transferFrom(_to, buyer, _amount));
        return true; 
    }

    /**
     * @dev withdraw the unused base token and quote token only by owner
     * @return bool success    
     */
    function withdrawal() onlyOption public returns (bool success) {
        require(block.number > optionsExpiry);
        uint256 balanceBT = BT.balanceOf(this);
        uint256 balanceQT = QT.balanceOf(this);
        require(BT.transfer(buyer, balanceBT));
        require(QT.transfer(buyer, balanceQT));
        optionDumper.dumpOption();
        return true;
    }

}