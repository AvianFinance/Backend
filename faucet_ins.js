const { ethers } = require("hardhat")

const { ListInsNFT,ViewAInsListing,view_installment,unlist_nft,rentInsNFT,payNextIns} = require('./scripts/iexchange_functions')

const provider = new ethers.providers.JsonRpcProvider("https://api.avax-test.network/ext/bc/C/rpc")
const signer_m = new ethers.Wallet("7e0dd21cba3952c769b9a90376893a351d4ac356aeacd0e537f5022e08593528", provider); // Meelan Credentials
const signer_r = new ethers.Wallet("2f3b47319ba27e3e58ae7a62ecb3966b23b9df1b8a12d1b7520f643a6d7fdc33", provider); // Rosy credentials
const signer_i = new ethers.Wallet("986815db062b75efa84cd38ea93e08e9e13a42ee9493f756c1bc661d06201e68", provider); // Meelan Credentials

stand = "ERC4907" // token type : set correctly before initiating

async function iexchange_handler(cond, signer){ // For handling installment based rental related scenarios

    if (cond==1){ // list a new NFT name
        token_ID = 25
        price = 0.03
        response =  await ListInsNFT(token_ID,price,signer,stand)
        console.log(response)
    }
    else if (cond==2){ // view the price and the listing of a NFT
        token_ID = 25
        response = await ViewAInsListing(token_ID,provider,stand) 
        console.log(response)
    }
    else if (cond==3){ //  get the next installment
        token_ID = 25
        rentalDays = 5
        response = await view_installment(token_ID,signer,stand,rentalDays)
    }
    else if (cond==4){ // unlist a nft
        token_ID = 25
        response = await unlist_nft(token_ID,signer,stand) 
    }
    else if (cond==5){ // rent the considered nft buy paying the first installment
        token_ID = 25
        num_days = 5
        response = await rentInsNFT(token_ID,signer,stand,num_days)
    }
    else if (cond==6){ // pay the next installment
        token_ID = 25
        response = await payNextIns(token_ID,signer,stand)
    }
}

iexchange_handler(6,signer_r)
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })

