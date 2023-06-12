const {getUserInputFromDropdown} = require('./services/cli-commands')
const {sexchange_handler} =  require('./faucet_sell')
const {rexchange_handler} =  require('./faucet_rent')
const {iexchange_handler} = require('./facet_ins')
const {wrapper_handler} = require('./faucet_wrapper')
var figlet = require('figlet');

let runStatus = "Running";

async function main(){

    console.log(figlet.textSync('Avian Finance', {
        whitespaceBreak: true
    }));

    while (runStatus=="Running"){
        console.log("Welcome to Avian Finance Backend Handler")
        const systemType = await getUserInputFromDropdown('Choose the system for your trading purpose ',['Buy|Sell','Outright Rental','Installment based Rental','General to Rental wrapping','Terminate'])

        switch(systemType) {
            case 0:
                console.log("Welcome to Buy|Sell Exchange");
                try{
                    const s_response = await sexchange_handler()
                    console.log(s_response);
                }catch(e){
                    console.log("Sell Exchange Failed with the error",e);
                }
                break;
            case 1:
                console.log("Welcome to Outright Rental Exchange");
                try{
                    const r_response = await rexchange_handler()
                    console.log(r_response);
                }catch(e){
                    console.log("Rent Exchange Failed with the error",e);
                }
                break;
            case 2:
                console.log("Welcome to Installment based Rental Exchange");
                try{
                    const i_response = await iexchange_handler()
                    console.log(i_response);
                }catch(e){
                    console.log("Installment Exchange Failed with the error",e);
                }

                break;
            case 3:
                console.log("Welcome to General to Rental wrapping tool");
                try{
                    const w_response = await wrapper_handler()
                    console.log(w_response);
                }catch(e){
                    console.log("Wrapper Failed with the error",e);
                }

                break;
            case 4:
                console.log("Thank you for using Avian Finance for your NFT Tradings !!!")
                runStatus = "Stop";
                break;
            default:
                console.log("No Option Selected");
            }
    
    }

}

main();



