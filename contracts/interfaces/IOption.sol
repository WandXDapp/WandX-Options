pragma solidity ^0.4.23;

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