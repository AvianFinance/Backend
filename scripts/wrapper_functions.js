const { ethers } = require("hardhat")
const fs = require('fs');
//Commented due to circular dependency issue: No usage in this file
// const { wrapper_handler } = require("../faucet_wrapper");
const { wrapper_list } = require("../config");

const WrapperContract = JSON.parse(fs.readFileSync('./artifacts/contracts/RentWrapper.sol/RentWrapper.json', 'utf-8'))
const RentContract = JSON.parse(fs.readFileSync('./artifacts/contracts/AVFXRent.sol/AVFXRent.json', 'utf-8'))

async function DepositNFT(wrapper_address,tokenId,signer) {

    const wrapper_contract = new ethers.Contract(wrapper_address, WrapperContract.abi, signer)

    const base_contract_address = await wrapper_contract.generalToken()
    const token_contract = new ethers.Contract(base_contract_address, RentContract.abi, signer)

    console.log("Approving Wrapper as operator of NFT...")
    const approvalTx = await token_contract.approve(wrapper_address, tokenId)
    await approvalTx.wait(1)

    console.log("Wrapping and depositing NFT...")
    const tx = await wrapper_contract.deposit(tokenId)

    await tx.wait(1)
    console.log("Base NFT Owner is ", await token_contract.ownerOf(tokenId))
    console.log("NFT deposied with token ID: ", tokenId.toString())
    return("For future tradings please use ", wrapper_address, "with token id :", tokenId.toString())
}

async function WithdrawNFT(wrapper_address,tokenId,signer) {

    const wrapper_contract = new ethers.Contract(wrapper_address, WrapperContract.abi, signer)

    const base_contract_address = await wrapper_contract.generalToken()
    const token_contract = new ethers.Contract(base_contract_address, RentContract.abi, signer)

    console.log("Withdrawing the original NFT...")
    const tx = await wrapper_contract.withdraw(tokenId)

    await tx.wait(1)
    console.log("Base NFT Owner is ", await token_contract.ownerOf(tokenId))
    return("For future tradings please use ", base_contract_address, "with token id :", tokenId.toString())
}

function readWrapperList(){
    let wrapper_list = []
    wrapper_list = fs.readFileSync("./wrapper_config.txt", "utf-8").split("\n").slice(0, -1);
    return wrapper_list
}

module.exports = {
    DepositNFT,
    WithdrawNFT,
    readWrapperList
};
