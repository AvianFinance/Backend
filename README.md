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


All the functionailty is available through the faucet.js
Change the handler as required and run with,

    > node faucet.js

// Not required

Minting NFT : npx hardhat run scripts/mint_nft.js --network avalanche_fuji

List the NFT : npx hardhat run scripts/list_nft.js --network avalanche_fuji

Update the price : npx hardhat run scripts/update_listed_nft.js --network avalanche_fuji

Config settings if required

mplace_token = "0x87e402f8bdc77d2C7995b1474D7c31f87f8b03c8"
rime_token   = "0x4909493F604AB882327ca880ad5B330e2B3C43C1"
rime_rent = "0xA5e80F4980878b7C2c23D6fA002358A47d0060a3"

module.exports = {
    rime_token,
    mplace_token,
    rime_rent
};