const { ethers } = require("hardhat")
const { mplace_token } = require('../config')
const {get_standard} = require('../services/token_standard')
const fs = require('fs');

const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/Marketplace.sol/Marketplace.json', 'utf-8'))

async function ViewListing(tokenId, signer, std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(mplace_token, Marketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

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
