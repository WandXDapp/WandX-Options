pragma solidity ^0.4.18;

/// ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
interface IERC20 {
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

interface IOption {

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
     * @param _trader Address of the buyer who buy the option
     * @param _amount No. of option trader buy
     */
    function tradeOption(address _trader, uint256 _amount) external;
    
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

    function getOptionTokenDecimals() view public returns (uint8, uint8);

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

/// @title Math operations with safety checks
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

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