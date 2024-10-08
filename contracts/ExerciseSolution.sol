// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "./ERC20Claimable.sol"; // Import the ERC20Claimable contract
import "./IExerciseSolution.sol";
import "./ExerciseSolutionToken.sol"; 

contract ExerciseSolution is IExerciseSolution {
    ERC20Claimable public token; // Reference to the ERC20 token contract
    ExerciseSolutionToken public solutionToken; 
    mapping(address => uint256) public claimedTokens; // Track claimed tokens
    mapping(address => mapping(uint256 => bool)) public exerciseProgression;
    address public teacherAddress; // Address of the teacher's ERC20 contract

    constructor(address _tokenAddress, address _solutionTokenAddress) {
        token = ERC20Claimable(_tokenAddress);
        teacherAddress = _tokenAddress;
        solutionToken = ExerciseSolutionToken(_solutionTokenAddress);

        // Ajouter le contrat comme minter pour le token
        solutionToken.addMinter(address(this));
    }

    // Claim tokens on behalf of the sender
    function claimTokensOnBehalf() external override {
        uint256 amountToClaim = 10; // Amount to claim

        // Ensure the user hasn't claimed tokens before
        require(claimedTokens[msg.sender] == 0, "Tokens already claimed");

        // Ensure the teacher has approved this contract to transfer tokens
        require(token.allowance(teacherAddress, address(this)) >= amountToClaim, "Not enough allowance");

        // Update the claimed amount
        claimedTokens[msg.sender] += amountToClaim;

        // Claim tokens from the ERC20Claimable contract
        token.claimTokens(); // This mints tokens to the caller

        // Mint equivalent ExerciseSolutionTokens to the user
        solutionToken.mint(msg.sender, amountToClaim);

        // Transfer tokens from the teacher to this contract
        token.transferFrom(teacherAddress, address(this), amountToClaim);
    }

    // Get the amount of tokens in custody for a specific address
    function tokensInCustody(address callerAddress) external view override returns (uint256) {
        return claimedTokens[callerAddress];
    }

    // Withdraw tokens to the caller's address
    function withdrawTokens(uint256 amountToWithdraw) external override returns (uint256) {
        uint256 amountToClaim = 10; // Amount to claim
        
        require(claimedTokens[msg.sender] >= amountToWithdraw, "Not enough tokens claimed");

        // Reduce the claimed amount
        claimedTokens[msg.sender] -= amountToWithdraw;

        // Transfer tokens to the user
        token.transfer(msg.sender, amountToWithdraw);
        return amountToWithdraw;

        // Burn the corresponding ExerciseSolutionTokens
        solutionToken.mint(msg.sender, amountToClaim);
    }


    function getERC20DepositAddress() external view override returns (address) {
        return address(token);
    }

    // Allow the contract to spend tokens on behalf of the user
    function approveSpender(uint256 amount) external {
        token.approve(0x5ADeBf74a71360Be295534274041ceeD6A39977a, amount);
    }

    // Check the balance of tokens held by the contract
    function checkBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    // Révoquer l'autorisation pour le contrat ExerciseSolution de dépenser des jetons
    function revokeAuthorization() external {
        token.approve(address(this), 0); // Révoquer l'autorisation en la mettant à zéro
    }

    function depositTokens(uint256 amount) external override returns (uint256) {
        // Check that the user has approved the contract to spend tokens
        require(token.allowance(msg.sender, address(this)) >= amount, "Not enough allowance");

        // Transfer tokens from the user to the contract
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");

        // Update the amount of tokens held by the user
        claimedTokens[msg.sender] += amount;

        // Mint ExerciseSolutionTokens to the user
        solutionToken.mint(msg.sender, amount); // Mint tokens equivalent to the deposited amount

        return amount; // Return the deposited amount
    }


}