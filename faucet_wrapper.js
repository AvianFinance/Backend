const { get_signer } = require('./services/token_standard')
const {deploy_rentalWrapper} = require('./deploy/deploy_RentWrapper')
const {DepositNFT, WithdrawNFT} = require('./scripts/wrapper_functions')
const {getUserInputText,getUserInputInt, getUserInputFromDropdown} = require('./services/cli-commands')
const { wrapper_list } = require('./config')

const provides = ['Wrap a Collection', 'Deposit an NFT','Withdraw an NFT','Go Back'];

async function wrapper_handler(){

    const systemType = await getUserInputFromDropdown('Select the required functionality',provides)

    switch(systemType) {
        case 0:
            const a_signer = await get_signer(true);
            const a_collection = await getUserInputText("Input the address of the collection");
            const a_name = await getUserInputText("Input a name for the wrapped collection");
            const a_symbol = await getUserInputText("Input a symbol for the wrapped collection");
            const a_response = await deploy_rentalWrapper(a_signer, a_name, a_symbol, a_collection);
            return(a_response);
        case 1:
            const b_signer = await get_signer(true);
            const b_wrapper_ind = await getUserInputFromDropdown('Select the required wrapper',wrapper_list)
            const b_wrapper_addr = wrapper_list[b_wrapper_ind]
            const b_token_ID = await getUserInputInt("Input the token id of the nft");
            const b_response = await DepositNFT(b_wrapper_addr, b_token_ID, b_signer);
            return(b_response);
        case 2:
            const c_signer = await get_signer(true);
            const c_wrapper_ind = await getUserInputFromDropdown('Select the required wrapper',wrapper_list)
            const c_wrapper_addr = wrapper_list[c_wrapper_ind]
            const c_token_ID = await getUserInputInt("Input the token id of the nft");
            const c_response = await WithdrawNFT(c_wrapper_addr, c_token_ID, c_signer);
            return(c_response);
        case 3:
            return("Returning to the main menu");
        default:
            console.log("No Option Selected");
        }
}


module.exports = {
    wrapper_handler
};
