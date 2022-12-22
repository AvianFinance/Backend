
const hre = require("hardhat");
const fs = require('fs');

async function main() {  //Create the address for the RimeToken collection
  const RimeToken = await hre.ethers.getContractFactory("RimeToken");
  const rime_token = await RimeToken.deploy();

  await rime_token.deployed();

  console.log("RimeToken deployed to:", rime_token.address);
  fs.writeFileSync('./config.js', `
  rime_token = "${rime_token.address}"
  
  module.exports = {
      rime_token,
  };
  `)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
