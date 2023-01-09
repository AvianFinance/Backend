const { ethers } = require("hardhat")
const { mplace_token } = require('../config')
const { rime_token } = require('../config')
const {get_standard} = require('../services/token_standard')
const fs = require('fs');

const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/Marketplace.sol/Marketplace.json', 'utf-8'))

async function UpdateListing(tokenId,price,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const PRICE = ethers.utils.parseEther(price.toString())

    const mplace_contract = new ethers.Contract(mplace_token, Marketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    console.log("Updating the NFT listing...")
    const tx = await mplace_contract.updateListing(token_contract.address, tokenId, PRICE)

    await tx.wait(1)

    return("Listing Updated to: ", tokenId.toString(), PRICE)
}

module.exports = {
    UpdateListing,
};
