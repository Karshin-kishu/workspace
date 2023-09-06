// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
contract MyContract {
    uint public changecounter;
    address public owner;
    string public theMessage;
    constructor(){
        owner = msg.sender;
    }
    function UpdateTheMessenger(string memory _newMessage) public {
        if (msg.sender==owner){  
        theMessage = _newMessage;
        changecounter++;
        }
    }
}