const { ethers } = require("hardhat")
const fs = require('fs');

async function deploy_rentalWrapper(signer, token_name, token_symbol, collectionToWrap) {

    const wrapper_metadata = JSON.parse(fs.readFileSync('./artifacts/contracts/RentWrapper.sol/RentWrapper.json', 'utf-8'))
    
    const WrapperToken = new ethers.ContractFactory(wrapper_metadata.abi, wrapper_metadata.bytecode, signer)
    
    const Wrapper = await WrapperToken.deploy(collectionToWrap, token_name,token_symbol);
    
    await Wrapper.deployed();

    console.log("Rentable 4907 Wrapper deployed to:", Wrapper.address, "for the 721 :", collectionToWrap);

    fs.appendFileSync('./wrapper_config.txt', `${token_symbol}_wrapper=${Wrapper.address}\n`,  "UTF-8",{'flags': 'a+'})

    return(Wrapper.address)
}

module.exports = {
    deploy_rentalWrapper
};
