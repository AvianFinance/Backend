# Project Title


## Listing Functionality

### Listing a NFT to Sell

```
    const tx = await mplace_contract.listItem(token_contract.address, tokenId, PRICE)
```

### Updating an existing NFT

```
    const tx = await mplace_contract.updateListing(token_address, tokenId, PRICE)
```

### Unlisting an already listed NFT to Sell

```
    function cancelListing(       
        address nftAddress, 
        uint256 tokenId
    )
```

### Listing a NFT to Rent

```
    const tx =  await mplace_contract.listNFT(token_contract.address, tokenId, PRICE, sDate, eDate,{
                    value: listingFee,
                })
```

### Unlisting an already listed NFT to Rent

```
    function unlistNFT(                        
        address nftAddress, 
        uint256 tokenId
    )
```

## Buying Functionality

### Buying an already listed NFT

```
    const tx =  await mplace_contract.buyItem(token_address, tokenID, {
                    value: price,
                })
```

## Renting Functionality

### Renting an already listed NFT to Rent

```
const txn = await mplace_contract.rentNFT(token_address, tokenID, days, {
                value: price
            }) 
```

## Handling Proceeds

### View available proceeds

```
    function getProceeds(address seller)
```

### Get available proceeds

```
    const tx = await mplace_contract.withdrawProceeds()
```

## Getter functions for Buy/Sell

### View available listings for selling

```
    const tx = await mplace_contract.getSellListings()
```

### View collection addresses listed to sell

```
    const tx = await mplace_contract.getSListedAdddresses()
```

### View token ids of a given collection, listed to sell

```
    const tx = await mplace_contract.getSListedAdddressTokens(token_address)
```

### View price info of a sell single listing

```
    const tx = await mplace_contract.getASListing(token_address, tokenId)
```


## Getter functions for Rent/Lend

### View available listings for renting

```
    const tx = await mplace_contract.getRentListings()
```

### View collection addresses listed to rent

```
    const tx = await mplace_contract.getRListedAdddresses()
```

### View token ids of a given collection, listed to rent

```
    const tx = await mplace_contract.getRListedAdddressTokens(token_address)
```

### View price info of a single rent listing

```
    const tx = await mplace_contract.getARListing(token_address, tokenId)
```

## Service Functions

### View the listing charge for rental lists

```
    const listingFee = (await mplace_contract.getListingFee()).toString();
```

### Check whether a contract is 4907 or not

```
    const tx = await mplace_contract.isRentableNFT(address nftContract)
```

### Check whether a contract is 721 or not

```
    const tx = await mplace_contract.isNFT(address nftContract)
```





































