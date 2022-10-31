// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./lib/ERC721Tradable.sol";
import "./InitialRug.sol";

/**
 * @title Reality Rugs Final
 */
contract FinalRug is ERC721Tradable {
    address initialNftAddress;

    constructor(address _proxyRegistryAddress) 
        ERC721Tradable("Reality Rugs Final", "RUGF", _proxyRegistryAddress)
    {

    }

    function mutate(uint256 _tokenId) public {

        // Initialize
        InitialRug initialRug = InitialRug(initialNftAddress);
        address _owner = initialRug.ownerOf(_tokenId);
        require(!_exists(_tokenId), "Token already mutated into final.");

        // Ensure owner
        require(
            _msgSender() == initialNftAddress ||
            _msgSender() == proxyRegistryAddress || 
            _msgSender() == owner() || 
            _owner == _msgSender(), 
        "You do not own this token.");

        // Ensure we can mutate
        require(initialRug.hasSerum(_tokenId), "Not enough time has elapsed since initial mint to mutate.");

        // Mint new token
        _mint(_owner, _tokenId);
    }

    function setInitialAddress(address _initialNftAddress) public onlyOwner {
        initialNftAddress = _initialNftAddress;
    }

    function getInitial() public view returns (address) {
        return initialNftAddress;
    }

}
