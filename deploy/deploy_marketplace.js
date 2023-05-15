const hre = require("hardhat");
const fs = require('fs');

// async function main() {  //Create the address for the RimeToken collection
//     const SExchange = await hre.ethers.getContractFactory("AvianSellExchange");
//     const RExchange = await hre.ethers.getContractFactory("AvianRentExchange");
//     const IExchange = await hre.ethers.getContractFactory("AvianInsExchange");

//     const sexchange_token = await SExchange.deploy();
//     await sexchange_token.deployed();

//     const rexchange_token = await RExchange.deploy();
//     await rexchange_token.deployed();

//     const iexchange_token = await IExchange.deploy();
//     await iexchange_token.deployed();

//     console.log("MarketPlace deployed successfully !");

//     fs.writeFileSync('./config.js', `
//     sexchange_token = "${sexchange_token.address}"
//     rexchange_token = "${rexchange_token.address}"
//     iexchange_token = "${iexchange_token.address}"

//     module.exports = {
//         sexchange_token,
//         rexchange_token,
//         iexchange_token,
//     };
//     `)
// }

async function main() {  //Create the address for the RimeToken collection
    const proxy = await hre.ethers.getContractFactory("ASE_Proxy");
    const impl = await hre.ethers.getContractFactory("AvianSellExchange");

    const impl_token = await impl.deploy();
    await impl_token.deployed();

    const proxy_token = await proxy.deploy(impl_token.address);
    await proxy_token.deployed();

    console.log("MarketPlace deployed successfully !");

    console.log(impl_token.address);

    fs.writeFileSync('./config.js', `
    impl_token = "${impl_token.address}"
    proxy_token = "${proxy_token.address}"
    `)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
