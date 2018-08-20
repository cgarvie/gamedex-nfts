pragma solidity 0.4.24;


/**
 * @title ERC223
 * @dev https://github.com/ethereum/EIPs/issues/223
 */
contract ERC223 {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
}