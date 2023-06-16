require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-ethers");

/** @type import('hardhat/config').HardhatUserConfig */

const PRIVATE_KEY = "986815db062b75efa84cd38ea93e08e9e13a42ee9493f756c1bc661d06201e68"
// const PRIVATE_KEY = "77c96d3532794190a06c9cc280427019"

module.exports = {
  solidity: "0.8.17",
  defaultNetwork: "goerli",
  networks: {
    goerli: {
      url: "https://goerli.infura.io/v3/306c106577824785a447b6398a50916e",//"https://avalanche-fuji.infura.io/v3/af80fbafec67441595f581fbeb7c8f1e", //"https://api.avax-test.network/ext/bc/C/rpc",
      accounts: [`0x${PRIVATE_KEY}`]
    }
  }
};


