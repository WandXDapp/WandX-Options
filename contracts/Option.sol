pragma solidity ^0.4.23;

import './interfaces/IOption.sol';
import './interfaces/IERC20.sol';
import './interfaces/IProxy.sol';
import './helpers/math/SafeMath.sol';
import './Proxy.sol';
import './OptionDumper.sol';

contract Option is IOption, IERC20 {

    using SafeMath for uint256;

    address public tokenProxy;
    address public optionDumperAddress;

    address public buyer;
    address public baseToken;
    address public quoteToken;
    uint256 public strikePrice;
    uint256 public expirationDate;

    uint256 public totalSupply_;
    uint256 public premium;
    uint256 public expiry;
    bool public isOptionIssued = false;

    uint8 public decimals = 0;
    uint8 public B_DECIMAL_FACTOR;
    uint8 public Q_DECIMAL_FACTOR;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    // Notifications
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
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
        uint8 _baseTokenDecimal,
        uint8 _quoteTokenDecimal, 
        uint256 _strikePrice,
        uint256 _expirationDate,
        address _buyer
        ) public 
    {
        require(_buyer != address(0) && _quoteToken != address(0) && _baseToken != address(0));
        require(_expirationDate > now);
        require(_strikePrice > 0);
        buyer = _buyer;
        baseToken = _baseToken;
        quoteToken = _quoteToken;
        strikePrice = _strikePrice;
        expirationDate = _expirationDate;
        B_DECIMAL_FACTOR = _baseTokenDecimal;
        Q_DECIMAL_FACTOR = _quoteTokenDecimal;
    }

    /**
     * @dev `issueOption` Use to issue option or generate the option called only by the owner of the option
     * @param _assetsOffered No. of options need to be generated
     * @param _premium Amount to be paid by the trader to buy the option
     * @param _expiry Timestamp when option get expired
     */
    function issueOption(uint256 _assetsOffered, uint256 _premium, uint256 _expiry) onlyBuyer public {
        require(isOptionIssued == false);
        require(expirationDate >= now);
        require(_expiry > block.number);
        optionDumperAddress = new OptionDumper();
        require(createProxy(_expiry));
        // Allowance for the option contract is necessary allowed[buyer][this] = _optionsOffered
        uint256 assets = _assetsOffered.mul(strikePrice * 10 ** uint256(Q_DECIMAL_FACTOR));
        require(IERC20(quoteToken).transferFrom(buyer, tokenProxy, assets)); 
        balances[this] = _assetsOffered;
        totalSupply_ = _assetsOffered;
        premium = _premium;
        expiry = _expiry;
        isOptionIssued = !isOptionIssued;
        Transfer(address(0), this, _assetsOffered);
        LogOptionsIssued(_assetsOffered, expiry, premium, tokenProxy);
    }

    function createProxy(uint256 _expiry) internal returns(bool) {
        tokenProxy = new Proxy(baseToken, quoteToken, _expiry, strikePrice, buyer, optionDumperAddress);
        return true;
    }

    /**
     * @dev `incOffering` Use to generate the more option supply in between the time boundation of the option
     * @param _extraOffering No. of options need to generate
     */
    function incOffering(uint256 _extraOffering) public {
        require(msg.sender == buyer);
        require(expiry > now);
        // Allowance for the option contract is necessary allowed[buyer][this] = _extraOffering
        uint256 extraOffering = _extraOffering.mul(strikePrice * 10 ** uint256(Q_DECIMAL_FACTOR));
        require(IERC20(quoteToken).transferFrom(buyer, tokenProxy, extraOffering));
        totalSupply_ = totalSupply_.add(_extraOffering);
        balances[this] = balances[this].add(_extraOffering);
        Transfer(address(0), this, _extraOffering);
        LogOptionsIssued(totalSupply_, expiry, premium, tokenProxy);
    }

    /**
     * @dev `tradeOption` This function use to buy the option
     * @param _trader Address of the buyer who buy the option
     * @param _amount No. of option trader buy
     */
    function tradeOption(address _trader, uint256 _amount) external {
        require(_amount > 0);
        require(_trader != address(0));
        require(expiry > block.number);
        uint256 amount = _amount.mul(premium * 10 ** uint256(Q_DECIMAL_FACTOR));
        require(IERC20(quoteToken).transferFrom(_trader, tokenProxy, amount));
        require(this.transfer(_trader,_amount));
        Traders[_trader] = TraderData(_amount,false);
        LogOptionsTrade(_trader, _amount, now);
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
        LogOptionsExcercised(msg.sender, _amount, now);
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

    function getOptionTokenDecimals() view public returns (uint8, uint8) {
        return (
            B_DECIMAL_FACTOR,
            Q_DECIMAL_FACTOR
        );
    }

    /**
     * @notice  Reference from zeppelin-solidity
                https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/StandardToken.sol
                https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/BasicToken.sol
     * 
     */

    //////////////////////////////////
    ////// ERC20 functions
    /////////////////////////////////

     /** 
      * @dev send `_value` option assets to `_to` from `msg.sender`
      * @param _to The address of the recipient
      * @param _value The amount of option assets to be transferred
      * @return Whether the transfer was successful or not 
      */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
  }

    /** 
     * @dev send `_value` option assets to `_to` from `_from` on the condition it is approved by `_from`
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of option assets to be transferred
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
     * @dev `balanceOf` function used to read the balance of the option assets holder
     * @param _owner The address from which the balance will be retrieved
     * @return The balance 
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    /** 
     * @dev `msg.sender` approves `_spender` to spend `_value` option assets
     * @param _spender The address of the account able to transfer the option assets
     * @param _value The amount of option assets to be approved for transfer
     * @return Whether the approval was successful or not 
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /** 
     * @dev `allowance`
     * @param _owner The address of the account owning option assets
     * @param _spender The address of the account able to transfer the option assets
     * @return Amount of remaining option assets allowed to spent 
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
    * @dev Increase the amount of option assets that an owner allowed to a spender.
    *
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _addedValue The amount of option assets to increase the allowance by.
    */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of option assets that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of option assets to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
  * @dev total number of options assets in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

}