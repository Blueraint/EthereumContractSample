pragma solidity ^0.8.0;

contract Proxy {
    address public implementation;

    function setImplementation(address _newImp) public {
        implementation = _newImp;
    }
    
    fallback () payable external {
        address impl = implementation;
        require(impl != address(0));
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize()) // (1) Copy incoming call data
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0) // (2) forward call to logic contract
            let size := returndatasize()
            returndatacopy(ptr, 0, size) // (3) retrieve return data
            switch result // (4) forward return data back to caller
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}

contract Sample is Proxy{

    string public Title;

    event Log(uint256 timestamp, string text);

    function foo() pure public returns(uint256){
        return 200;
    }

    function doo()  public returns(uint256){
        Title="Hello";
        emit Log(block.timestamp, "foo");
        return 100;
    } 

}
