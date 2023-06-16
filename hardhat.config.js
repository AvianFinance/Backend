require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-ethers");

/** @type import('hardhat/config').HardhatUserConfig */

const PRIVATE_KEY = "986815db062b75efa84cd38ea93e08e9e13a42ee9493f756c1bc661d06201e68"

module.exports = {
  solidity: "0.8.17",
  defaultNetwork: "avalanche_fuji",
  networks: {
    avalanche_fuji: {
      url: "https://api.avax-test.network/ext/bc/C/rpc",//"https://avalanche-fuji.infura.io/v3/af80fbafec67441595f581fbeb7c8f1e", //"https://api.avax-test.network/ext/bc/C/rpc",
      accounts: [`0x${PRIVATE_KEY}`]
    }
  }
};


