// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ExerciseSolutionToken is ERC20, Ownable {
    mapping(address => bool) public isMinter; // List of addresses allowed to mint
    mapping(address => bool) public isController;

    // Constructor to initialize the token
    constructor() ERC20("ExerciseSolutionToken", "EST") {
        isController[msg.sender] = true;
    }

    // Function to add a new minter
    function addMinter(address _minter) public {
        isMinter[_minter] = true;
    }

    // Function to mint new tokens, callable by authorized minters
    function mint(address to, uint256 amount) external {
        require(isMinter[msg.sender], "Caller is not authorized to mint");
        _mint(to, amount);
    }
        // Function to remove a minter
    function removeMinter(address _minter) public {
        require(isController[msg.sender], "Caller is not a controller");
        isMinter[_minter] = false;
    }

    // Function to add a controller
    function addController(address _controller) public onlyOwner {
        isController[_controller] = true;
    }

    // Function to remove a controller
    function removeController(address _controller) public onlyOwner {
        isController[_controller] = false;
    }

}
