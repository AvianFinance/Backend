const { ethers } = require("hardhat")
const { mplace_token } = require('../config')
const { rime_token } = require('../config')

const fs = require('fs');
const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/Marketplace.sol/Marketplace.json', 'utf-8'))
const RimeToken = JSON.parse(fs.readFileSync('./artifacts/contracts/RimeToken.sol/RimeToken.json', 'utf-8'))



async function ViewListing(tokenId, signer) {

    const mplace_contract = new ethers.Contract(mplace_token, Marketplace.abi, signer)
    const token_contract = new ethers.Contract(rime_token, RimeToken.abi, signer)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getListing(token_contract.address, tokenId)

    return("Listing data: ", tx)
}

// ViewListing()
//     .then(() => process.exit(0))
//     .catch((error) => {
//         console.error(error)
//         process.exit(1)
//     })


module.exports = {
    ViewListing,
};
