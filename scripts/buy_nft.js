const { ethers } = require("hardhat")
const { mplace_token } = require('../config')
const fs = require('fs');
const {get_standard} = require('../services/token_standard')
const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/Marketplace.sol/Marketplace.json', 'utf-8'))

async function buyNFT(tokenID,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(mplace_token, Marketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const listing = await mplace_contract.getListing(token_contract.address, tokenID)

    const price = listing.price.toString()
    const tx = await mplace_contract.buyItem(token_contract.address, tokenID, {
            value: price,
        })
    await tx.wait(1)
    console.log("NFT Bought!")

    const newOwner = await token_contract.ownerOf(tokenID)
    return(`New owner of Token ID ${tokenID} is ${newOwner}.`)
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
