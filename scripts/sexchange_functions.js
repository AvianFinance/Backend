const { ethers } = require("hardhat")
const { sexchange_token } = require('../config')
const fs = require('fs');
const {get_standard} = require('../services/token_standard')

const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/AvianSellExchange.sol/AvianSellExchange.json', 'utf-8'))

async function ListNFT(tokenId,amount,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const PRICE = ethers.utils.parseEther(amount.toString())

    const mplace_contract = new ethers.Contract(sexchange_token, Marketplace.abi, signer)
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

async function UpdateListing(tokenId,price,signer,std) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const PRICE = ethers.utils.parseEther(price.toString())

    const mplace_contract = new ethers.Contract(sexchange_token, Marketplace.abi, signer)

    console.log("Updating the NFT listing...")
    const tx = await mplace_contract.updateListing(token_address, tokenId, PRICE)

    await tx.wait(1)

    return("Listing Updated to: ", tokenId.toString(), PRICE)
}

async function ViewASellListing(tokenId, signer, std) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const mplace_contract = new ethers.Contract(sexchange_token, Marketplace.abi, signer)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getASListing(token_address, tokenId)

    return("Listing data: ", tx)
}

async function ViewSellListing(provider) { // For viewving 

    const mplace_contract = new ethers.Contract(sexchange_token, Marketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getSellListings()

    return("Listing data: ", tx)
}

async function ViewSellListedAddrs(provider) {

    const mplace_contract = new ethers.Contract(sexchange_token, Marketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getSListedAdddresses() // Gives all the token addresses listed for selling

    return("Listing data: ", tx)
}

async function ViewSellListedAddrTokens(std,provider) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const mplace_contract = new ethers.Contract(sexchange_token, Marketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getSListedAdddressTokens(token_address) // when the token address is given gives the token ids listed for selling

    return("Listing data: ", tx)
}

async function buyNFT(tokenID,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(sexchange_token, Marketplace.abi, signer)
    // const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const listing = await mplace_contract.getASListing(token_address, tokenID)

    const price = listing.price.toString()
    const tx = await mplace_contract.buyItem(token_address, tokenID, {
            value: price,
        })
    await tx.wait(1)
    return("NFT Bought!")
}

module.exports = {
    ListNFT,
    UpdateListing,
    ViewASellListing,
    ViewSellListing,
    ViewSellListedAddrs,
    ViewSellListedAddrTokens,
    buyNFT
};