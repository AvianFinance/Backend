const { ethers } = require("hardhat")
const { amplace_token } = require('../config')

const fs = require('fs');
// const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/Marketplace.sol/Marketplace.json', 'utf-8'))
const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/AvianMarket.sol/AvianMarket.json', 'utf-8'))

async function pullProceeds(signer) {

    const mplace_contract = new ethers.Contract(amplace_token, Marketplace.abi, signer)

    console.log("Retrieving proceeds for the signer...")
    const tx = await mplace_contract.withdrawProceeds()

    return("proceeds: ", tx)
}

module.exports = {
    pullProceeds,
};
