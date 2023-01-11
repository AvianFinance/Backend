const { rime_token } = require('./config')
const { ethers } = require("hardhat")
const { mintNFT } = require('./scripts/mint_nft')
const { ViewASellListing } = require('./scripts/view_listing')
const { ViewRentListing } = require('./scripts/view_listing')
const { ViewSellListing } = require('./scripts/view_listing')
const { ListNFT } = require('./scripts/list_nft')
const { ListRentNFT } = require('./scripts/list_nft')
const { UpdateListing } = require('./scripts/update_listed_nft')
const { buyNFT } = require('./scripts/buy_nft')
const { pullProceeds } = require('./scripts/get_proceeds')
const { rentNFT } = require('./scripts/rent_nft')

const provider = new ethers.providers.JsonRpcProvider("https://api.avax-test.network/ext/bc/C/rpc")
const signer_m = new ethers.Wallet("7e0dd21cba3952c769b9a90376893a351d4ac356aeacd0e537f5022e08593528", provider); // Meelan Credentials
const signer_r = new ethers.Wallet("2f3b47319ba27e3e58ae7a62ecb3966b23b9df1b8a12d1b7520f643a6d7fdc33", provider); // Rosy credentials


stand = "ERC4907"

async function basic_handler(cond, signer){

    if (cond==1){ // Mint a new NFT name, description and the file location is required
        response =  await mintNFT("panda hug 02","Checking the new mplace","Rimer12.jpg",signer,stand)
        console.log(response)
    }
    else if (cond==2){ // list a nft to be sold in the market place, token_ID and the price is required
        token_ID = 27
        price = 0.05
        response = await ListNFT(token_ID,price,signer,stand)
        console.log(response)
    }
    else if (cond==3){ // view the price and the listing of a NFT, token_ID is required as the input
        token_ID = 27
        response = await ViewASellListing(token_ID,provider,stand) //Data can be read only with the provider
        console.log(response)
    }
    else if (cond==4){ // update the price of a NFT, token_ID is required as the input
        token_ID = 27
        price = 0.04
        response = await UpdateListing(token_ID,price,signer,stand) //Data can be read only with the provider
        console.log(response)
    }
    else if (cond==5){ // buys the listed nft
        token_ID = 27
        response = await buyNFT(token_ID,signer,stand) //Data can be read only with the provider
        console.log(response)
    }
    else if (cond==6){ // pulls available proceeds
        response = await pullProceeds(signer) //Data can be read only with the provider
        console.log(response)
    }
    else if (cond==7){ // pulls available proceeds
        response = await ViewSellListing(provider) //Data can be read only with the provider
        console.log(response)
    }

}

async function rent_handler(cond, signer){

    if (cond==1){ // list a new NFT name, description and the file location is required
        token_ID = 12
        price = 0.03
        n_days = 5
        sDate = Math.floor(Date.now()/1000) + (60*60);
        eDate = sDate + (n_days*24*60*60);
        response =  await ListRentNFT(token_ID,price,signer,stand,sDate,eDate)
        console.log(response)
    }
    else if (cond==2){ // view the price and the listing of a NFT, token_ID is required as the input
        response = await ViewRentListing(provider) //Data can be read only with the provider
        console.log(response)
    }
    else if (cond==3){ // rent the nft
        token_ID = 12
        n_days = 2
        expires = Math.floor(Date.now()/1000) + (n_days*24*60*60)
        price = 0.03
        response = await rentNFT(token_ID,signer,stand,expires,price) //Data can be read only with the provider
        console.log(response)
    }
}

// basic_handler(1,signer_m)
//     .then(() => process.exit(0))
//     .catch((error) => {
//         console.error(error)
//         process.exit(1)
//     })

rent_handler(3,signer_r)
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })

