const hre = require("hardhat");
const fs = require('fs');

async function main() {  //Create the address for the RimeToken collection
    const MarketPlace = await hre.ethers.getContractFactory("AvianInstallment");
    const mplace_token = await MarketPlace.deploy();

    await mplace_token.deployed();

    console.log("MarketPlace deployed to:", mplace_token.address);
    fs.writeFileSync('./config.js', `
    insmplace_token = "${mplace_token.address}"
    
    module.exports = {
        insmplace_token,
    };
    `)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
