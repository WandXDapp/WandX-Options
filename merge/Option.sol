pragma solidity ^0.4.23;

/// ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
contract IERC20 {
    uint8 public decimals;
    function totalSupply() public view returns (uint256);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

interface IProxy {

    /**
     * @dev `distributeStakes` Use to settle down the excersice request of the option
     * @param _to Address of the seller
     * @param _amount Number of the assets seller want to excercised
     * @return bool success
     */
    function distributeStakes(address _to, uint256 _amount) public returns (bool success);

    /**
     * @dev withdraw the unused base token and quote token only by owner
     * @return bool success    
     */
    function withdrawal() public returns (bool success);
}

interface IOptionDumper {

    function dumpOption () public returns (bool);
    
}

contract IOption {

   /**
    * @dev `issueOption` Use to issue option or generate the option called only by the owner of the option
    * @param _assetsOffered No. of options need to be generated
    * @param _premium Amount to be paid by the trader to buy the option
    * @param _expiry Timestamp when option get expired
    */
    function issueOption(uint256 _assetsOffered, uint256 _premium, uint256 _expiry) public;

    /**
     * @dev `incOffering` Use to generate the more option supply in between the time boundation of the option
     * @param _extraOffering No. of options need to generate
     */
    function incOffering(uint256 _extraOffering) public;

    /**
     * @dev `tradeOption` This function use to buy the option
     * @param _amount No. of option trader buy
     */
    function tradeOption(uint256 _amount) external;
    
     /**
     * @dev `exerciseOption` This function use to excercise the option means to sell the option to the owner again
     * @param _amount no. of option trader want to exercise
     * @return bool
     */
    function exerciseOption(uint256 _amount) external returns (bool);

    /**
     * @dev `withdrawTokens` Withdraw the tokens
     * @return bool
     */
    function withdrawTokens() external returns(bool);

    ///////////////////////
    /// GET FUNCTIONS
    //////////////////////

    function getOptionDetails() view public returns (address, address, address, address, uint256, uint256, uint256, uint256);


    //////////////////////////////////
    ////// ERC20 functions
    /////////////////////////////////

     /** 
      * @dev send `_value` option assets to `_to` from `msg.sender`
      * @param _to The address of the recipient
      * @param _value The amount of option assets to be transferred
      * @return Whether the transfer was successful or not 
      */
    function transfer(address _to, uint256 _value) public returns (bool);

    /** 
     * @dev send `_value` option assets to `_to` from `_from` on the condition it is approved by `_from`
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of option assets to be transferred
     * @return Whether the transfer was successful or not 
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    /**
     * @dev `balanceOf` function used to read the balance of the option assets holder
     * @param _owner The address from which the balance will be retrieved
     * @return The balance 
     */
    function balanceOf(address _owner) public view returns (uint256 balance);

    /** 
     * @dev `msg.sender` approves `_spender` to spend `_value` option assets
     * @param _spender The address of the account able to transfer the option assets
     * @param _value The amount of option assets to be approved for transfer
     * @return Whether the approval was successful or not 
     */
    function approve(address _spender, uint256 _value) public returns (bool);

    /** 
     * @dev `allowance`
     * @param _owner The address of the account owning option assets
     * @param _spender The address of the account able to transfer the option assets
     * @return Amount of remaining option assets allowed to spent 
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

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
  function increaseApproval(address _spender, uint _addedValue) public returns (bool);

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
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool);
  
  /**
  * @dev total number of options assets in existence
  */
  function totalSupply() public view returns (uint256); 
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

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

contract OptionDumper {

    constructor () public {
    } 

   function dumpOption () public returns(bool) {
        // Selfdestruct  
        selfdestruct(address(this));
        return true;
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

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