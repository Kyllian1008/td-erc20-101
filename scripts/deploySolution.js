const hre = require("hardhat");

async function main() {
    // Déployer le contrat ExerciseSolutionToken
    const ExerciseSolutionToken = await hre.ethers.getContractFactory("ExerciseSolutionToken");
    const exerciseSolutionToken = await ExerciseSolutionToken.deploy();

    console.log("ExerciseSolutionToken déployé à l'adresse:", exerciseSolutionToken.target);
}

// Exécuter la fonction principale et gérer les erreurs
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });