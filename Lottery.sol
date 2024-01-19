//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable {
    uint256 players; // To track total number of players
    uint256 winner; // to track total number of winners

    error OnlyEOA();
    error NotEnoughETHPaid();
    error NotPlayer();
    error NotWinner();
    error RewardSendingFailed();
    error LotteryNotStarted();
    error LotteryStillRunning();
    error LotteryClosed();
    error EnterClosed();
    error AlreadyPlayer();
    error WithdrawalFailed();
    error QuizWinnersNotAllowedNow();

    // Status of lottery game
    enum State {
        open,
        running,
        closed
    }

    State public state;

    enum AllowQuizWinners {
        False,
        True
    }

    AllowQuizWinners public AQW;

    mapping(address => uint256) public isPlayer; // to check whether the caller is player or not
    mapping(address => uint256) public winners; // To track winner's address

    address[] internal WhitelistedForHash;

    constructor(address initalOwner) Ownable(initalOwner) {}

    /**
     * @notice This function can only be called when state is Open
     */
    function deposit() external payable onlyEOA {
        if (isPlayer[msg.sender] == 2) {
            revert AlreadyPlayer();
        }
        if (state != State.open) {
            revert EnterClosed();
        }
        if (msg.value < 0) {
            revert NotEnoughETHPaid();
        }
        isPlayer[msg.sender] = 2;
        players++;
        WhitelistedForHash.push(msg.sender);
    }

    /**
     * @notice When state is open quiz winners can enter in lottery, as they won in quiz they don't need to pay
     * Important: This function must be called from front end and it is front-end dev's resposibility to make available this function only to those users who won is quiz
     * When a user won a quiz he should get the option to call this function to enter the lottery.
     */
    function enterFromQuiz() external onlyEOA {
        if (state != State.open) {
            revert EnterClosed();
        }
        if (AQW != AllowQuizWinners.True) {
            revert QuizWinnersNotAllowedNow();
        }
        isPlayer[msg.sender] = 2;
        players++;
        WhitelistedForHash.push(msg.sender);
    }

    /**
     * @notice This function can only be called when state is Running
     * @param _number Any random number from 0 to 99 choosed by players
     * Benifit: A functionality was added that a player can try as many times he wants until he wins and until we have 3 winners. After having 3 winners
     * this function will be automatically blocked. It will increase transaction in our dapp. But the trick is if a winner tried more than 1 time and wins
     * more than 1 time it will be consider as 1 win, there is no revert/error for him.
     */
    function pickNumber(uint256 _number) external onlyEOA {
        if (winner == 3) {
            state = State.closed;
        }
        if (state != State.running) {
            revert LotteryNotStarted();
        }

        if (isPlayer[msg.sender] != 2) {
            revert NotPlayer();
        }
        uint256 number = _generateRandomNumber(100);
        if (number == _number) {
            if (winners[msg.sender] != 1) {
                // no matter how many times a player wins, 1 win is equal to 1000 win. He will be rewarded only one time.
                winners[msg.sender] = 1;
                winner++;
            } else {
                return;
            }
        }
    }

    function _generateRandomNumber(uint256 _number) private view returns (uint256) {
        uint256 number = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp))) % _number;
        return number;
    }

    function getReward() external onlyEOA {
        if (state != State.closed) {
            revert LotteryStillRunning();
        }
        if (winners[msg.sender] != 1) {
            revert NotWinner();
        }
        uint256 number = _generateRandomNumber(10);
        if (number > 7) {
            delete winners[msg.sender];
            _sendETH(msg.sender, 30);
        } else if (number > 4 && number <= 7) {
            delete winners[msg.sender];
            _sendETH(msg.sender, 20);
        } else if (number <= 4) {
            delete winners[msg.sender];
            _sendETH(msg.sender, 10);
        }
    }

    function _sendETH(address _winner, uint256 _percentage) private {
        (bool success,) = payable(_winner).call{value: (address(this).balance * _percentage) / 100}("");
        if (!success) {
            revert RewardSendingFailed();
        }
    }

    function switchState() external onlyOwner onlyEOA {
        if (state == State.open) {
            state = State.running;
        } else if (state == State.running) {
            state = State.closed;
        } else if (state == State.closed) {
            state = State.open;
        }
    }

    function SwitchQuizAllowance() external onlyOwner onlyEOA {
        if (AQW == AllowQuizWinners.False) {
            AQW = AllowQuizWinners.True;
        } else {
            AQW = AllowQuizWinners.False;
        }
    }

    function withdraw() external onlyOwner onlyEOA {
        (bool success,) = payable(owner()).call{value: address(this).balance}("");
        if (!success) {
            revert WithdrawalFailed();
        }
    }

    function getWhitelistedAddressForHASH() external view onlyEOA returns (address[] memory) {
        return WhitelistedForHash;
    }

    function checkBalance() external view onlyOwner onlyEOA returns (uint256) {
        return address(this).balance;
    }

    modifier onlyEOA() {
        if (msg.sender.code.length > 0) {
            revert OnlyEOA();
        }
        _;
    }
}
