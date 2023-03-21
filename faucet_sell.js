const { ethers } = require("hardhat")
const { mintNFT } = require('./scripts/mint_nft')
const { pullProceeds } = require('./scripts/get_proceeds')
const { ListNFT, cancelListing,UpdateListing, ViewASellListing, ViewSellListedAddrs, ViewSellListedAddrTokens, buyNFT} = require('./scripts/sexchange_functions')

const provider = new ethers.providers.JsonRpcProvider("https://api.avax-test.network/ext/bc/C/rpc")
const signer_m = new ethers.Wallet("7e0dd21cba3952c769b9a90376893a351d4ac356aeacd0e537f5022e08593528", provider); // Meelan Credentials
const signer_r = new ethers.Wallet("2f3b47319ba27e3e58ae7a62ecb3966b23b9df1b8a12d1b7520f643a6d7fdc33", provider); // Rosy credentials
const signer_i = new ethers.Wallet("986815db062b75efa84cd38ea93e08e9e13a42ee9493f756c1bc661d06201e68", provider); // Meelan Credentials

stand = "ERC721" // token type : set correctly before initiating

async function sexchange_handler(cond, signer){ // For handling buy sell related scenarios

    if (cond==1){ // Mint a new NFT name
        response =  await mintNFT("cute panda 2222","Beautiful panda","panda.jpg",signer,stand)
        console.log(response)
    }
    else if (cond==2){ // list a nft to be sold in the market place
        token_ID = 32
        price = 0.08
        response = await ListNFT(token_ID,price,signer,stand)
        console.log(response)
    }
    else if (cond==3){ // unlist an already listed sell order
        token_ID = 4
        response = await cancelListing(token_ID,signer,stand)
        console.log(response)
    }
    else if (cond==4){ // view the price and the listing of a NFT
        token_ID = 4
        response = await ViewASellListing(token_ID,provider,stand)
        console.log(response)
    }
    else if (cond==5){ // update the price of a NFT
        token_ID = 4
        price = 0.06
        response = await UpdateListing(token_ID,price,signer,stand) 
        console.log(response)
    }
    else if (cond==6){ // buy a listed nft
        token_ID = 4
        response = await buyNFT(token_ID,signer,stand) 
        console.log(response)
    }
    else if (cond==7){ // pulls available proceeds
        response = await pullProceeds(signer)
        console.log(response)
    }
    else if (cond==8){ // View the set of collection addresses listed for selling
        response = await ViewSellListedAddrs(provider) 
        console.log(response)
    }
    else if (cond==9){ // View the set of token ids listed under a given collection for selling
        response = await ViewSellListedAddrTokens(stand,provider) 
        console.log(response)
    }
}


sexchange_handler(6,signer_m)
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })

