const { ethers } = require("hardhat");
const {LINK_address, OWNER} = require("../settings.json");

async function main() {
    const gasPrice = ethers.parseUnits('40', 'gwei'); // 40 Gwei

    // Get the contract factory for Operator
    const Operator = await ethers.getContractFactory("Operator");
    
    // Deploy the contract
    const operator = await Operator.deploy(LINK_address, OWNER, { gasPrice });
    console.log(`Operator deployed at: ${operator.target}`);
}

// Execute the deployment script
main()
.then(() => process.exit(0))
.catch(error => {
    console.error(error);
    process.exit(1);
});
