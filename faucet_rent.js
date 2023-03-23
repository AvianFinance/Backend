const { get_signer } = require('./services/token_standard')
const {getUserInputFromDropdown, getUserInputInt, getUserInputFloat} = require('./services/cli-commands')
const { ListRentNFT, cancelRentNFT, updateRentNFT, ViewARentListing,ViewRentListedAddrs, ViewRentListedAddrTokens, rentNFT} = require('./scripts/rexchange_functions')

stand = "ERC4907" 

const provides = ['List an NFT', 'Unlist an NFT','View a Single listing','View all the listed collections', 'View the listed token ids of a collection','Update the price of a listed NFT','Rent a listed NFT'];

async function rexchange_handler(){

    const systemType = await getUserInputFromDropdown('Select the required functionality',provides)

    switch(systemType) {
        case 0:
            const a_signer = await get_signer(true);
            const a_token_ID = await getUserInputInt("Input the token id of the nft");
            const a_price = await getUserInputFloat("Input the price in AVAX");
            const a_response = await ListRentNFT(a_token_ID,a_price,a_signer,stand)
            return(a_response);
            break;
        case 1:
            const b_signer = await get_signer(true);
            const b_token_ID = await getUserInputInt("Input the token id of the nft");
            const b_response = await cancelRentNFT(b_token_ID,b_signer,stand)
            return(b_response);
            break;
        case 2:
            const c_provider = await get_signer(false);
            const c_token_ID = await getUserInputInt("Input the token id of the nft");
            const c_response = await ViewARentListing(c_token_ID,c_provider,stand) 
            return(c_response);
        case 3:
            const d_provider = await get_signer(false);
            const d_response = await ViewRentListedAddrs(d_provider) 
            return(d_response);
        case 4:
            const e_provider = await get_signer(false);
            const e_response = await ViewRentListedAddrTokens(stand,e_provider) 
            return(e_response)
        case 5:
            const f_signer = await get_signer(true);
            const f_token_ID = await getUserInputInt("Input the token id of the nft");
            const f_price = await getUserInputFloat("Input the price in AVAX");
            const f_response = await updateRentNFT(f_token_ID,f_price,f_signer,stand)
            return(f_response);
        case 6:
            const g_signer = await get_signer(true);
            const g_token_ID = await getUserInputInt("Input the token id of the nft");
            const g_days = await getUserInputInt("Input the number of days required (maximum 10)");
            const g_response = await rentNFT(g_token_ID,g_signer,stand,g_days);
            return(g_response);
        default:
            console.log("No Option Selected");
        }
}


module.exports = {
    rexchange_handler
};
