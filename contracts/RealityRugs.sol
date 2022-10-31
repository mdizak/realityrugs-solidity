// SPDX-License-Identifier: Commercial
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./lib/IFactoryERC721.sol";
import "./InitialRug.sol";
import "./FinalRug.sol";

/**
 * RealityRugs contract
 */
contract RealityRugs is FactoryERC721, Ownable {
    using Strings for string;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    address presaleAddress = address(0xad3030eea34dCAEa7B17c8668E08539b30F7Db27);
    address public proxyRegistryAddress;
    address public initialNftAddress;
    address public finalNftAddress;
    string public baseURI = "https://reality-rugs.realityrugs.apexpl.dev/meta/factory/";

    /**
     * Reality Rugs config vars
     */
    uint256 RUGS_SUPPLY = 3333;
    uint256 NUM_OPTIONS = 1;
    uint256 INITIAL_TOKEN_OPTION = 0;
    uint256 presalePrice = 100000000000000000;

    constructor(address _proxyRegistryAddress, address _finalNftAddress) {

        // Set properties
        proxyRegistryAddress = _proxyRegistryAddress;
        finalNftAddress = _finalNftAddress;
        initialNftAddress = address(
            new InitialRug(_proxyRegistryAddress, finalNftAddress)
        );

        fireTransferEvents(address(0), owner());
    }

    function name() override external pure returns (string memory) {
        return "Reality Rugs Item Sale";
    }

    function symbol() override external pure returns (string memory) {
        return "RUGS";
    }

    function supportsFactoryInterface() override public pure returns (bool) {
        return true;
    }

    function numOptions() override public view returns (uint256) {
        return NUM_OPTIONS;
    }

    function transferOwnership(address newOwner) override public onlyOwner {
        address _prevOwner = owner();
        super.transferOwnership(newOwner);
        fireTransferEvents(_prevOwner, newOwner);
    }

    function fireTransferEvents(address _from, address _to) private {
        for (uint256 i = 0; i < NUM_OPTIONS; i++) {
            emit Transfer(_from, _to, i);
        }
    }

    function mint(uint256 _optionId, address _toAddress) override public {

        // Must be sent from the owner proxy or owner.
        assert(
            proxyRegistryAddress == _msgSender() ||
            owner() == _msgSender()
        );
        require(canMint(_optionId));

        // Ensure token not already minted
        InitialRug initialRug = InitialRug(initialNftAddress);
        require((!initialRug.checkAddress(_toAddress)), "Only one token per-account allowed.");

        if (_optionId == INITIAL_TOKEN_OPTION) {
            initialRug.mintInitial(_toAddress);
        }

    }

    function canMint(uint256 _optionId) override public view returns (bool) {
        if (_optionId >= NUM_OPTIONS) {
            return false;
        }

        InitialRug initialRug = InitialRug(initialNftAddress);
        uint256 rugSupply = initialRug.totalSupply();

        return rugSupply < (RUGS_SUPPLY - 1);
    }

    function presale( uint8 _v, bytes32 _r, bytes32 _s) payable public {

        // Verify signature and amount
        require(verifySignature(_v, _r, _s), "Invalid signature");
    require(msg.value >= presalePrice, "Not enough funds sent");

        // Ensure token not already minted
        InitialRug initialRug = InitialRug(initialNftAddress);
        require((!initialRug.checkAddress(msg.sender)), "Only one token per-account allowed.");

        // Mint token
        initialRug.mintInitial(msg.sender);
    }



    function verifySignature( uint8 _v, bytes32 _r, bytes32 _s) private view returns (bool) {
        bytes32 _hash = keccak256(abi.encodePacked(msg.sender));
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 _message = keccak256(abi.encodePacked(prefix, _hash));
        address signer = ecrecover(_message, _v, _r, _s);
        return signer == presaleAddress;
    }

    function tokenURI(uint256 _optionId) override external view returns (string memory) {
        return string(abi.encodePacked(baseURI, Strings.toString(_optionId)));
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use transferFrom so the frontend doesn't have to worry about different method names.
     */
    function transferFrom(
        address,
        address _to,
        uint256 _tokenId
    ) public {
        mint(_tokenId, _to);
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        returns (bool)
    {
        if (owner() == _owner && _owner == _operator) {
            return true;
        }

        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (
            owner() == _owner &&
            address(proxyRegistry.proxies(_owner)) == _operator
        ) {
            return true;
        }

        return false;
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
     */
    function ownerOf(uint256) public view returns (address _owner) {
        return owner();
    }

    function initialAddress() public view returns (address) {
        return initialNftAddress;
    }

    function finalAddress() public view returns (address) {
        return finalNftAddress;
    }

    function withdraw(address _to, uint256 _amount) public payable onlyOwner {
        address payable addr = payable(_to);
        addr.transfer(_amount);
    }

}


