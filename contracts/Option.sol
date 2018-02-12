pragma solidity ^0.4.18;

import './interfaces/IOption.sol';
import './interfaces/IERC20.sol';
import './helpers/math/SafeMath.sol';
import './Proxy.sol';

contract Option is IOption {

    using SafeMath for uint256;

    IERC20 public BT;
    IERC20 public QT;
    IProxy public proxy;
    address public tokenProxy;

    address public buyer;
    address public baseToken;
    address public quoteToken;
    uint256 public strikePrice;
    uint256 public expirationDate;

    uint256 public assetsOffered;
    uint256 public premium;
    uint256 public expiry;
    bool public isOptionIssued = false;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event LogOptionsIssued(uint256 _optionsIssued, uint256 _expirationTime, uint256 _premium);
    event LogOptionsTrade(address indexed _trader, uint256 _amount, uint256 _timestamp);
    event LogOptionsExcercised(address indexed _trader, uint256 _amount, uint256 _timestamp);

    struct traderData {
        uint256 optionQuantity;
        bool status;                        // false when it doesn't excercise the full option Quantity, True when fully excercised 
    }

    mapping(address => traderData) public Traders;

    /**
     * @dev `Option` Constructor
     */

    function Option( 
        address _baseToken, 
        address _quoteToken, 
        uint256 _strikePrice,
        uint256 _expirationDate,
        address _buyer
        ) public 
    {
        require(_buyer != address(0) && _quoteToken != address(0) && _baseToken != address(0));
        require(_expirationDate > now);
        require(strikePrice > 0);
        buyer = _buyer;
        baseToken = _baseToken;
        quoteToken = _quoteToken;
        strikePrice = _strikePrice;
        expirationDate = _expirationDate;
        BT = IERC20(baseToken);
        QT = IERC20(quoteToken);
    }

    /**
     * @dev `issueOption` Use to issue option or generate the option called only by the owner of the option
     * @param _assetsOffered No. of options need to be generated
     * @param _premium Amount to be paid by the trader to buy the option
     * @param _expiry Timestamp when option get expired
     */


    function issueOption(uint256 _assetsOffered, uint256 _premium, uint256 _expiry) public {
        require(isOptionIssued == false);
        require(msg.sender == buyer);
        require(_premium > 0);
        require(expirationDate >= _expiry);
        tokenProxy = new Proxy(baseToken, quoteToken, _expiry, strikePrice, buyer);
        proxy = IProxy(tokenProxy);
        // Allowance for the option contract is necessary allowed[buyer][this] = _optionsOffered
        require(QT.transferFrom(buyer, tokenProxy, _assetsOffered * strikePrice)); 
        balances[this] = _assetsOffered;
        assetsOffered = _assetsOffered;
        premium = _premium;
        expiry = _expiry;
        isOptionIssued = !isOptionIssued;
        LogOptionsIssued(_assetsOffered, expiry, premium);
    }


    /**
     * @dev `incOffering` Use to generate the more option supply in between the time boundation of the option
     * @param _extraOffering No. of options need to generate
     */

    function incOffering(uint256 _extraOffering) public {
        require(msg.sender == buyer);
        require(expiry > now);
        // Allowance for the option contract is necessary allowed[buyer][this] = _extraOffering
        require(QT.transferFrom(buyer,tokenProxy,_extraOffering * strikePrice));
        assetsOffered = assetsOffered.add(_extraOffering);
        balances[this] = balances[this].add(_extraOffering);
        LogOptionsIssued(assetsOffered, expiry, premium);
    }

    /**
     * @dev `tradeOption` This function use to buy the option
     * @param _trader Address of the buyer who buy the option
     * @param _amount No. of option trader buy
     * @return bool
     */

    function tradeOption(address _trader, uint256 _amount) external returns(bool) {
        require(_amount > 0);
        require(_trader != address(0));
        require(expiry > now);
        require(QT.transferFrom(_trader, tokenProxy, _amount * premium));
        require(this.transfer(_trader,_amount));
        Traders[_trader] = traderData(_amount,false);
        LogOptionsTrade(_trader, _amount, now);
        return true;
    }
    
    /**
     * @dev `exerciseOption` This function use to excercise the option means to sell the option to the owner again
     * @param _trader Address of the holder of the option
     * @param _amount no. of option trader want to exercise
     * @return bool
     */

    function exerciseOption(address _trader, uint256 _amount) external returns (bool) {
        require(_amount > 0);
        require(_trader != address(0));
        require(expiry >= now);      
        require(this.balanceOf(_trader) >= _amount);
        require(BT.allowance(tokenProxy, _trader) >= _amount);
        require(QT.balanceOf(tokenProxy) >= _amount * strikePrice);
        require(proxy.distributeStakes(_trader, _amount));
        // Provide allowance to this by the trader
        require(this.transferFrom(_trader,0x0,_amount)); 
        Traders[_trader].optionQuantity = Traders[_trader].optionQuantity.sub(_amount);
        LogOptionsExcercised(_trader, _amount, now);
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
            assetsOffered
        );
    } 

    //////////////////////////////////
    ////// ERC20 functions
    /////////////////////////////////

     /** 
      * @dev send `_value` token to `_to` from `msg.sender`
      * @param _to The address of the recipient
      * @param _value The amount of token to be transferred
      * @return Whether the transfer was successful or not 
      */
    function transfer(address _to, uint256 _value) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /** 
     * @dev send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not 
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
      require(_to != address(0));
      require(_value <= balances[_from]);
      require(_value <= allowed[_from][msg.sender]);

      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
      Transfer(_from, _to, _value);
      return true;
    }

    /**
     * @dev `balanceOf` function used to read the balance of the token holder
     * @param _owner The address from which the balance will be retrieved
     * @return The balance 
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    /** 
     * @dev `msg.sender` approves `_spender` to spend `_value` tokens
     * @param _spender The address of the account able to transfer the tokens
     * @param _value The amount of tokens to be approved for transfer
     * @return Whether the approval was successful or not 
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /** 
     * @dev `allowance`
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent 
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


}