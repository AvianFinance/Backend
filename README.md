# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```

Before running un

    npm install
    npx hardhat compile 

Deploy the nft smart contract run : npx hardhat run scripts/deploy_RimeToken.js --network avalanche_fuji

Minting NFT : npx hardhat run scripts/mint_nft.js --network avalanche_fuji

List the NFT : npx hardhat run scripts/list_nft.js --network avalanche_fuji

Update the price : npx hardhat run scripts/update_listed_nft.js --network avalanche_fuji


npx hardhat run faucet.js --network avalanche_fuji



Config settings if required

  mplace_token = "0x87e402f8bdc77d2C7995b1474D7c31f87f8b03c8"
  rime_token   = "0x4909493F604AB882327ca880ad5B330e2B3C43C1"
  
  module.exports = {
      rime_token,
      mplace_token,
  };