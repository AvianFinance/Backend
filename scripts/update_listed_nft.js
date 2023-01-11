const { ethers } = require("hardhat")
const { amplace_token } = require('../config')
const {get_standard} = require('../services/token_standard')
const fs = require('fs');

const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/AvianMarket.sol/AvianMarket.json', 'utf-8'))

async function UpdateListing(tokenId,price,signer,std) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const PRICE = ethers.utils.parseEther(price.toString())

    const mplace_contract = new ethers.Contract(amplace_token, Marketplace.abi, signer)

    console.log("Updating the NFT listing...")
    const tx = await mplace_contract.updateListing(token_address, tokenId, PRICE)

    await tx.wait(1)

    return("Listing Updated to: ", tokenId.toString(), PRICE)
}

module.exports = {
    UpdateListing,
};
