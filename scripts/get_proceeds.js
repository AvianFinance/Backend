const { ethers } = require("hardhat")
const { sell_proxy_addr } = require('../config')
const fs = require('fs');
const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/ASEProxy.sol/ASE_Proxy.json', 'utf-8'))

async function pullProceeds(signer) {

    const mplace_contract = new ethers.Contract(sell_proxy_addr, Marketplace.abi, signer)

    console.log("Retrieving proceeds for the signer...")
    const tx = await mplace_contract.withdrawProceeds()

    return("proceeds: ", tx)
}

async function viewProceeds(signer) {

    const mplace_contract = new ethers.Contract(sell_proxy_addr, Marketplace.abi, signer)

    console.log("Retrieving proceeds for the signer...")
    const tx = await mplace_contract.getProceeds()

    return("proceeds: ", tx)
}

module.exports = {
    viewProceeds,
    pullProceeds
};
