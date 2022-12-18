// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "../node_modules/@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Payments is Context, PaymentSplitter, Ownable {
    address private withdrawAddress;

    constructor(address[] memory _payees, uint256[] memory _shares) PaymentSplitter(_payees, _shares) payable {}

    function release(address payable account) public override onlyOwner {}

    function release(IERC20 token, address account) public override onlyOwner {}
}