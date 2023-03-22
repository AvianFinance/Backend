const {getUserInputFromDropdown} = require('./services/cli-commands')
const {sexchange_handler} =  require('./faucet_sell')

let runStatus = "Running";

async function main(){

    while (runStatus=="Running"){
        console.log("Welcome to Avian Finance Backend Handler")
        const systemType = await getUserInputFromDropdown('Choose the system for your trading purpose ',['Buy|Sell','Outright Rental','Installment based Rental','Terminate'])

        switch(systemType) {
            case 0:
                console.log("Welcome to Buy|Sell Exchange");
                const response = await sexchange_handler()
                console.log(response);
                break;
            case 1:
                console.log("Welcome to Outright Rental Exchange");
                break;
            case 2:
                console.log("Welcome to Installment based Rental Exchange");
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



