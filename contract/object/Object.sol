// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "../../library/ECDSA.sol";
import "./Permission.sol";
import "./FeeController.sol";
import "./NonceController.sol";

contract Object is ERC721, Permission, FeeController, NonceController {
    using ECDSA for bytes32;

    uint256 public _totalSupply;

    event Mint(address to, uint256 objectId);
    event Burn(uint256 objectId);

    constructor()
        ERC721("Kokull object", "KKLO")
        Permission()
        FeeController()
    {}

    function payCraftCost(address crafter, uint256 price) internal {
        uint256 calculatedFee = (msg.value * _percentFee) / 100;
        payable(address(this)).transfer(calculatedFee);
        payable(crafter).transfer(price - calculatedFee);
    }

    function mintNewObject(address to) internal returns (uint256) {
        uint256 _objectId = _totalSupply + 1;
        _mint(to, _objectId);
        _totalSupply = _totalSupply + 1;
        emit Mint(to, _objectId);
        return _objectId;
    }

    /* ------------ CRAFT ----------------  */
    function craftWithCrafter(
        address crafter,
        address to,
        uint256 recipeID,
        uint256 price,
        uint256 nonce,
        bytes memory signature
    ) public payable validateNonce(nonce) returns (uint256) {
        address signer = getCraftWithCrafterSigner(
            crafter,
            to,
            recipeID,
            price,
            nonce,
            signature
        );

        require(_minters[signer], "Transaction CREATE not have valid signed");
        require(msg.value >= price, "Transacion CREATE invalid value");

        payCraftCost(crafter, price);
        return mintNewObject(to);
    }

    function getCraftWithCrafterSigner(
        address crafter,
        address to,
        uint256 recipeID,
        uint256 price,
        uint256 nonce,
        bytes memory signature
    ) internal pure returns (address) {
        //Recreamos la llamada
        bytes32 txHash = keccak256(
            abi.encodePacked(crafter, to, recipeID, price, nonce)
        );
        //Recreamos la firma
        bytes32 ethSignedHash = txHash.toEthSignedMessageHash();
        //Sacamos el signer con la firma recreada
        address signer = ethSignedHash.recover(signature);
        return signer;
    }

    function craft(
        address to,
        uint256 recipeID,
        uint256 nonce,
        bytes memory signature
    ) public payable validateNonce(nonce) payFee returns (uint256) {
        address signer = getCraftSigner(to, recipeID, nonce, signature);
        require(_minters[signer], "Transaction CREATE not have valid signed");
        return mintNewObject(to);
    }

    function getCraftSigner(
        address to,
        uint256 recipeID,
        uint256 nonce,
        bytes memory signature
    ) internal pure returns (address) {
        //Recreamos la llamada
        bytes32 txHash = keccak256(
            abi.encodePacked(to, recipeID, nonce)
        );
        //Recreamos la firma
        bytes32 ethSignedHash = txHash.toEthSignedMessageHash();
        //Sacamos el signer con la firma recreada
        address signer = ethSignedHash.recover(signature);
        return signer;
    }

    /* ------------ END CRAFT ----------------  */

    /* ------------ MINT ----------------  */

    // function mint(
    //     address to,
    //     uint256 nonce,
    //     bytes memory signature
    // ) public payable checkFee returns (uint256) {
    //     address signer = getMintSigner(to, nonce, signature);
    //     require(_minters[signer], "Not permission to mint");
    //     require(!_usedNonces[nonce], "Nonces already used");
    //     _usedNonces[nonce] = true;

    //     uint256 _tokenId = _totalSupply + 1;
    //     _mint(to, _tokenId);
    //     _totalSupply = _totalSupply + 1;

    //     emit Mint(to, _tokenId);
    //     return _tokenId;
    // }

    // function getMintSigner(
    //     address _to,
    //     uint256 _nonce,
    //     bytes memory _signature
    // ) internal pure returns (address) {
    //     //Recreamos la llamada
    //     bytes32 txHash = keccak256(abi.encodePacked(_to, _nonce));
    //     //Recreamos la firma
    //     bytes32 ethSignedHash = txHash.toEthSignedMessageHash();
    //     //Sacamos el signer con la firma recreada
    //     address signer = ethSignedHash.recover(_signature);
    //     return signer;
    // }

    /* ------------ END MINT ----------------  */

    /* ------------   BURN   ----------------  */

    function burn(
        address to,
        uint256 tokenId,
        uint256 nonce,
        bytes memory signature
    ) public payable validateNonce(nonce) checkFee {
        require(ownerOf(tokenId) == to, "Not token owner");
        address signer = getBurnSigner(to, tokenId, nonce, signature);
        require(_burners[signer], "Not permission to mint");

        _burn(tokenId);
        emit Burn(tokenId);
    }

    function getBurnSigner(
        address _to,
        uint256 _tokenId,
        uint256 _nonce,
        bytes memory _signature
    ) internal pure returns (address) {
        //Recreamos la llamada
        bytes32 txHash = keccak256(abi.encodePacked(_to, _tokenId, _nonce));
        //Recreamos la firma
        bytes32 ethSignedHash = txHash.toEthSignedMessageHash();
        //Sacamos el signer con la firma recreada
        address signer = ethSignedHash.recover(_signature);
        return signer;
    }

    /* ------------ END BURN ----------------  */
}
