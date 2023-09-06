// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
contract SampleMappingWithdrawals {

    mapping (address => uint) public BalanceRecieved;
    function sendMoney () public payable {
        BalanceRecieved[msg.sender]+=msg.value;
    }
    function getBalance () public view returns (uint){
        return address(this).balance;
    }
    function WithdrawAllMoney(address payable _to ) public {
        uint balanceToSendOut = BalanceRecieved[msg.sender];
        BalanceRecieved[msg.sender] = 0;
        _to.transfer(balanceToSendOut);
    }
}