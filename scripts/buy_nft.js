const { ethers } = require("hardhat")
const { amplace_token } = require('../config')
const fs = require('fs');
const {get_standard} = require('../services/token_standard')
// const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/Marketplace.sol/Marketplace.json', 'utf-8'))
const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/AvianMarkett.sol/AvianMarkett.json', 'utf-8'))


async function buyNFT(tokenID,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(amplace_token, Marketplace.abi, signer)
    // const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const listing = await mplace_contract.getListing(token_address, tokenID)

    const price = listing.price.toString()
    const tx = await mplace_contract.buyItem(token_address, tokenID, {
            value: price,
        })
    await tx.wait(1)
    return("NFT Bought!")
}

// buyItem()
//     .then(() => process.exit(0))
//     .catch((error) => {
//         console.error(error)
//         process.exit(1)
//     })

module.exports = {
    buyNFT,
};
