const { uploadImage } = require('../services/PinataConnection')
const {get_standard} = require('../services/token_standard')
const fs = require('fs');

async function mintNFT(name,desc,img_name,signer,std) {

    const standard = await get_standard(std)

    const token_address = standard.addr;
    const nft_token = standard.token;

    const image = fs.readFileSync(`./${img_name}`);

    console.log("Image Uploading to Pinata...")
    const tokenCounter = await getTokenCounter(nft_token,token_address)

    const ipfsHash = await uploadImage(image, img_name, tokenCounter, name, desc)
    console.log("Minting NFT...")
    await mintToken(`https://gateway.pinata.cloud/ipfs/${ipfsHash}`,signer,nft_token,token_address)
    return(`Contract Address: ${token_address} Token Counter: ${tokenCounter}`)
}

async function getTokenCounter(token,address) {
    const provider = new ethers.providers.JsonRpcProvider("https://api.avax-test.network/ext/bc/C/rpc")
    const contract = new ethers.Contract(address, token.abi, provider)
    const tokenCounter = await contract.tokenCounter()
    return tokenCounter
}

async function mintToken(ipfsUrl,signer,token,address) {
    const contract = new ethers.Contract(address, token.abi, signer)
    const transaction = await contract.mint(ipfsUrl)
    await transaction.wait()
    const tokenCounter = await contract.tokenCounter()
    return `${tokenCounter - 1}`
}


module.exports = {
    mintNFT,
};
