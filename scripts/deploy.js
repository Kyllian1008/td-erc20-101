const hre = require("hardhat");
async function main() {
    const [deployer] = await hre.ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    // Hardcoded address of the existing ERC20Claimable token
    const teacherTokenAddress = "0x5ADeBf74a71360Be295534274041ceeD6A39977a"; // claimable
    const solutionTokenAddress = "0xAb8259776CD1D844941B94257547c32D0078312B"; // Replace with your ExerciseSolutionToken address

    // Deploy the ExerciseSolution contract
    const ExerciseSolution = await hre.ethers.getContractFactory("ExerciseSolution");
    const exerciseSolution = await ExerciseSolution.deploy(teacherTokenAddress, solutionTokenAddress);

    console.log("ExerciseSolution deployed to:", exerciseSolution.target);

    // Create a contract instance for the existing ERC20Claimable token
    const ERC20Claimable = await hre.ethers.getContractFactory("ERC20Claimable");
    const claimableToken = ERC20Claimable.attach(teacherTokenAddress); // Attach to the existing token

    // Approve the ExerciseSolution contract to spend tokens on behalf of the teacher
    await claimableToken.approve(exerciseSolution.target, 100);
    console.log("Approved ExerciseSolution to spend tokens.");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
    

