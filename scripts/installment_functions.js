const { ethers } = require("hardhat")
const { insmplace_token } = require('../config')
const fs = require('fs');
const {get_standard} = require('../services/token_standard')

const InsMarketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/AvianInstallment.sol/AvianInstallment.json', 'utf-8'))


async function payNextIns(tokenId,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(insmplace_token, InsMarketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const numDays = ((await mplace_contract.getAINSListing(token_address, tokenId)).numDays).toString();

    console.log("rental period : ",numDays)

    const nextIns = (await mplace_contract.getNFTInstallment(token_contract.address, tokenId, numDays)).toString();

    console.log("due installment : ",nextIns)

    console.log("paying NFT installment...")
    const tx = await mplace_contract.payNFTIns(token_contract.address, tokenId,{
        value: nextIns,
    })

    await tx.wait(1)
    console.log("NFT rented and first ins paid")

}


async function rentInsNFT(tokenId,signer,std, numDays) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(insmplace_token, InsMarketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const firstIns = (await mplace_contract.getNFTInstallment(token_contract.address, tokenId, numDays)).toString();

    console.log("Renting NFT...")
    const tx = await mplace_contract.rentINSNFT(token_contract.address, tokenId, numDays,{
        value: firstIns,
    })

    await tx.wait(1)
    console.log("NFT rented and first ins paid")

}

async function unlist_nft(tokenId,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(insmplace_token, InsMarketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const tx = await mplace_contract.unlistINSNFT(token_contract.address, tokenId)

    console.log("NFT Unlisted")
}



async function view_installment(tokenId,signer,std,rentaldays) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(insmplace_token, InsMarketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const tx = await mplace_contract.getNFTInstallment(token_contract.address, tokenId, rentaldays)

    console.log("Next installment : ",tx)
}



module.exports = {
    view_installment,
    unlist_nft,
    rentInsNFT,
    payNextIns
};
