const { ethers } = require("hardhat");
const fs = require('fs');
const highLevelOracleAbi = JSON.parse(fs.readFileSync('./artifacts/contracts/PriceOracle.sol/PriceOracle.json')).abi;
const {LINK_address, oracleAddress} = require('../settings.json')
const ORACLE_PAYMENT = ethers.parseUnits("1", 18);


describe("Token Balance Check", function () {
    let provider, deployer, LINK, oracle;
    this.timeout(60000); // 60 seconds

    before(async function () {
        [deployer] = await ethers.getSigners();
        provider = deployer.provider;

        LINK = await ethers.getContractAt([
            "function deposit() payable",
            "function balanceOf(address) view returns (uint256)",
            "function approve(address spender, uint256 amount) external returns (bool)",
            "function allowance(address owner, address spender) view returns (uint256)",
            "function transfer(address recipient, uint256 amount) external returns (bool)"
        ], LINK_address);

        oracle = new ethers.Contract(oracleAddress, highLevelOracleAbi, deployer);
    });

    it("should approve LINK tokens for PriceOracle contract", async function () {
        // Approve the PriceOracle contract to spend LINK tokens
        const tx = await LINK.connect(deployer).approve(oracle.target, ORACLE_PAYMENT);
        await tx.wait();
        console.log(`Approved PriceOracle to spend ${ethers.formatUnits(ORACLE_PAYMENT, 18)} LINK tokens`);
    });

    it("should call requestEthereumPrice of HighLevelOracleBalance", async function () {
        // Call the requestCryptocompareCoinPrice function
        const tx = await oracle.requestCryptocompareCoinPrice("ETH");
        const receipt = await tx.wait();
        console.log("Requested Ethereum price from PriceOracle");
    });
})
