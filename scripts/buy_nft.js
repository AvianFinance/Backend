const { ethers } = require("hardhat")
const { mplace_token } = require('../config')
const { rime_token } = require('../config')

const TOKEN_ID = 7 // SET THIS BEFORE RUNNING SCRIPT

const fs = require('fs');
const Marketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/Marketplace.sol/Marketplace.json', 'utf-8'))
const RimeToken = JSON.parse(fs.readFileSync('./artifacts/contracts/RimeToken.sol/RimeToken.json', 'utf-8'))



async function buyItem() {

    const provider = new ethers.providers.JsonRpcProvider("https://api.avax-test.network/ext/bc/C/rpc")
    const signer = new ethers.Wallet("2f3b47319ba27e3e58ae7a62ecb3966b23b9df1b8a12d1b7520f643a6d7fdc33", provider); // Rosy credentials

    const mplace_contract = new ethers.Contract(mplace_token, Marketplace.abi, signer)
    const token_contract = new ethers.Contract(rime_token, RimeToken.abi, signer)

    const listing = await mplace_contract.getListing(token_contract.address, TOKEN_ID)

    const price = listing.price.toString()
    const tx = await mplace_contract.buyItem(token_contract.address, TOKEN_ID, {
            value: price,
        })
    await tx.wait(1)
    console.log("NFT Bought!")

    const newOwner = await token_contract.ownerOf(TOKEN_ID)
    console.log(
        `New owner of Token ID ${TOKEN_ID} is ${newOwner}.`)
}

buyItem()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })

// module.exports = {
//     buyItem,
// };
