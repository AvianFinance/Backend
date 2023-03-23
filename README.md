This is the implementation of the AvianMarket platform implemented with Solidity on Avalanche Fuji Testnet.

Follow the below step to generate a working project.

> Step 01 : Clone the repository to your local directory.
> Step 02 : In a terminal opened in the cloned directory run,

            npm install 

            This should install all the required dependencies, node_modules folder will be added to the directory. 
        
> Step 03 : Compile the smart contracts available in the contracts folder, via

            npx hardhat compile

            This should create a folders artifcats (will hold the compiled versions of the smart contracts) and cache.

> Step 04: In a terminal opened in the backend directory, run

            node cli-tool.js

In case you require to deploy your own version of the smart contract:

> Step 01 : Choose the smart contract you want from the contracts folder.

> Step 02 : Do any required modification in the code.

> Step 03 : Compile the smart contract via,

            npx hardhat compile

> Step 04 : Deploy the contract to fuji testnet via,

            npx hardhat run deploy/<corresponding deploy script> 