pragma solidity 0.4.24;


contract ERC223Interface {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
}