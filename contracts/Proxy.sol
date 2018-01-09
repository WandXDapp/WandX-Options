pragma solidity ^0.4.18;

import './interfaces/IERC20.sol';

contract Proxy {

    IERC20 public BT;
    IERC20 public QT;

    address public owner;

    function Proxy(address _baseToken, address _quoteToken) {
        owner = msg.sender;
        BT = IERC20(_baseToken);
        QT = IERC20(_quoteToken); 
    }

    function withdrawal() {
        require(msg.sender == owner);
    }

}