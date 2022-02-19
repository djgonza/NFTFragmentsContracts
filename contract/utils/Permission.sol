// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Permission {

    mapping(address => bool) public _admins;
    mapping(address => bool) public _minters;
    mapping(address => bool) public _burners;

    constructor () {
        _admins[address(msg.sender)] = true;
        _minters[address(msg.sender)] = true;
        _burners[address(msg.sender)] = true;
    }

    modifier isAdmin () {
        require(_admins[address(msg.sender)], "No admin role");
        _;
    }

    function addAdmin(address newAdmin) public isAdmin {
        _admins[newAdmin] = true;
    }

    function removeAdmin(address oldAdmin) public isAdmin {
        _admins[oldAdmin] = false;
    }

    modifier isMinter () {
        require(_minters[address(msg.sender)], "No minter role");
        _;
    }

    function addMinter(address newMinter) public isAdmin {
        _minters[newMinter] = true;
    }

    function removeMinter(address oldMinter) public isAdmin {
        _minters[oldMinter] = false;
    }

    modifier isBurner () {
        require(_burners[address(msg.sender)], "No burner role");
        _;
    }

    function addBurner(address newBurner) public isAdmin {
        _burners[newBurner] = true;
    }

    function removeBurner(address oldBurner) public isAdmin {
        _burners[oldBurner] = false;
    }


}