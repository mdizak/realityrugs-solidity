// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./lib/ERC721Tradable.sol";
import "./FinalRug.sol";

/**
 * @title Reality Rug
 */
contract InitialRug is ERC721Tradable {
    address finalNftAddress;
    uint256 mutateMins = 15;
    mapping(uint256 => uint256) public timeMinted;
    mapping(address => uint256) public tokenOwners;

    constructor(address _proxyRegistryAddress, address _finalNftAddress)
        ERC721Tradable("Reality Rugs", "RUGT", _proxyRegistryAddress)
    {
        finalNftAddress = _finalNftAddress;
    }

    function mintInitial(address _to) public onlyOwner returns (uint256) {
        uint256 _tokenId = mintTo(_to);
        timeMinted[_tokenId] = block.timestamp;
        tokenOwners[_to] = _tokenId;
        return _tokenId;
    }

    function mutate(uint256 _tokenId) public payable {

        require(
            proxyRegistryAddress == _msgSender() || 
            owner() == _msgSender() || 
            ownerOf(_tokenId) == _msgSender(),
        "You do not own this token.");

        // Ensure we have serum
        require(hasSerum(_tokenId), "Not enough time has elapsed since initial mint to mutate.");

        // Mint new token
        FinalRug finalRug = FinalRug(finalNftAddress);
        finalRug.mutate(_tokenId);

        // Burn initial token
        _burn(_tokenId);
    }

    function hasSerum(uint256 _tokenId) public view returns (bool) {

        if ((timeMinted[_tokenId] + (mutateMins * 60)) > block.timestamp) {
            return false;
        }
        return true;
    }

    function checkAddress(address _addr) public view returns (bool) {

        if (tokenOwners[_addr] == 0) {
            return false;
        }
        return true;
    }

    function getTokenId(address _addr) public view returns (uint256) {
        return tokenOwners[_addr];
    }

}

