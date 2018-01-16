pragma solidity ^0.4.18;

import './interfaces/IERC20.sol';

contract Proxy {

    IERC20 public BT;
    IERC20 public QT;

    address public owner;
    uint256 public optionsExpiry;

    function Proxy(address _baseToken, address _quoteToken, uint256 _expiry) public {
        owner = msg.sender;
        BT = IERC20(_baseToken);
        QT = IERC20(_quoteToken); 
        optionsExpiry = _expiry;
    }

    function distributeStakes(address _to, uint256 _profit, uint256 _amount, address _creator) public returns(bool) {
        require(msg.sender == owner);
        if (_profit > 0) {
            require(QT.transfer(_to,_profit));
        }
        require(BT.transfer(_creator, _amount));
        return true; 
    } 

    function withdrawal(address _creator) public returns (bool) {
        require(msg.sender == owner);
        require(now > optionsExpiry);
        uint256 balanceBT = BT.balanceOf(this);
        uint256 balanceQT = QT.balanceOf(this);
        require(BT.transfer(_creator, balanceBT));
        require(QT.transfer(_creator, balanceQT));
        return true;
    }

}