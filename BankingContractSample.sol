// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DefiToken.sol";

struct StakeInfo{
    uint256 stakeStart;
    uint256 amount;
}

contract Bank {

    string constant public BankName="MyBank";
    mapping(address => uint256) public _balances;
    mapping(address=> mapping(address => uint256)) public _tokenBalance;
    mapping(address=> mapping(address => StakeInfo[])) public _stakeBalance;
    mapping(string => IERC20) public tokens;

    DefiToken public defiToken;


    address owner;

    event Deposit ( address from, uint256 value);
    event Withdraw( address to, uint256 value);


    constructor() payable{
        _balances[msg.sender] = msg.value;
        owner = msg.sender;
        defiToken = new DefiToken();
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"transaction sender is not owner");
        _;
    }

    function deposit() public payable {

        _balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 value) public payable  {
        _balances[msg.sender] -=value;
        payable(msg.sender).transfer(value);
    }

    function balanceOf(address _owner) public view returns(uint256) {
        return _balances[_owner];
    }

    function stake(string memory tokenSYM, uint256 amount) public {
        address tokenAddress = address(tokens[tokenSYM]);
        require( tokenAddress != address(0));

        tokens[tokenSYM].transferFrom( msg.sender, address(this), amount);
        _stakeBalance[tokenAddress][msg.sender].push( StakeInfo(block.timestamp, amount));
    }

    function unstake(string memory tokenSYM, uint256 stakeIdx) public {
        address tokenAddress = address(tokens[tokenSYM]);
        require( tokenAddress != address(0));
        uint256 stakeLength = _stakeBalance[tokenAddress][msg.sender].length;
        require( stakeLength > stakeIdx);

        uint256 amount = _stakeBalance[tokenAddress][msg.sender][stakeIdx].amount;
        uint256 duration = block.timestamp - _stakeBalance[tokenAddress][msg.sender][stakeIdx].stakeStart;
        uint256 coupon = amount * duration  *  10 / 100 / 1 seconds;
        defiToken.mint(msg.sender, amount+coupon);

        _stakeBalance[tokenAddress][msg.sender][stakeIdx] = _stakeBalance[tokenAddress][msg.sender][stakeLength -1];
        _stakeBalance[tokenAddress][msg.sender].pop();

        tokens[tokenSYM].transfer( msg.sender, amount);
    }

    function addSupportToken(IERC20 _newToken, uint256 _exchangeRatio ) public {
        require( msg.sender == owner);
        string memory sym = _newToken.symbol();
        require( address(tokens[sym]) == address(0));
        tokens[sym] = _newToken;
    }

    

    fallback() external payable{
        deposit();
    }
    
}

interface IERC20 {
    function symbol() external view returns(string memory);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
