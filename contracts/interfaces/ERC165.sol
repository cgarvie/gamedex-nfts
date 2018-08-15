pragma solidity 0.4.24;


/**
 * @title ERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface ERC165 {
    function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}