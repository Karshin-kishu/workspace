// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 < 0.9.0;

import "./Owned.sol";
import "./Logger.sol";
import "./Ifaucet.sol";

contract Faucet is Owned , Logger , Ifaucet {
    uint public numOfFunders;

    mapping(uint => address) private lutfunders;
    mapping(address => bool) private funders;

    modifier limitWithdraw(uint withdrawAmount) {
        require(
            withdrawAmount <= 100000000000000000,
            "Cannot withdraw not more than 0.1 ether"
        );
        _;
    }

    receive() external payable {}

    function emitLog() public pure override returns (bytes32) {
        return "Hello World";
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function addFunds() override external payable {
        address funder = msg.sender;
        if (!funders[funder]) {
            numOfFunders++;
            funders[funder] = true;
            lutfunders[numOfFunders] = funder;
        }
    }

    function test1() external onlyOwner {}

    function test2() external onlyOwner {}

    function withdraw(uint withdrawAmount) override external {
        require(
            withdrawAmount <= 100000000000000000,
            "Cannot withdraw not more than 0.1 ether"
        );
        payable(msg.sender).transfer(withdrawAmount);
    }

    function getAllFunders() external view returns (address[] memory) {
        address[] memory _funders = new address[](numOfFunders);
        for (uint i = 0; i < numOfFunders; i++) {
            _funders[i] = lutfunders[i];
        }
        return _funders;
    }

    function getFunderAtIndex(uint8 index) external view returns (address) {
        return lutfunders[index];
    }
}
