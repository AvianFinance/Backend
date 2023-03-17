const { ethers } = require("hardhat")
const { sexchange_token } = require('../config')
const fs = require('fs');
const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/ASEProxy.sol/ASE_Proxy.json', 'utf-8'))

async function pullProceeds(signer) {

    const mplace_contract = new ethers.Contract(sexchange_token, Marketplace.abi, signer)

    console.log("Retrieving proceeds for the signer...")
    const tx = await mplace_contract.withdrawProceeds()

    return("proceeds: ", tx)
}

module.exports = {
    pullProceeds,
};
