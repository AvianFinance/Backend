const { ethers } = require("hardhat")
const { amplace_token } = require('../config')
const fs = require('fs');
const {get_standard} = require('../services/token_standard')
const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/AvianMarket.sol/AvianMarket.json', 'utf-8'))

async function rentNFT(tokenID,signer,std,days,amount) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const mplace_contract = new ethers.Contract(amplace_token, Marketplace.abi, signer)

    let value = days * amount;
    const price = ethers.utils.parseEther(value.toString())

    const txn = await mplace_contract.rentNFT(token_address, tokenID, days, {value: price});

    await txn.wait(1)
    return("NFT Rented!")
}

module.exports = {
    rentNFT,
};
