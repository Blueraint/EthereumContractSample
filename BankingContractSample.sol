// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    string constant public BankName="NaverBank";
    uint256 balance = 0;
    address owner;

    event Deposit ( address from, uint256 value);
    event Withdraw( address to, uint256 value);

    constructor() payable {
        balance = msg.value;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Tx sender is not owner");
        _;
    }

    function deposit() public payable {
        if(msg.sender != owner) revert("Tx sender is not owner");
        balance += msg.value;
        emit Deposit(msg.sender, msg.value); // message 기능 구현
    }

    function withdraw(uint256 value) public payable {
        if(msg.sender != owner) revert("Tx sender is not owner");        
        balance -= value;
        payable(msg.sender).transfer(value);
    }

    function getBalance() public view returns(uint256) {
        return balance;
    }

    fallback() external payable {
        deposit();
    }
}
