const { ethers } = require("hardhat")
const { rent_proxy_addr } = require('../config')
const fs = require('fs');
const {get_standard} = require('../services/token_standard')

const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/AREProxy.sol/ARE_Proxy.json', 'utf-8'))

async function ListRentNFT(tokenId,amount,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const PRICE = ethers.utils.parseEther(amount.toString())

    const mplace_contract = new ethers.Contract(rent_proxy_addr, Marketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)
    
    let start1 = Date.now();
    console.log("Approving Marketplace as operator of NFT...")
    const approvalTx = await token_contract.approve(mplace_contract.address, tokenId)
    await approvalTx.wait(1)

    const mintedBy = await token_contract.ownerOf(tokenId)
    const listingFee = (await mplace_contract.getListingFee()).toString();

    console.log("Listing NFT...")
    const tx = await mplace_contract.listNFT(token_contract.address, tokenId, PRICE,{
        value: listingFee,
    })
    let timeTaken1 = Date.now() - start1;
    console.log("Time taken to list the NFT: ", timeTaken1, "ms")
    await tx.wait(1)
    console.log("NFT Listed with token ID: ", tokenId.toString())

    return(
        `NFT with ID ${tokenId} listed by owner ${mintedBy}.`)
}

async function cancelRentNFT(tokenId,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(rent_proxy_addr, Marketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    console.log("cancelling rent NFT listing...")
    const tx = await mplace_contract.unlistNFT(token_contract.address, tokenId)

    await tx.wait(1)
    return("NFT unlisted with token ID: ", tokenId.toString())
}

async function updateRentNFT(tokenId,amount,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const PRICE = ethers.utils.parseEther(amount.toString())

    const mplace_contract = new ethers.Contract(rent_proxy_addr, Marketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    console.log("updating rent NFT listing...")
    const tx = await mplace_contract.updateNFT(token_contract.address, tokenId, PRICE)

    await tx.wait(1)
    return("NFT with token ID, updated: ", tokenId.toString())
}

async function ViewARentListing(tokenId, signer, std) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const mplace_contract = new ethers.Contract(rent_proxy_addr, Marketplace.abi, signer)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getARListing(token_address, tokenId)

    return("Listing data: ", tx)
}

async function ViewRentListedAddrs(provider) {

    const mplace_contract = new ethers.Contract(rent_proxy_addr, Marketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getRListedAdddresses() // Gives all the token addresses listed for renting

    return("Listing data: ", tx)
}

async function ViewRentListedAddrTokens(std,provider) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const mplace_contract = new ethers.Contract(rent_proxy_addr, Marketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getRListedAdddressTokens(token_address) // when the token address is given gives the token ids listed for renting

    return("Listing data: ", tx)
}

async function rentNFT(tokenID,signer,std,days) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const mplace_contract = new ethers.Contract(rent_proxy_addr, Marketplace.abi, signer)

    const listing = await mplace_contract.getARListing(token_address, tokenID)

    const amount = (listing.pricePerDay)*Math.pow(10, -18);

    let price = days * amount;

    const payment = ethers.utils.parseEther(price.toString())

    let start1 = Date.now();
    const txn = await mplace_contract.rentNFT(token_address, tokenID, days, {value: payment});
    let timeTaken1 = Date.now() - start1;
    console.log("Time taken to rent the NFT: ", timeTaken1, "ms")
    await txn.wait(1)
    return("NFT Rented!")
}

module.exports = {
    ListRentNFT,
    cancelRentNFT,
    updateRentNFT,
    ViewARentListing,
    ViewRentListedAddrs,
    ViewRentListedAddrTokens,
    rentNFT
};