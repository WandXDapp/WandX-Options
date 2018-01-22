pragma solidity ^0.4.18;

/// ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
interface IERC20 {
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

interface IProxy {

    function distributeStakes(address _to, uint256 _amount) public returns (bool success);

    function withdrawal() public returns (bool success);
}

contract Proxy is IProxy {

    IERC20 public BT;
    IERC20 public QT;

    address public owner;
    address public buyer;
    uint256 public optionsExpiry;
    uint256 public strikePrice;

    modifier onlyOption() {
        require(msg.sender == owner);
        _;
    }

    function Proxy(address _baseToken, address _quoteToken, uint256 _expiry, uint256 _strikePrice, address _buyer) public {
        owner = msg.sender;
        BT = IERC20(_baseToken);
        QT = IERC20(_quoteToken); 
        optionsExpiry = _expiry;
        strikePrice = _strikePrice;
        buyer = _buyer;
    }

    function distributeStakes(address _to, uint256 _amount) onlyOption public returns (bool success) {
        require(msg.sender == owner);
        require(QT.transfer(_to, strikePrice));
        require(QT.transferFrom(_to, buyer, _amount));
        return true; 
    } 

    function withdrawal() onlyOption public returns (bool success) {
        require(msg.sender == owner);
        require(now > optionsExpiry);
        uint256 balanceBT = BT.balanceOf(this);
        uint256 balanceQT = QT.balanceOf(this);
        require(BT.transfer(buyer, balanceBT));
        require(QT.transfer(buyer, balanceQT));
        return true;
    }

}