const { rime_token } = require('../config')
const { rime_rent } = require('../config')
const {getUserInputFromDropdown, getUserInputInt, getUserInputFloat} = require('./cli-commands')
const { ethers } = require("hardhat")

const fs = require('fs');

const provider = new ethers.providers.JsonRpcProvider("https://api.avax-test.network/ext/bc/C/rpc")
const eth_provider = new ethers.providers.JsonRpcProvider("https://goerli.infura.io/v3/086ef2c6684246f5a5a39f241fd2aaed")
const signer_m = new ethers.Wallet("7e0dd21cba3952c769b9a90376893a351d4ac356aeacd0e537f5022e08593528", provider); // Meelan Credentials
const signer_r = new ethers.Wallet("2f3b47319ba27e3e58ae7a62ecb3966b23b9df1b8a12d1b7520f643a6d7fdc33", provider); // Rosy credentials
const signer_i = new ethers.Wallet("986815db062b75efa84cd38ea93e08e9e13a42ee9493f756c1bc661d06201e68", eth_provider); // Meelan Credentials

async function get_standard(token_type) { // token_type shout be ERC721 or ERC4907

    if (token_type=="ERC721"){
        const RimeToken = JSON.parse(fs.readFileSync('./artifacts/contracts/AVFXGeneral.sol/AVFXGeneral.json', 'utf-8'))
        return({"addr":rime_token,"token":RimeToken})
    }
    else if(token_type=="ERC4907"){
        const RimeRent = JSON.parse(fs.readFileSync('./artifacts/contracts/AVFXRent.sol/AVFXRent.json', 'utf-8'))
        return({"addr":rime_rent,"token":RimeRent})
    }

}

async function get_signer(condition) { 
    if (condition){
        const signer = await getUserInputFromDropdown('Select the required signer',['isuru','meelan','roshinie'])
        switch(signer) {
            case 0:
                return(signer_i);
            case 1:
                return(signer_m);
            case 2:
                return(signer_r)
            default:
                return(provider);
            }
    }else{
        return(provider);
    }

}


module.exports = {
    get_standard,
    get_signer
};