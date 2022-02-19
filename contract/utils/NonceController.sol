// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NonceController {
    mapping(uint256 => bool) public _usedNonces;

    modifier validateNonce(uint256 nonce) {
        require(!_usedNonces[nonce], "Nonces already used");
        _usedNonces[nonce] = true;
        _;
    }

    
}
