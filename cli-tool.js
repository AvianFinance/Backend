const {getUserInputFromDropdown} = require('./services/cli-commands')
const {sexchange_handler} =  require('./faucet_sell')
const {rexchange_handler} =  require('./faucet_rent')
const {iexchange_handler} = require('./facet_ins')
var figlet = require('figlet');

let runStatus = "Running";

async function main(){

    console.log(figlet.textSync('Avian Finance', {
        whitespaceBreak: true
    }));

    while (runStatus=="Running"){
        console.log("Welcome to Avian Finance Backend Handler")
        const systemType = await getUserInputFromDropdown('Choose the system for your trading purpose ',['Buy|Sell','Outright Rental','Installment based Rental','Terminate'])

        switch(systemType) {
            case 0:
                console.log("Welcome to Buy|Sell Exchange");
                const s_response = await sexchange_handler()
                console.log(s_response);
                break;
            case 1:
                console.log("Welcome to Outright Rental Exchange");
                const r_response = await rexchange_handler()
                console.log(r_response);
                break;
            case 2:
                console.log("Welcome to Installment based Rental Exchange");
                const i_response = await iexchange_handler()
                console.log(i_response);
                break;
            case 3:
                console.log("Thank you for using Avian Finance for your NFT Tradings !!!")
                runStatus = "Stop";
                break;
            default:
                console.log("No Option Selected");
            }
    
    }

}

main();


