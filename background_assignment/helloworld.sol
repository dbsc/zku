// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

contract HelloWorld {
    // declare variable of uint type
    uint number;

    function storeNumber(uint _number) public {
        // assign a value to the variable `number`
        number = _number;
    }

    function retrieveNumber() public view returns (uint) {
        // read the value of the variable `number` 
        return number;
    }
}
