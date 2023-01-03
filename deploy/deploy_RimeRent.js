
const hre = require("hardhat");
const fs = require('fs');

async function main() {  //Create the address for the RimeToken collection
    const RimeRent = await hre.ethers.getContractFactory("RimeRent");
    const rime_rent = await RimeRent.deploy();

    await rime_rent.deployed();

    console.log("RimeRent deployed to:", rime_rent.address);
    fs.writeFileSync('./config.js', `
    rime_rent = "${rime_rent.address}"

    module.exports = {
        rime_rent,
    };
    `)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
    console.error(error);
    process.exit(1);
    });
