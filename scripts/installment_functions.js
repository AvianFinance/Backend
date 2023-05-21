const { ethers } = require("hardhat")
const { installment_proxy_addr } = require('../config')
const fs = require('fs');
const {get_standard} = require('../services/token_standard')

const InsMarketplace = JSON.parse(fs.readFileSync('./artifacts/contracts/AIEProxy.sol/AIE_Proxy.json', 'utf-8'))

async function ListInsNFT(tokenId,pricePerDay,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const unitPrice = ethers.utils.parseEther(pricePerDay.toString())

    const mplace_contract = new ethers.Contract(installment_proxy_addr, InsMarketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    let start1 = Date.now();
    console.log("Approving Marketplace as operator of NFT...")
    const approvalTx = await token_contract.approve(mplace_contract.address, tokenId)
    await approvalTx.wait(1)

    const mintedBy = await token_contract.ownerOf(tokenId)
    const listingFee = (await mplace_contract.getListingFee()).toString();

    console.log("Listing NFT...")
    const tx = await mplace_contract.listInsBasedNFT(token_contract.address, tokenId, unitPrice, {
        value: listingFee,
    })
    let timeTaken1 = Date.now() - start1;
    console.log("Time taken to list the NFT: ", timeTaken1, "ms")
    await tx.wait(1)
    console.log("NFT Listed with token ID: ", tokenId.toString())

    return(
        `NFT with ID ${tokenId} listed by owner ${mintedBy}.`)
}

async function unlist_nft(tokenId,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(installment_proxy_addr, InsMarketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const tx = await mplace_contract.unlistINSNFT(token_contract.address, tokenId)

    return("NFT Unlisted")
}

async function rentInsNFT(tokenId,signer,std, numDays) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(installment_proxy_addr, InsMarketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const firstIns = (await mplace_contract.getNftInstallment(token_contract.address, tokenId, numDays)).toString();

    console.log("Renting NFT...")
    let start1 = Date.now();
    const tx = await mplace_contract.rentINSNFT(token_contract.address, tokenId, numDays,{
        value: firstIns,
    })
    let timeTaken1 = Date.now() - start1;
    console.log("Time taken to rent installment the NFT: ", timeTaken1, "ms")
    

    await tx.wait(1)

    return("NFT rented and first ins paid")

}

async function view_installment(tokenId,signer,std,rentaldays) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(installment_proxy_addr, InsMarketplace.abi, signer)
    const token_contract = new ethers.Contract(token_address, nft_token.abi, signer)

    const tx = await mplace_contract.getNftInstallment(token_contract.address, tokenId, rentaldays)

    return("Next installment : ",tx)
}

async function payNextIns(tokenId,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const mplace_contract = new ethers.Contract(installment_proxy_addr, InsMarketplace.abi, signer)
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
    return("Due installment paid !");

}

async function ViewAInsListing(tokenId, signer, std) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const mplace_contract = new ethers.Contract(installment_proxy_addr, InsMarketplace.abi, signer)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getAInsListing(token_address, tokenId)

    return("Listing data: ", tx)
}

async function ViewInsListedAddrs(provider) {

    const mplace_contract = new ethers.Contract(installment_proxy_addr, InsMarketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getInsListedAdddresses() // Gives all the token addresses listed for renting

    return("Listing data: ", tx)
}

async function ViewInsListedAddrTokens(std,provider) {

    const standard = await get_standard(std)
    const token_address = standard.addr;

    const mplace_contract = new ethers.Contract(installment_proxy_addr, InsMarketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getInsListedAdddressTokens(token_address) // when the token address is given gives the token ids listed for renting

    return("Listing data: ", tx)
}

async function ViewImplContract(provider) {

    const mplace_contract = new ethers.Contract(installment_proxy_addr, InsMarketplace.abi, provider)

    console.log("Retrieving NFT listing data...")
    const tx = await mplace_contract.getImplAddrs() // Get the implementation contract address

    return("Implementation Address: ", tx)
}

async function UpdateImplContract(new_impl_addr,signer) {

    const mplace_contract = new ethers.Contract(installment_proxy_addr, InsMarketplace.abi, signer)

    const tx = await mplace_contract.updateImplContract(new_impl_addr)

    return("Implementation Updated")
}



module.exports = {
    ListInsNFT,
    ViewAInsListing,
    ViewInsListedAddrs,
    ViewInsListedAddrTokens,
    view_installment,
    unlist_nft,
    rentInsNFT,
    payNextIns,
    ViewImplContract,
    UpdateImplContract
};
