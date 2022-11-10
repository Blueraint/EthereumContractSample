pragma solidity ^0.5.0;

contract HelloWorld{
    address public creator;

    event Hi(address indexed);

    constructor() public {
        creator = msg.sender;
    }

    function hi() public {
        emit Hi(msg.sender);
    }

    function changeCreator() public {
        creator = msg.sender;
    }
}
