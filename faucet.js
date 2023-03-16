const { ethers } = require("hardhat")
const { mintNFT } = require('./scripts/mint_nft')
const { pullProceeds } = require('./scripts/get_proceeds')

const { ListRentNFT, ViewRentListing, ViewRentListedAddrs, ViewRentListedAddrTokens, rentNFT} = require('./scripts/rexchange_functions')
const { ListNFT, UpdateListing, ViewASellListing, ViewSellListing, ViewSellListedAddrs, ViewSellListedAddrTokens, buyNFT} = require('./scripts/sexchange_functions')
const { ListInsNFT,ViewAInsListing,view_installment,unlist_nft,rentInsNFT,payNextIns} = require('./scripts/iexchange_functions')

const provider = new ethers.providers.JsonRpcProvider("https://api.avax-test.network/ext/bc/C/rpc")
const signer_m = new ethers.Wallet("7e0dd21cba3952c769b9a90376893a351d4ac356aeacd0e537f5022e08593528", provider); // Meelan Credentials
const signer_r = new ethers.Wallet("2f3b47319ba27e3e58ae7a62ecb3966b23b9df1b8a12d1b7520f643a6d7fdc33", provider); // Rosy credentials
const signer_i = new ethers.Wallet("986815db062b75efa84cd38ea93e08e9e13a42ee9493f756c1bc661d06201e68", provider); // Meelan Credentials

stand = "ERC4907" // token type : set correctly before initiating

async function sexchange_handler(cond, signer){ // For handling buy sell related scenarios

    if (cond==1){ // Mint a new NFT name
        response =  await mintNFT("cute panda 2222","Beautiful panda","panda.jpg",signer,stand)
        console.log(response)
    }
    else if (cond==2){ // list a nft to be sold in the market place
        token_ID = 6
        price = 0.07
        response = await ListNFT(token_ID,price,signer,stand)
        console.log(response)
    }
    else if (cond==3){ // view the price and the listing of a NFT
        token_ID = 34
        response = await ViewASellListing(token_ID,provider,stand)
        console.log(response)
    }
    else if (cond==4){ // update the price of a NFT
        token_ID = 34
        price = 0.05
        response = await UpdateListing(token_ID,price,signer,stand) 
        console.log(response)
    }
    else if (cond==5){ // buy a listed nft
        token_ID = 21
        response = await buyNFT(token_ID,signer,stand) 
        console.log(response)
    }
    else if (cond==6){ // pulls available proceeds
        response = await pullProceeds(signer)
        console.log(response)
    }
    else if (cond==7){ // view the set of sell listings
        response = await ViewSellListing(provider)
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

async function rexchange_handler(cond, signer){ // For handling outright rental related scenarios

    if (cond==1){ // list a new NFT for rentals
        token_ID = 3
        price = 0.08
        response =  await ListRentNFT(token_ID,price,signer,stand)
        console.log(response)
    }
    else if (cond==2){ // view the price and the listing of a NFT
        response = await ViewRentListing(provider)
        console.log(response)
    }
    else if (cond==3){ // rent the nft
        token_ID = 22
        n_days = 2
        price = 0.05
        response = await rentNFT(token_ID,signer,stand,n_days,price)
        console.log(response)
    }
    else if (cond==4){ // View the collection addresses listed for renting
        response = await ViewRentListedAddrs(provider) 
        console.log(response)
    }
    else if (cond==5){ // view the token ids listed under a given collection for renting
        response = await ViewRentListedAddrTokens(stand,provider) 
        console.log(response)
    }
}

async function iexchange_handler(cond, signer){ // For handling installment based rental related scenarios

    if (cond==1){ // list a new NFT name
        token_ID = 12
        price = 0.04
        response =  await ListInsNFT(token_ID,price,signer,stand)
        console.log(response)
    }
    else if (cond==2){ // view the price and the listing of a NFT
        token_ID = 12
        response = await ViewAInsListing(token_ID,provider,stand) 
        console.log(response)
    }
    else if (cond==3){ //  get the next installment
        token_ID = 12
        rentalDays = 5
        response = await view_installment(token_ID,provider,stand,rentalDays)
    }
    else if (cond==4){ // unlist a nft
        token_ID = 12
        response = await unlist_nft(token_ID,signer,stand) 
    }
    else if (cond==5){ // rent the considered nft buy paying the first installment
        token_ID = 12
        num_days = 5
        response = await rentInsNFT(token_ID,signer,stand,num_days)
    }
    else if (cond==6){ // pay the next installment
        token_ID = 12
        response = await payNextIns(token_ID,signer,stand)
    }
}

// sexchange_handler(1,signer_m)
//     .then(() => process.exit(0))
//     .catch((error) => {
//         console.error(error)
//         process.exit(1)
//     })

// rexchange_handler(2,signer_i)
//     .then(() => process.exit(0))
//     .catch((error) => {
//         console.error(error)
//         process.exit(1)
//     })

// iexchange_handler(5,signer_r)
//     .then(() => process.exit(0))
//     .catch((error) => {
//         console.error(error)
//         process.exit(1)
//     })

