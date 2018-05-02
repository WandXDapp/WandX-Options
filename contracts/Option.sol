pragma solidity ^0.4.23;

import "./Proxy.sol";
import "./interfaces/IOption.sol";
import "./interfaces/IProxy.sol";
import "./OptionDumper.sol";
import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


contract Option is IOption, StandardToken {

    using SafeMath for uint256;

    // Address of the tokenProxy contract which works as the proxy for funds in or out from the option contract.
    address public tokenProxy;
    // Address of the OptionDumper contract address use to dump the all assets of the option
    address public optionDumperAddress;
    // Address of the buyer (Creator of the option)
    address public buyer;
    // Address of the BaseToken act as the underlying securities
    address public baseToken;
    // Address of the QuoteToken use to pay the premium. 
    address public quoteToken;
    // Price at which buyer will obligate to buy the base token
    uint256 public strikePrice;
    // Amount needs to pay to hold the option.
    uint256 public premium;
    // Block.number (when this option get expired)
    uint256 public expiry;

    bool public isOptionIssued = false;
    
    uint8 public decimals = 0;

    // Notifications
    event LogOptionsIssued(uint256 _optionsIssued, uint256 _expirationTime, uint256 _premium, address _tokenProxy);
    event LogOptionsTrade(address indexed _trader, uint256 _amount, uint256 _timestamp);
    event LogOptionsExcercised(address indexed _trader, uint256 _amount, uint256 _timestamp);

    struct TraderData {
        uint256 optionQuantity;
        bool status;                        // false when it doesn't excercise the full option Quantity, True when fully excercised 
    }

    mapping(address => TraderData) public Traders;

    modifier onlyBuyer() {
        require(msg.sender == buyer);
        _;
    }
    
    /**
     * @dev `Option` Constructor
     */

    constructor ( 
        address _baseToken, 
        address _quoteToken,
        uint256 _strikePrice,
        address _buyer
        ) public 
    {
        require(_buyer != address(0) && _quoteToken != address(0) && _baseToken != address(0));
        require(_strikePrice > 0);
        buyer = _buyer;
        baseToken = _baseToken;
        quoteToken = _quoteToken;
        strikePrice = _strikePrice;
    }

    /**
     * @dev `issueOption` Use to issue option or generate the option called only by the owner of the option
     * @param _assetsOffered No. of options need to be generated
     * @param _premium Amount to be paid by the trader to buy the option
     * @param _expiry Block.number when option get expired
     */
    function issueOption(uint256 _assetsOffered, uint256 _premium, uint256 _expiry) onlyBuyer public {
        require(isOptionIssued == false);
        require(_expiry > block.number);
        optionDumperAddress = new OptionDumper();
        tokenProxy = new Proxy(optionDumperAddress);
        // Allowance for the option contract is necessary allowed[buyer][this] = _optionsOffered
        uint256 assets = _assetsOffered.mul(strikePrice.mul(10 ** uint256(IERC20(quoteToken).decimals())));
        balances[address(this)] = _assetsOffered;
        totalSupply_ = _assetsOffered;
        premium = _premium;
        expiry = _expiry;
        isOptionIssued = true;
        require(IERC20(quoteToken).transferFrom(buyer, tokenProxy, assets));
        Transfer(address(0), address(this), _assetsOffered);
        emit LogOptionsIssued(_assetsOffered, expiry, premium, tokenProxy);
    }

    /**
     * @dev `incOffering` Use to generate the more option supply in between the time boundation of the option
     * @param _extraOffering No. of options need to generate
     */
    function incOffering(uint256 _extraOffering) public {
        require(msg.sender == buyer);
        require(expiry > block.number);
        // Allowance for the option contract is necessary allowed[buyer][this] = _extraOffering
        uint256 extraOffering = _extraOffering.mul(strikePrice.mul(10 ** uint256(IERC20(quoteToken).decimals())));
        totalSupply_ = totalSupply_.add(_extraOffering);
        balances[address(this)] = balances[address(this)].add(_extraOffering);
        require(IERC20(quoteToken).transferFrom(buyer, tokenProxy, extraOffering));
        Transfer(address(0), address(this), _extraOffering);
        emit LogOptionsIssued(totalSupply_, expiry, premium, tokenProxy);
    }

    /**
     * @dev `tradeOption` This function use to buy the option
     * @param _amount No. of option trader buy
     */
    function tradeOption(uint256 _amount) external {
        require(_amount > 0);
        require(expiry > block.number);
        uint256 amount = _amount.mul(premium * 10 ** uint256(IERC20(quoteToken).decimals()));
        Traders[msg.sender] = TraderData(_amount,false);
        require(IERC20(quoteToken).transferFrom(msg.sender, tokenProxy, amount));
        require(this.transfer(msg.sender,_amount));
        emit LogOptionsTrade(msg.sender, _amount, now);
    }
    
    /**
     * @dev `exerciseOption` This function use to excercise the option means to sell the option to the owner again
     * @param _amount no. of option trader want to exercise
     * @return bool
     */
    function exerciseOption(uint256 _amount) external returns (bool) {
        require(_amount > 0);
        require(expiry >= block.number);      
        require(this.balanceOf(msg.sender) >= _amount);
        require(IProxy(tokenProxy).distributeStakes(msg.sender, _amount));
        // Provide allowance to this by the trader
        require(this.transferFrom(msg.sender, optionDumperAddress, _amount)); 
        Traders[msg.sender].optionQuantity = Traders[msg.sender].optionQuantity.sub(_amount);
        emit LogOptionsExcercised(msg.sender, _amount, now);
        return true;
    }

    /**
     * @dev `withdrawTokens` Withdraw the tokens
     * @return bool
     */
    function withdrawTokens() onlyBuyer external returns(bool) {
        require(IProxy(tokenProxy).withdrawal());
        return true;
    }

    ///////////////////////////////////
    //// Get Functions
    //////////////////////////////////

    function getOptionDetails() view public returns (address, address, address, address, uint256, uint256, uint256, uint256) {
        return (
            buyer,
            baseToken,
            quoteToken,
            tokenProxy,
            strikePrice,
            expiry,
            premium,
            totalSupply_
        );
    } 

}