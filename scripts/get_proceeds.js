const { ethers } = require("hardhat")
const { mplace_token } = require('../config')

const fs = require('fs');
const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/Marketplace.sol/Marketplace.json', 'utf-8'))
const RimeToken = JSON.parse(fs.readFileSync('./artifacts/contracts/RimeToken.sol/RimeToken.json', 'utf-8'))


async function pullProceeds(signer) {

    const mplace_contract = new ethers.Contract(mplace_token, Marketplace.abi, signer)

    console.log("Retrieving proceeds for the signer...")
    const tx = await mplace_contract.withdrawProceeds()

    return("proceeds: ", tx)
}

// pull_proceeds(signer)
//     .then(() => process.exit(0))
//     .catch((error) => {
//         console.error(error)
//         process.exit(1)
//     })


module.exports = {
    pullProceeds,
};
