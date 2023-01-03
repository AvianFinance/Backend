const { rime_token } = require('../config')
const { rime_rent } = require('../config')

const fs = require('fs');


async function get_standard(token_type) { // token_type shout be ERC721 or ERC4907

    if (token_type=="ERC721"){
        const RimeToken = JSON.parse(fs.readFileSync('./artifacts/contracts/RimeToken.sol/RimeToken.json', 'utf-8'))
        return({"addr":rime_token,"token":RimeToken})
    }
    else if(token_type=="ERC4907"){
        const RimeRent = JSON.parse(fs.readFileSync('./artifacts/contracts/RimeRent.sol/RimeRent.json', 'utf-8'))
        return({"addr":rime_rent,"token":RimeRent})
    }

}

module.exports = {
    get_standard,
};