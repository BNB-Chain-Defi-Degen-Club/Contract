// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract BDDCGame {
    address payable payments;
    uint gamePee = 0.001 ether;

    constructor(address _payments) {
        payments = payable(_payments);
    }
    
    modifier costs () {
        require(msg.value >= gamePee, "Not enough BNB provided.");
        _;
    }

    function insertCoin() public payable costs(){
        (bool success, ) = payable(payments).call{value: msg.value}("");
        require(success);
    }
}