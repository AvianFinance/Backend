const { rime_token } = require('../config')
const { uploadImage } = require('../services/PinataConnection')
const fs = require('fs');
const RimeToken = JSON.parse(fs.readFileSync('./artifacts/contracts/RimeToken.sol/RimeToken.json', 'utf-8'))

async function mintNFT(name,desc,img_name,signer) {

    const image = fs.readFileSync(`./${img_name}`);

    console.log("Image Uploading to Pinata...")
    const tokenCounter = await getTokenCounter()
    const ipfsHash = await uploadImage(image, img_name, tokenCounter, name, desc)
    console.log("Minting NFT...")
    await mintToken(`https://gateway.pinata.cloud/ipfs/${ipfsHash}`,signer)
    return(`Contract Address: ${rime_token} Token Counter: ${tokenCounter}`)
}

async function getTokenCounter() {
    const provider = new ethers.providers.JsonRpcProvider("https://api.avax-test.network/ext/bc/C/rpc")
    const contract = new ethers.Contract(rime_token, RimeToken.abi, provider)
    const tokenCounter = await contract.tokenCounter()
    return tokenCounter
}

async function mintToken(ipfsUrl,signer) {
    const contract = new ethers.Contract(rime_token, RimeToken.abi, signer)
    const transaction = await contract.mint(ipfsUrl)
    await transaction.wait()
    const tokenCounter = await contract.tokenCounter()
    return `${tokenCounter - 1}`
}

// main()
//     .then(() => process.exit(0))
//     .catch((error) => {
//         console.error(error);
//         process.exit(1);
//     });

module.exports = {
    mintNFT,
};
