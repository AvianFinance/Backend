const { ethers } = require("hardhat")
const { mplace_token } = require('../config')
const { rime_token } = require('../config')
const { rime_rent } = require('../config')

const fs = require('fs');
const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/Marketplace.sol/Marketplace.json', 'utf-8'))
const RimeToken = JSON.parse(fs.readFileSync('./artifacts/contracts/RimeToken.sol/RimeToken.json', 'utf-8'))
const RimeRent = JSON.parse(fs.readFileSync('./artifacts/contracts/RimeRent.sol/RimeRent.json', 'utf-8'))



async function ListNFT(tokenId,amount,signer) {

    const PRICE = ethers.utils.parseEther(amount.toString())

    const mplace_contract = new ethers.Contract(mplace_token, Marketplace.abi, signer)
    const token_contract = new ethers.Contract(rime_token, RimeToken.abi, signer)

    console.log("Approving Marketplace as operator of NFT...")
    const approvalTx = await token_contract.approve(mplace_contract.address, tokenId)
    await approvalTx.wait(1)

    console.log("Listing NFT...")
    const tx = await mplace_contract.listItem(token_contract.address, tokenId, PRICE)

    await tx.wait(1)
    console.log("NFT Listed with token ID: ", tokenId.toString())

    const mintedBy = await token_contract.ownerOf(tokenId)

    return(
        `NFT with ID ${tokenId} listed by owner ${mintedBy}.`)
}

// List()
//     .then(() => process.exit(0))
//     .catch((error) => {
//         console.error(error)
//         process.exit(1)
//     })

module.exports = {
    ListNFT,
};
