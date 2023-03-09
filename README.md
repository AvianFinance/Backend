This is the implementation of the AvianMarket platform implemented with Solidity on Avalanche Fuji Testnet.

Follow the below step to generate a working project.

> Step 01 : Clone the repository to your local directory.
> Step 02 : In a terminal opened in the cloned directory run,

            npm install 

            This should install all the required dependencies, node_modules folder will be added to the directory. 
        
> Step 03 : Compile the smart contracts available in the contracts folder, via

            npx hardhat compile

            This should create a folder called artifcats, it will hold the compiled versions of the smart contracts.

> Step 04: Go to the faucet.js and run one of the two functions with edits as required via,

            node faucet.js


In case you require to deploy your own version of the smart contract:

> Step 01 : Choose the smart contract you want from the contracts folder.

> Step 02 : Do any required modification in the code.

> Step 03 : Compile the smart contract via,

            npx hardhat compile

> Step 04 : Deploy the contract to fuji testnet via,

            npx hardhat run scripts/deploy_RimeToken.js --network avalanche_fuji


old_mplace_token = "0x35A0e34Ae03EE9e0Bfc510E75d6251510f531bFc"    
amplace_token = "0x4608a302Ab37866d31c7ee3f2a2E78B333C4D6e5"
insmplace_token = "0x6d7ACd03C210f848155DA44Ce77e1715E4578691"
rime_token   = "0x71146F50Cf97A5B2b8D66bc5bfF93b86Cd3FF1f1"
rime_rent = "0xA5e80F4980878b7C2c23D6fA002358A47d0060a3"

module.exports = {
    rime_token,
    rime_rent,
    amplace_token,
    insmplace_token,
};