const { rime_token } = require('./config')

const { mintNFT } = require('./scripts/mint_nft')
const { ViewListing } = require('./scripts/view_listing')
const { ListNFT } = require('./scripts/list_nft')
const { UpdateListing } = require('./scripts/update_listed_nft')
const { buyNFT } = require('./scripts/buy_nft')
const { pullProceeds } = require('./scripts/get_proceeds')



const provider_m = new ethers.providers.JsonRpcProvider("https://api.avax-test.network/ext/bc/C/rpc")
const signer_m = new ethers.Wallet("7e0dd21cba3952c769b9a90376893a351d4ac356aeacd0e537f5022e08593528", provider_m); // Meelan Credentials

const provider_r = new ethers.providers.JsonRpcProvider("https://api.avax-test.network/ext/bc/C/rpc")
const signer_r = new ethers.Wallet("2f3b47319ba27e3e58ae7a62ecb3966b23b9df1b8a12d1b7520f643a6d7fdc33", provider_r); // Rosy credentials


stand = "ERC4907"

async function handler(cond, signer){

    if (cond==1){ // Mint a new NFT name, description and the file location is required
        response =  await mintNFT("Adorable Panda 1","Trying out the restructure","Rimer01.jpg",signer,stand)
        console.log(response)
    }
    else if (cond==2){ // list a nft to be sold in the market place, token_ID and the price is required
        token_ID = 2
        price = 0.03
        response = await ListNFT(token_ID,price,signer,stand)
        console.log(response)
    }
    else if (cond==3){ // view the price and the listing of a NFT, token_ID is required as the input
        token_ID = 2
        response = await ViewListing(token_ID,provider,stand) //Data can be read only with the provider
        console.log(response)
    }
    else if (cond==4){ // update the price of a NFT, token_ID is required as the input
        token_ID = 2
        price = 0.02
        response = await UpdateListing(token_ID,price,signer,stand) //Data can be read only with the provider
        console.log(response)
    }
    else if (cond==5){ // buys the listed nft
        token_ID = 2
        response = await buyNFT(token_ID,signer,stand) //Data can be read only with the provider
        console.log(response)
    }
    else if (cond==6){ // pulls available proceeds
        response = await pullProceeds(signer) //Data can be read only with the provider
        console.log(response)
    }

}

handler(6,signer_m)
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })

