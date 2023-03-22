const { ethers } = require("hardhat")

const { ListRentNFT, cancelRentNFT, updateRentNFT, ViewARentListing,ViewRentListedAddrs, ViewRentListedAddrTokens, rentNFT} = require('./scripts/rexchange_functions')

const provider = new ethers.providers.JsonRpcProvider("https://api.avax-test.network/ext/bc/C/rpc")
const signer_m = new ethers.Wallet("7e0dd21cba3952c769b9a90376893a351d4ac356aeacd0e537f5022e08593528", provider); // Meelan Credentials
const signer_r = new ethers.Wallet("2f3b47319ba27e3e58ae7a62ecb3966b23b9df1b8a12d1b7520f643a6d7fdc33", provider); // Rosy credentials
const signer_i = new ethers.Wallet("986815db062b75efa84cd38ea93e08e9e13a42ee9493f756c1bc661d06201e68", provider); // Meelan Credentials

stand = "ERC4907" // token type : set correctly before initiating

async function rexchange_handler(cond, signer){ // For handling outright rental related scenarios

    // if (cond==1){ // list a new NFT for rentals
    //     token_ID = 11
    //     price = 0.03
    //     response =  await ListRentNFT(token_ID,price,signer,stand)
    //     console.log(response)
    // }
    // else if (cond==2){ // unlist the nft
    //     token_ID = 11
    //     response = await cancelRentNFT(token_ID,signer,stand)
    //     console.log(response)
    // }
    // else if (cond==3){ // update the nft
    //     token_ID = 11
    //     price = 0.04
    //     response = await updateRentNFT(token_ID,price,signer,stand)
    //     console.log(response)
    // }
    else if (cond==4){ // rent the nft
        token_ID = 11
        n_days = 3
        price = 0.04
        response = await rentNFT(token_ID,signer,stand,n_days,price)
        console.log(response)
    }
    else if (cond==5){ // View the collection addresses listed for renting
        response = await ViewRentListedAddrs(provider) 
        console.log(response)
    }
    else if (cond==6){ // view the token ids listed under a given collection for renting
        response = await ViewRentListedAddrTokens(stand,provider) 
        console.log(response)
    }
    else if (cond==7){ // view the token ids listed under a given collection for renting
        token_ID = 11
        response = await ViewARentListing(token_ID,provider,stand) 
        console.log(response)
    }
}

rexchange_handler(7,signer_m)
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })

