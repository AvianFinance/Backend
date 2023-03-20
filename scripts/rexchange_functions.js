const { ethers } = require("hardhat")
const { rexchange_token } = require('../config')
const fs = require('fs');
const {get_standard} = require('../services/token_standard')

const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/AREProxy.sol/ARE_Proxy.json', 'utf-8'))

async function ListRentNFT(tokenId,amount,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const PRICE = ethers.utils.parseEther(amount.toString())

    const mplace_contract = new ethers.Contract(rexchange_token, Marketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    console.log("Approving Marketplace as operator of NFT...")
    const approvalTx = await token_contract.approve(mplace_contract.address, tokenId)
    await approvalTx.wait(1)

    const mintedBy = await token_contract.ownerOf(tokenId)
    const listingFee = (await mplace_contract.getListingFee()).toString();

    console.log("Listing NFT...")
    const tx = await mplace_contract.listNFT(token_contract.address, tokenId, PRICE,{
        value: listingFee,
    })

    await tx.wait(1)
    console.log("NFT Listed with token ID: ", tokenId.toString())

    return(
        `NFT with ID ${tokenId} listed by owner ${mintedBy}.`)
}

async function ViewRentListedAddrs(provider) {

    const mplace_contract = new ethers.Contract(rexchange_token, Marketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getRListedAdddresses() // Gives all the token addresses listed for renting

    return("Listing data: ", tx)
}

async function ViewRentListedAddrTokens(std,provider) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const mplace_contract = new ethers.Contract(rexchange_token, Marketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getRListedAdddressTokens(token_address) // when the token address is given gives the token ids listed for renting

    return("Listing data: ", tx)
}

async function rentNFT(tokenID,signer,std,days,amount) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const mplace_contract = new ethers.Contract(rexchange_token, Marketplace.abi, signer)

    let value = days * amount;
    const price = ethers.utils.parseEther(value.toString())

    const txn = await mplace_contract.rentNFT(token_address, tokenID, days, {value: price});

    await txn.wait(1)
    return("NFT Rented!")
}

module.exports = {
    ListRentNFT,
    ViewRentListedAddrs,
    ViewRentListedAddrTokens,
    rentNFT
};