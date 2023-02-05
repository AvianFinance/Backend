const { ethers } = require("hardhat")
const { amplace_token } = require('../config')
const {get_standard} = require('../services/token_standard')
const fs = require('fs');
const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/AvianMarkett.sol/AvianMarkett.json', 'utf-8'))


async function ViewASellListing(tokenId, signer, std) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const mplace_contract = new ethers.Contract(amplace_token, Marketplace.abi, signer)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getListing(token_address, tokenId)

    return("Listing data: ", tx)
}


async function ViewSellListing(provider) { // For viewving 

    const mplace_contract = new ethers.Contract(amplace_token, Marketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getSellListings()

    return("Listing data: ", tx)
}

async function ViewRentListing(provider) {

    const mplace_contract = new ethers.Contract(amplace_token, Marketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getRentListings()

    return("Listing data: ", tx)
}

async function ViewSellListedAddrs(provider) {

    const mplace_contract = new ethers.Contract(amplace_token, Marketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getSListedAdddresses() // Gives all the token addresses listed for selling

    return("Listing data: ", tx)
}

async function ViewSellListedAddrTokens(std,provider) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const mplace_contract = new ethers.Contract(amplace_token, Marketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getSListedAdddressTokens(token_address) // when the token address is given gives the token ids listed for selling

    return("Listing data: ", tx)
}

async function ViewRentListedAddrs(provider) {

    const mplace_contract = new ethers.Contract(amplace_token, Marketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getRListedAdddresses() // Gives all the token addresses listed for renting

    return("Listing data: ", tx)
}

async function ViewRentListedAddrTokens(std,provider) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const mplace_contract = new ethers.Contract(amplace_token, Marketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getRListedAdddressTokens(token_address) // when the token address is given gives the token ids listed for renting

    return("Listing data: ", tx)
}


module.exports = {
    ViewASellListing,
    ViewRentListing,
    ViewSellListing,
    ViewSellListedAddrs,
    ViewRentListedAddrs,
    ViewSellListedAddrTokens,
    ViewRentListedAddrTokens,
};
