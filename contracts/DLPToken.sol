// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";

contract DLPToken is Ownable, ERC20 {
    address payable public DDCAddress;
    ERC20 private DDCToken;
    mapping (address => uint) stakingBalances;
    // mapping (address => mapping (string => uint)) stakingBalance; 추후 스테이킹 풀 별로 구분하기 위함
    mapping (string => uint128) public DLPRatio;
    uint public totalStaking;
    uint decimal = 18; 

    mapping (address => uint) fallbackBalances;

    constructor(string memory _name, string memory _symbol, address payable _DDCAddress) ERC20(_name, _symbol) {
        DDCAddress = payable(_DDCAddress);
        DLPRatio["BNB"] = 10 ** 14; // 1 BNB (10^18) = 10^4 DLP 
    }

    fallback() external payable {
        fallbackBalances[msg.sender] += msg.value;
    }

    receive() external payable {
        fallbackBalances[msg.sender] += msg.value;
    }

    function setStakingAddress (address payable _address) public onlyOwner {
        DDCAddress = payable(_address);
        _mint(_address, 10 ** 10 * decimal);
    }    

    function changeDLPRatio(string memory CoinSymbol, uint128 Ratio) public onlyOwner { // 코인 교환비 설정
        DLPRatio[CoinSymbol] = Ratio;
    }

    function getDLPRatio(string memory CoinSymbol) public view returns(uint128) {
        return DLPRatio[CoinSymbol];
    }

    modifier buyDLPProcess () {
        require(msg.value >= 0.0001 ether, "Minimum amount is 0.0001 BNB");
        _;
    }

    function buyDLP() external payable buyDLPProcess() {
        (bool success, ) = payable(DDCAddress).call{value: msg.value}("");
        require(success, "");
        uint DLPamount = msg.value / DLPRatio["BNB"] * decimal;
        _mint(msg.sender, DLPamount);
    }

    modifier sellDLPProcess (uint DLPamount) {
        require(balanceOf(msg.sender) >= DLPamount, "No balance");
        _;
    }

    function sellDLP(uint DLPamount) external sellDLPProcess(DLPamount) {
        _burn(msg.sender, DLPamount);
        (bool success2, ) = msg.sender.call{value: DLPamount * DLPRatio["BNB"] / decimal}("");
        require(success2, "Error");
    }

    modifier stakeProcess (uint DLPamount) {
        require(balanceOf(msg.sender) >= DLPamount  , "No balance.");
        _;
    }

    function stake(uint DLPamount) public stakeProcess(DLPamount){
        (bool success) = transfer(DDCAddress, DLPamount);
        require(success);
        stakingBalances[msg.sender] += DLPamount;
        totalStaking += DLPamount;
    }

    modifier unstakeProcess (uint DLPamount) {
        require(stakingBalances[msg.sender] >= DLPamount, "a shortage of staking balance");
        _;
    }

    function unstake(uint DLPamount) public unstakeProcess(DLPamount){
        stakingBalances[msg.sender] -= DLPamount;
        totalStaking -= DLPamount;
    }

    function balanceOf() public view returns(uint amount) { // DLP 밸런스
        amount = balanceOf(msg.sender);
    }

    function getStakingBalance() public view returns(uint amount) { // staking 밸런스
        amount = stakingBalances[msg.sender];
    }

    function getStakingBalance(address account) public view returns(uint amount) { // 적금 밸런스
        amount = stakingBalances[account];
    }

    
    function emergencyCall () public onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "");
    }
}