const { ethers } = require("hardhat");
const fs = require('fs');
const highLevelOracleAbi = JSON.parse(fs.readFileSync('./artifacts/contracts/PriceOracle.sol/PriceOracle.json')).abi;
const {LINK_address, oracleAddress} = require('../../settings.json')
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

    it("should call requestCrossChainCoinPrice", async function () {

        // Define the cross-chain price request
        const crossChainPriceRequest = [
            { 
                rpcUrl: "https://bsc-dataseed.binance.org/", 
                priceFeedContract:"0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE" 
            },
            { 
                rpcUrl: `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`, 
                priceFeedContract: "0x14e613AC84a31f709eadbdF89C6CC390fDc9540A" 
            },
            { 
                rpcUrl: "", 
                priceFeedContract: "" 
            }
        ];

        // Call the requestCrossChainCoinPrice function
        const tx = await oracle.requestCrossChainCoinPrice(crossChainPriceRequest);
        const receipt = await tx.wait();
        console.log("Requested Cross Chain Coin Price price from PriceOracle");
    });
})
