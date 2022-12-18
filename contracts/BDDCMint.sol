// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";

contract BDDCMint is Ownable, ERC721Enumerable {
    string public metadataURI;
    uint constant public TOTAL_NFT = 100;
    uint constant public Price = 0.001 ether;
    address payable payments;
    event SetBlacklist(address user, bool status);
    mapping(address => bool) public blacklist;

    constructor(address _payments) ERC721("BNB Chain Defi Degen Club", "BDDC"){
        // metadataURI = _metadataURI;
        metadataURI = "https://gateway.pinata.cloud/ipfs/QmWd93y42ye4zKAC19QTcDHkxzoeBfcSumLDdFEPvJJkdk/";
        payments = payable(_payments);
    }
    
    modifier costs (uint amount) {
        require(TOTAL_NFT >= totalSupply() + amount, "No more mint.");
        require(msg.value >= Price*amount, "Not enough BNB provided.");
        _;
    }

    function mintNFT(uint16 amount) public payable costs(amount) {
        (bool success, ) = payable(payments).call{value: msg.value}("");
        require(success);
        for(uint i = 0; i < amount; i++) {
            uint tokenId = totalSupply() + 1;
            _mint(msg.sender, tokenId);
        }
    }

    function mintableAmount() public view returns(string memory text) {
        uint mintable = TOTAL_NFT - totalSupply();
        text = string(abi.encodePacked("Amount of mintable is ", Strings.toString(mintable)));
    }
    
    function tokenURI(uint _tokenId) public override view returns(string memory) {
        return string(abi.encodePacked(metadataURI, '/', Strings.toString(_tokenId%10), '.json'));
    }

    function getNFTs(address _owner) public view returns(uint[] memory) {
        require(balanceOf(_owner) > 0, "Owner does not have NFT.");
        uint[] memory myNFTs = new uint[](balanceOf(_owner));
        
        for(uint i = 0; i < balanceOf(_owner); i++) {
            myNFTs[i] = tokenOfOwnerByIndex(_owner, i); 
        }
 
        return myNFTs;
    }

    function setBlacklist(address user, bool status) external onlyOwner {
        blacklist[user] = status;
        emit SetBlacklist(user, status);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721) {
        require(!blacklist[msg.sender] && !blacklist[from] && !blacklist[to], "BLACKLIST");
        super.transferFrom(from, to, tokenId);
    }
}