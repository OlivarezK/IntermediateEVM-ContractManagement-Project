// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

//import "hardhat/console.sol";

contract Assessment {
    address payable public owner;
    uint256 public balance;
    string private currency = "ETH";

    event Deposit(uint256 amount);
    event Withdraw(uint256 amount);
    event Convert();

    constructor(uint initBalance) payable {
        owner = payable(msg.sender);
        balance = initBalance;
    }

    function getBalance() public view returns(uint256){
        return balance;
    }

    function deposit(uint256 _amount) public payable {
        uint _previousBalance = balance;

        // make sure this is the owner
        require(msg.sender == owner, "You are not the owner of this account");

        // check current currency
        if (keccak256(abi.encodePacked(currency)) == keccak256(abi.encodePacked("GWEI"))){
            _amount *= 1000000000;
        }

        // perform transaction
        balance += _amount;

        // assert transaction completed successfully
        assert(balance == _previousBalance + _amount);

        // emit the event
        emit Deposit(_amount);
    }

    // custom error
    error InsufficientBalance(uint256 balance, uint256 withdrawAmount);

    function withdraw(uint256 _withdrawAmount) public {
        require(msg.sender == owner, "You are not the owner of this account");
        uint _previousBalance = balance;
        if (balance < _withdrawAmount) {
            revert InsufficientBalance({
                balance: balance,
                withdrawAmount: _withdrawAmount
            });
        }

        // check current currency
        if (keccak256(abi.encodePacked(currency)) == keccak256(abi.encodePacked("GWEI"))){
            _withdrawAmount *= 1000000000;
        }

        // withdraw the given amount
        balance -= _withdrawAmount;

        // assert the balance is correct
        assert(balance == (_previousBalance - _withdrawAmount));

        // emit the event
        emit Withdraw(_withdrawAmount);
    }

    function convertCurrency() public {
        require(msg.sender == owner, "You are not the owner of this account");
        uint _previousBalance = balance;

        // check current currency
        if (keccak256(abi.encodePacked(currency)) == keccak256(abi.encodePacked("ETH"))){
            // convert eth to gwei
            balance *= 1000000000;
            currency = "GWEI";
            
            assert(balance == (_previousBalance *= 1000000000));
            assert(keccak256(abi.encodePacked(currency)) == keccak256(abi.encodePacked("GWEI")));
        }else {
            // convert gwei to eth
            balance /= 1000000000;
            currency = "ETH";

            assert(balance == (_previousBalance /= 1000000000));
            assert(keccak256(abi.encodePacked(currency)) == keccak256(abi.encodePacked("ETH")));
        }

        // emit the event
        emit Convert();
    }
}
