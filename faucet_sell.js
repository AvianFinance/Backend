const { get_signer } = require('./services/token_standard')
const {getUserInputFromDropdown, getUserInputInt, getUserInputFloat} = require('./services/cli-commands')
const { pullProceeds, viewProceeds } = require('./scripts/get_proceeds')
const { ListNFT, cancelListing,UpdateListing, ViewASellListing, ViewSellListedAddrs, ViewSellListedAddrTokens, buyNFT} = require('./scripts/sell_functions')

const provides = ['List an NFT', 'Unlist an NFT','View a Single listing','View all the listed collections', 'View the listed token ids of a collection','Update the price of a listed NFT','Buy a listed NFT','View the available proceeds','Obtain the available proceeds','Go Back'];

async function sexchange_handler(){

    stand = "ERC721" // token type : set correctly before initiating

    const systemType = await getUserInputFromDropdown('Select the required functionality',provides)

    switch(systemType) {
        case 0:
            const a_signer = await get_signer(true);
            const a_token_ID = await getUserInputInt("Input the token id of the nft");
            const a_price = await getUserInputFloat("Input the price in AVAX");
            const a_response = await ListNFT(a_token_ID,a_price,a_signer,stand);
            return(a_response);
        case 1:
            const b_signer = await get_signer(true);
            const b_token_ID = await getUserInputInt("Input the token id of the nft");
            const b_response = await cancelListing(b_token_ID,b_signer,stand);
            return(b_response);
        case 2:
            const c_provider = await get_signer(false);
            const c_token_ID = await getUserInputInt("Input the token id of the nft");
            const c_response = await ViewASellListing(c_token_ID,c_provider,stand);
            return(c_response);
        case 3:
            const d_provider = await get_signer(false);
            const d_response = await ViewSellListedAddrs(d_provider);
            return(d_response);
        case 4:
            const e_provider = await get_signer(false);
            const e_response = await ViewSellListedAddrTokens(stand,e_provider);
            return(e_response)
        case 5:
            const f_signer = await get_signer(true);
            const f_token_ID = await getUserInputInt("Input the token id of the nft");
            const f_price = await getUserInputFloat("Input the price in AVAX");
            const f_response = await UpdateListing(f_token_ID,f_price,f_signer,stand) 
            return(f_response);
        case 6:
            const g_signer = await get_signer(true);
            const g_token_ID = await getUserInputInt("Input the token id of the nft");
            const g_response = await buyNFT(g_token_ID,g_signer,stand) 
            return(g_response);
        case 7:
            const h_signer = await get_signer(true);
            const h_response = await viewProceeds(h_signer);
            return(h_response);
        case 8:
            const i_signer = await get_signer(true);
            const i_response = await pullProceeds(i_signer)
            return(i_response)
        case 9:
            return("Returning to the main menu");
        default:
            console.log("No Option Selected");
        }
}


module.exports = {
    sexchange_handler
};
