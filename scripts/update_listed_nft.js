const { ethers } = require("hardhat")
const { mplace_token } = require('../config')
const { rime_token } = require('../config')

const fs = require('fs');
const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/Marketplace.sol/Marketplace.json', 'utf-8'))
const RimeToken = JSON.parse(fs.readFileSync('./artifacts/contracts/RimeToken.sol/RimeToken.json', 'utf-8'))



async function UpdateListing(tokenId,price,signer) {

    const PRICE = ethers.utils.parseEther(price.toString())

    const mplace_contract = new ethers.Contract(mplace_token, Marketplace.abi, signer)
    const token_contract = new ethers.Contract(rime_token, RimeToken.abi, signer)

    console.log("Updating the NFT listing...")
    const tx = await mplace_contract.updateListing(token_contract.address, tokenId, PRICE)

    await tx.wait(1)

    return("Listing Updated to: ", tokenId.toString(), PRICE)
}

// UpdateListing()
//     .then(() => process.exit(0))
//     .catch((error) => {
//         console.error(error)
//         process.exit(1)
//     })

module.exports = {
    UpdateListing,
};
