const { ethers } = require("hardhat")
const { amplace_token } = require('../config')
const fs = require('fs');
const {get_standard} = require('../services/token_standard')
// const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/Marketplace.sol/Marketplace.json', 'utf-8'))

const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/AvianMarket.sol/AvianMarket.json', 'utf-8'))

async function rentNFT(tokenID,signer,std,expires,amount) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(amplace_token, Marketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const now_time = Math.floor(Date.now()/1000);

    let value = ((expires - now_time)/60/60/24 + 1) * amount;

    const price = ethers.utils.parseEther(value.toString())

    const txn = await mplace_contract.rentNFT(token_contract.address, tokenID, expires, {value: price});

    await txn.wait(1)
    console.log("NFT Rented!")

    const newUser = await token_contract.userOf(tokenID)
    return(`New owner of Token ID ${tokenID} is ${newUser}.`)
}

// buyItem()
//     .then(() => process.exit(0))
//     .catch((error) => {
//         console.error(error)
//         process.exit(1)
//     })

module.exports = {
    rentNFT,
};
