const { get_signer } = require('./services/token_standard')
const {getUserInputFromDropdown, getUserInputInt, getUserInputFloat, getUserInputText} = require('./services/cli-commands')
const { ListInsNFT,ViewAInsListing,ViewInsListedAddrs,ViewInsListedAddrTokens,view_installment,unlist_nft,rentInsNFT,payNextIns, ViewImplContract, UpdateImplContract} = require('./scripts/installment_functions')

stand = "ERC4907" // token type : set correctly before initiating

const provides = ['List an NFT', 'Unlist an NFT','View a Single listing','View all the listed collections', 'View the listed token ids of a collection','Rent a listed NFT','Pay due installments for a rented NFT','View the next installment','View the Implementation Address','Update the implementation','Go back'];

async function iexchange_handler(){

    const systemType = await getUserInputFromDropdown('Select the required functionality',provides)

    let start = Date.now();

    switch(systemType) {
        case 0:
            const a_signer = await get_signer(true);
            const a_token_ID = await getUserInputInt("Input the token id of the nft");
            const a_price = await getUserInputFloat("Input the price in AVAX");
            const a_response = await ListInsNFT(a_token_ID,a_price,a_signer,stand);
            console.log("List an NFT : ",Date.now() - start);
            return(a_response);
        case 1:
            const b_signer = await get_signer(true);
            const b_token_ID = await getUserInputInt("Input the token id of the nft");
            const b_response = await unlist_nft(b_token_ID,b_signer,stand);
            console.log("Unlist an NFT : ",Date.now() - start);
            return(b_response);
        case 2:
            const c_provider = await get_signer(false);
            const c_token_ID = await getUserInputInt("Input the token id of the nft");
            const c_response = await ViewAInsListing(c_token_ID,c_provider,stand);
            console.log("View a Single listing : ",Date.now() - start);
            return(c_response);
        case 3:
            const d_provider = await get_signer(false);
            const d_response = await ViewInsListedAddrs(d_provider) 
            console.log("View all the listed collections : ",Date.now() - start);
            return(d_response);
        case 4:
            const e_provider = await get_signer(false);
            const e_response = await ViewInsListedAddrTokens(stand,e_provider)
            console.log("View the listed token ids of a collection : ",Date.now() - start);
            return(e_response)
        case 5:
            const f_signer = await get_signer(true);
            const f_token_ID = await getUserInputInt("Input the token id of the nft");
            const f_days = await getUserInputInt("Input the number of days required (maximum 10)");
            const f_response = await rentInsNFT(f_token_ID,f_signer,stand,f_days)
            console.log("Rent a listed NFT : ",Date.now() - start);
            return(f_response);
        case 6:
            const g_signer = await get_signer(true);
            const g_token_ID = await getUserInputInt("Input the token id of the nft");
            const g_response = await payNextIns(g_token_ID,g_signer,stand)
            console.log("Pay due installments for a rented NFT : ",Date.now() - start);
            return(g_response);
        case 7:
            const h_signer = await get_signer(true);
            const h_token_ID = await getUserInputInt("Input the token id of the nft");
            const h_days = await getUserInputInt("Input the number of days required (maximum 10)");
            const h_response = await view_installment(h_token_ID,h_signer,stand,h_days)
            console.log("View the next installment : ",Date.now() - start);
            return(h_response);
        case 8:
            const i_signer = await get_signer(false);
            const i_response = await ViewImplContract(i_signer)
            console.log("View the Implementation Address : ",Date.now() - start);
            return(i_response);
        case 9:
            const j_signer = await get_signer(true); 
            const j_new_impl = await getUserInputText("Input the address of the new implementation contract");
            const j_response = await UpdateImplContract(j_new_impl,j_signer)
            console.log("Update the implementation : ",Date.now() - start);
            return(j_response);
        case 10:
            return("Returning to the main menu");
        default:
            console.log("No Option Selected");
        }
}


module.exports = {
    iexchange_handler
};
