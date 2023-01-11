const { ethers } = require("hardhat")
const { amplace_token } = require('../config')
const fs = require('fs');
const {get_standard} = require('../services/token_standard')

const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/AvianMarket.sol/AvianMarket.json', 'utf-8'))

async function ListNFT(tokenId,amount,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const PRICE = ethers.utils.parseEther(amount.toString())

    const mplace_contract = new ethers.Contract(amplace_token, Marketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

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

async function ListRentNFT(tokenId,amount,signer,std, sDate, eDate) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const PRICE = ethers.utils.parseEther(amount.toString())

    const mplace_contract = new ethers.Contract(amplace_token, Marketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    console.log("Approving Marketplace as operator of NFT...")
    const approvalTx = await token_contract.approve(mplace_contract.address, tokenId)
    await approvalTx.wait(1)

    const mintedBy = await token_contract.ownerOf(tokenId)
    const listingFee = (await mplace_contract.getListingFee()).toString();

    console.log("Listing NFT...")
    const tx = await mplace_contract.listNFT(token_contract.address, tokenId, PRICE, sDate, eDate,{
        value: listingFee,
    })

    await tx.wait(1)
    console.log("NFT Listed with token ID: ", tokenId.toString())

    return(
        `NFT with ID ${tokenId} listed by owner ${mintedBy}.`)
}


// buyItem()
//     .then(() => process.exit(0))
//     .catch((error) => {
//         console.error(error)
//         process.exit(1)
//     })



module.exports = {
    ListNFT,
    ListRentNFT,
};
