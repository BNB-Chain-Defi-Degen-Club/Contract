// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";

contract DDCToken is Ownable, ERC20 {
    ERC20 private DLPToken;
    address public DLPAddress;
    uint public totalBalance;
    mapping (address => uint) public borrowBalances;
    // mapping (address => mapping (string => uint)) borrowBalances; 추후 다른 토큰 추가될 경우
    uint DDCPer;
    mapping (address => uint) borrowTokenPer;
    uint borrowPercentage;
    uint decimal = 10 ** 18; 
    
    mapping (address => uint) fallbackBalances;

    constructor(string memory _name, string memory _symbol, ERC20 _DLPAddress) ERC20(_name, _symbol) {
        DLPToken = _DLPAddress;
        DLPAddress = address(_DLPAddress);
        DDCPer = 10 ** 3;
        borrowTokenPer[address(_DLPAddress)] = 10 ** 14;
        borrowPercentage = 9;
    }

    fallback() external payable {
        fallbackBalances[msg.sender] += msg.value;
    }

    receive() external payable {
        totalBalance += msg.value;
    }

    function setDepositAddress (ERC20 _address) public onlyOwner {
        DLPToken = _address;
        DLPAddress = address(_address);
    }

    function withdraw (address user, uint amount) public onlyOwner {
        (bool success, ) = payable(user).call{value: amount}("");
        require(success, "Error");
    }

    modifier borrowProcess(address[] memory tokenAddress, uint amount) {
        require(tokenAddress[0] != tokenAddress[1], "The collateral and loan cannot be the same coin.");
        if(tokenAddress[0] == DLPAddress) {
            uint DLPbalance = DLPToken.balanceOf(msg.sender);
            require(DLPbalance >= amount, "lack of margin");
            uint DLPApprove = DLPToken.allowance(msg.sender, address(this));
            require(DLPApprove >= amount, "Token access permission is required.");
        }
        _;
    }

    function borrow (address[] memory tokenAddress, uint amount) external payable { //tokenAddress[0]: 담보 코인, tokenAddress[1]: 대출 코인. BNB일 경우 msg.sender Addr, amount: 담보금 금액. BNB일 경우 아무 값이나
        if(tokenAddress[0] == msg.sender) {
            uint sendValue = msg.value / borrowTokenPer[DLPAddress] * borrowPercentage / 10;
            (bool success) = DLPToken.transfer(msg.sender, sendValue);
            require(success, "Fail to borrow");
            _mint(msg.sender, sendValue / DDCPer * decimal);
        } else if(tokenAddress[0] == DLPAddress) {
            uint sendValue = amount * borrowTokenPer[DLPAddress] * borrowPercentage / 10;
            (bool success1) = DLPToken.transferFrom(msg.sender, address(this), amount);
            require(success1, "DLP token transfer fail.");
            (bool success2, ) = payable(msg.sender).call{value: sendValue}("");
            require(success2, "ERROR");
            _mint(msg.sender, amount / DDCPer * decimal);
        }
    }

    function emergencyCall () public onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "");
    }
}