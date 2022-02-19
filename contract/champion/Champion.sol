// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/djgonza/NFTFragmentsContracts/blob/master/library/ECDSA.sol";
import "https://github.com/djgonza/NFTFragmentsContracts/blob/master/contract/utils/Permission.sol";
import "https://github.com/djgonza/NFTFragmentsContracts/blob/master/contract/utils/FeeController.sol";
import "https://github.com/djgonza/NFTFragmentsContracts/blob/master/contract/utils/NonceController.sol";

contract Champion is ERC721, Permission, FeeController, NonceController {

    using ECDSA for bytes32;

    uint256 public _totalSupply;

    event Mint (address to, uint256 championId);
    event Burn (uint256 championId);

    constructor()
        ERC721("Kokull champion", "KKLC")
        Permission()
        FeeController()
    {
    }

    /* ------------ MINT ----------------  */

    function mint(
        address to,
        uint256 nonce,
        bytes memory signature
    ) public payable validateNonce(nonce) payFee returns (uint256) {
        address signer = getMintSigner(to, nonce, signature);
        require(_minters[signer], "Not permission to mint");

        uint256 tokenId = _totalSupply + 1;
        _mint(to, tokenId);
        _totalSupply = tokenId;

        emit Mint(to, tokenId);
        return tokenId;       

    }

    function getMintSigner(
        address _to,
        uint _nonce,
        bytes memory _signature
    ) internal pure returns (address) {
        //Recreamos la llamada
        bytes32 txHash = keccak256(abi.encodePacked(_to, _nonce));
        //Recreamos la firma
        bytes32 ethSignedHash = txHash.toEthSignedMessageHash();
        //Sacamos el signer con la firma recreada
        address signer = ethSignedHash.recover(_signature);
        return signer;
    }


    /* ------------ END MINT ----------------  */

    /* ------------   BURN   ----------------  */

    function burn(
        address to,
        uint256 tokenId,
        uint256 nonce,
        bytes memory signature
    ) public payable validateNonce(nonce) payFee {
        require(ownerOf(tokenId) == to, "Not token owner");
        address signer = getBurnSigner(to, tokenId, nonce, signature);
        require(_burners[signer], "Not permission to mint");

        _burn(tokenId);
        emit Burn(tokenId);     
    }

    function getBurnSigner(
        address _to,
        uint256 _tokenId,
        uint _nonce,
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
