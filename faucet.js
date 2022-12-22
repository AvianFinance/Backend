const { rime_token } = require('./config')

const { mintNFT } = require('./scripts/mint_nft')
const { ViewListing } = require('./scripts/view_listing')
const { ListNFT } = require('./scripts/list_nft')
const { UpdateListing } = require('./scripts/update_listed_nft')


const provider = new ethers.providers.JsonRpcProvider("https://api.avax-test.network/ext/bc/C/rpc")
const signer = new ethers.Wallet("7e0dd21cba3952c769b9a90376893a351d4ac356aeacd0e537f5022e08593528", provider);


async function handler(cond, signer){

    if (cond==1){ // Mint a new NFT name, description and the file location is required
        response =  await mintNFT("Adorable Cat","Trying out the infura function","Rime06.jpg",signer)
        console.log(response)
    }
    else if (cond==2){ // list a nft to be sold in the market place, token_ID and the price is required
        token_ID = 6
        price = 0.04
        response = await ListNFT(token_ID,price,signer)
        console.log(response)
    }
    else if (cond==3){ // view the price and the listing of a NFT, token_ID is required as the input
        token_ID = 4
        response = await ViewListing(token_ID,provider) //Data can be read only with the provider
        console.log(response)
    }
    else if (cond==4){ // update the price of a NFT, token_ID is required as the input
        token_ID = 5
        price = 0
        response = await UpdateListing(token_ID,price,signer) //Data can be read only with the provider
        console.log(response)
    }

}

handler(3,signer)
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })

