# Avian Finance NFT Trading Marketplace

## Smart contract functionality documentation

```
    The marketplace interactions can be done through 3 principle proxy contracts which dynamically load the required 
    functionality from concrete implementations and the rule engine.
```

## Buy | Sell Exchange proxy

```
    Buy/Sell exchange supports and hold all the market data related to buying and selling erc721, erc4907 based NFTs.
```

### Listing a NFT to Sell

```
    Needs to be signed by the owner of the nft

    const tx = await sellexchange_contract.listItem(
        address collection_address, 
        uint256 token_id, 
        uint256 sell_price)

    emits ItemListed(msg.sender, collection_address, token_id, sell_price)
```

### Unlisting an already listed NFT to Sell

```
    Needs to be signed by the owner of the nft

    const tx = await sellexchange_contract.cancelListing(                           
        address collection_address, 
        uint256 token_id
    )

    emits ItemCanceled(msg.sender, collection_address, token_id)
```

### Updating an existing NFT

```
    Needs to be signed by the owner of the nft

    const tx = await sellexchange_contract.updateListing(
        address collection_address,
        uint256 token_id,
        uint256 new_price
    )

    emits ItemListed(msg.sender, collection_address, token_id, new_price)
```

### Buying an existing NFT

```
    Needs to be signed by the buyer of the nft

    const tx = await sellexchange_contract.buyItem(
        address collection_address, 
        uint256 token_id,
        { value: price,}
    )

    emit ItemBought(msg.sender, collection_address, token_id, price); 
```

### Viewing a single NFT listing

```
    Not required to sign by the users

    const tx = await sellexchange_contract.getASListing(
        address collection_address, 
        uint256 tokenId)

    returns the corresponding listing structure.
```

### Viewing all the NFT collections listed for selling

```
    Not required to sign by the users

    const tx = await sellexchange_contract.getSListedAdddresses()

    returns all the collection addresses listed for selling.
```

### Viewing all the token ids of a NFT collections listed for selling

```
    Not required to sign by the users

    const tx = await sellexchange_contract.getSListedAdddressTokens(
        address collection_address)

    returns all the token ids of the given addresses listed for selling.
```

### View proceeds available for sellers

```
    Needs to be signed by the seller

    const tx = await sellexchange_contract.getProceeds()

    returns the available proceeds for the seller.
```

### get proceeds available for sellers

```
    Needs to be signed by the seller 

    const tx = await sellexchange_contract.withdrawProceeds()

    returns the available proceeds for the seller.
```

## Rent | Lend Exchange proxy

```
    Rent/Lend exchange supports and hold all the market data related to renting and lending erc4907 based NFTs.
```

### Listing a NFT to lend

```
    Needs to be signed by the owner of the nft

    const tx = await rentexchange_contract.listNFT(
        address collection_addres,
        uint256 token_id,
        uint256 price_per_day,
        { value: listing_fee,}
    )

    emits NFTListed(
            owner_address,
            address(0),
            collection_address,
            token_id,
            price_per_day,
            0
        );

    to get the listing fee use : const listingFee = (await mplace_contract.getListingFee()).toString();

    Before listing 
```

### Unlisting an already listed NFT to Sell

```
    Needs to be signed by the owner of the nft

    const tx = await sellexchange_contract.cancelListing(                           
        address collection_address, 
        uint256 token_id
    )

    emits ItemCanceled(msg.sender, collection_address, token_id)
```

### Updating an existing NFT

```
    Needs to be signed by the owner of the nft

    const tx = await sellexchange_contract.updateListing(
        address collection_address,
        uint256 token_id,
        uint256 new_price
    )

    emits ItemListed(msg.sender, collection_address, token_id, new_price)
```

### Buying an existing NFT

```
    Needs to be signed by the buyer of the nft

    const tx = await sellexchange_contract.buyItem(
        address collection_address, 
        uint256 token_id,
        { value: price,}
    )

    emit ItemBought(msg.sender, collection_address, token_id, price); 
```

### Viewing a single NFT listing

```
    Not required to sign by the users

    const tx = await sellexchange_contract.getASListing(
        address collection_address, 
        uint256 tokenId)

    returns the corresponding listing structure.
```

### Viewing all the NFT collections listed for selling

```
    Not required to sign by the users

    const tx = await sellexchange_contract.getSListedAdddresses()

    returns all the collection addresses listed for selling.
```

### Viewing all the token ids of a NFT collections listed for selling

```
    Not required to sign by the users

    const tx = await sellexchange_contract.getSListedAdddressTokens(
        address collection_address)

    returns all the token ids of the given addresses listed for selling.
```

