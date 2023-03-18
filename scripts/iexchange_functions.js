const { ethers } = require("hardhat")
const { iexchange_token } = require('../config')
const fs = require('fs');
const {get_standard} = require('../services/token_standard')

const InsMarketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/AIEProxy.sol/AIE_Proxy.json', 'utf-8'))

async function ListInsNFT(tokenId,pricePerDay,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const unitPrice = ethers.utils.parseEther(pricePerDay.toString())

    const mplace_contract = new ethers.Contract(iexchange_token, InsMarketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    console.log("Approving Marketplace as operator of NFT...")
    const approvalTx = await token_contract.approve(mplace_contract.address, tokenId)
    await approvalTx.wait(1)

    const mintedBy = await token_contract.ownerOf(tokenId)
    const listingFee = (await mplace_contract.getListingFee()).toString();

    console.log("Listing NFT...")
    const tx = await mplace_contract.listInsBasedNFT(token_contract.address, tokenId, unitPrice, {
        value: listingFee,
    })

    await tx.wait(1)
    console.log("NFT Listed with token ID: ", tokenId.toString())

    return(
        `NFT with ID ${tokenId} listed by owner ${mintedBy}.`)
}

async function ViewAInsListing(tokenId, signer, std) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const mplace_contract = new ethers.Contract(iexchange_token, InsMarketplace.abi, signer)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getAInsListing(token_address, tokenId)

    return("Listing data: ", tx)
}

async function view_installment(tokenId,signer,std,rentaldays) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(iexchange_token, InsMarketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const tx = await mplace_contract.getNftInstallment(token_contract.address, tokenId, rentaldays)

    console.log("Next installment : ",tx)
}

async function unlist_nft(tokenId,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(iexchange_token, InsMarketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const tx = await mplace_contract.unlistINSNFT(token_contract.address, tokenId)

    console.log("NFT Unlisted")
}

async function rentInsNFT(tokenId,signer,std, numDays) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(iexchange_token, InsMarketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const firstIns = (await mplace_contract.getNftInstallment(token_contract.address, tokenId, numDays)).toString();

    console.log("Renting NFT...")
    const tx = await mplace_contract.rentINSNFT(token_contract.address, tokenId, numDays,{
        value: firstIns,
    })

    await tx.wait(1)
    console.log("NFT rented and first ins paid")

}

async function payNextIns(tokenId,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(iexchange_token, InsMarketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const numDays = ((await mplace_contract.getAInsListing(token_address, tokenId)).installmentCount).toString();

    console.log("rental period : ",numDays)

    const nextIns = (await mplace_contract.getNftInstallment(token_contract.address, tokenId, numDays)).toString();

    console.log("due installment : ",nextIns)

    console.log("paying NFT installment...")
    const tx = await mplace_contract.payNFTIns(token_contract.address, tokenId,{
        value: nextIns,
    })

    await tx.wait(1)
    console.log("NFT rented and first ins paid")

}












module.exports = {
    ListInsNFT,
    ViewAInsListing,
    view_installment,
    unlist_nft,
    rentInsNFT,
    payNextIns
};
