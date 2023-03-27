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

    Before listing the sell proxy needs to be approved for the corresponding NFT. Can be done via,

    const approvalTx = await nft_contract.approve(sellexchange_contract_address, token_id)

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
        { value: listing_fee, }
    )

    emits NFTListed(
            owner_address,
            address(0),
            collection_address,
            token_id,
            price_per_day,
            0
        );

    to get the listing fee use : const listingFee = (await rentexchange_contract.getListingFee()).toString();

    Before listing the rent proxy needs to be approved for the corresponding NFT (Logic provided above)
```

### Unlisting an already listed NFT to Sell

```
    Needs to be signed by the owner of the nft

    const tx = await rentexchange_contract.unlistNFT(                 
        address collection_address, 
        uint256 token_id
    )

    emits NFTUnlisted(msg.sender,collection_address,token_id);
```

### Updating an existing NFT

```
    Needs to be signed by the owner of the nft

    const tx = await sellexchange_contract.updateRentNFT(
        address collection_address,
        uint256 token_id,
        uint256 price_per_day
    )

    emits NFTListed(
            owner,
            user,
            collection_address,
            token_id,
            price_per_day,
            expiry_time
        );
```

### Renting an existing NFT

```
    Needs to be signed by the buyer of the nft

    const tx = await rentexchange_contract.rentNFT(
        address collection_address,
        uint256 token_id,
        uint64 num_days,
        {value: rental_fee}
    )

    emit NFTRented(
            owner,
            user,
            collection_addressract,
            token_id,
            expires,
            rental_fee
        );

    rental_fee needs to be calculated properly by the implementor, before calling the rentNFT function.

```

### Viewing a single NFT listed for selling

```
    Not required to sign by the users

    const tx = await rentexchange_contract.getARListing(
        address collection_address, 
        uint256 token_id)

    returns the corresponding listing structure.
```

### Viewing all the NFT collections listed for renting

```
    Not required to sign by the users

    const tx = await rentexchange_contract.getRListedAdddresses()

    returns all the collection addresses listed for renting.
```

### Viewing all the token ids of a NFT collections listed for selling

```
    Not required to sign by the users

    const tx = await rentexchange_contract.getRListedAdddressTokens(
        address collection_address)

    returns all the token ids of the given addresses listed for renting.
```

## Installment based rental Exchange proxy

```
    Installment based rental exchange supports and hold all the market data related to renting and lending erc4907 based NFTs via installments.
```

### Listing a NFT to lend

```
    Needs to be signed by the owner of the nft

    const tx = await insexchange_contract.listInsBasedNFT(
        address collection_addres,
        uint256 token_id,
        uint256 price_per_day,
        { value: listing_fee, }
    )

    emits INSNFTListed(
            owner,
            user,
            collection_addres,
            token_id,
            price_per_day
        );

    to get the listing fee use : const listingFee = (await insexchange_contract.getListingFee()).toString();

    Before listing the rent proxy needs to be approved for the corresponding NFT (Logic provided above)
```

### Unlisting an already listed NFT to Sell

```
    Needs to be signed by the owner of the nft

    const tx = await insexchange_contract.unlistINSNFT(                 
        address collection_address, 
        uint256 token_id
    )

    emits NFTUnlisted(msg.sender,collection_address,token_id);
```

### Renting an existing NFT

```
    Needs to be signed by the buyer of the nft

    const tx = await insexchange_contract.rentINSNFT(
        address collection_address,
        uint256 token_id,
        uint64 num_days,
        {value: first_installment}
    )

    emits NFTINSPaid(
            owner,
            user,
            collection_address,
            token_id,
            expires,
            num_days,
            1,
            first_installment,
            first_installment
        );

    first_installment needs to be calculated properly by the implementor, before calling the rentNFT function as below,

    const firstIns = (await insexchange_contract.getNftInstallment(collection_address, token_id, num_days)).toString();

```

### Paying the next installment an existing NFT for a rented NFT
```
    Needs to be signed by the buyer of the nft

    const tx = await insexchange_contract.payNFTIns(
        address collection_address,
        uint256 token_id,
        {value: next_installment}
    )

    emits NFTINSPaid(
            owner,
            user,
            collection_address,
            token_id,
            expires,
            num_days,
            installment_index,
            this_installment,
            total_paid
        );

    next_installment needs to be calculated properly by the implementor, before calling the payNFTIns function as below,

    const nextIns = (await insexchange_contract.getNftInstallment(collection_address, token_id, 0)).toString();

```

### Viewing a single NFT listed for selling

```
    Not required to sign by the users

    const tx = await insexchange_contract.getAInsListing(
        address collection_address, 
        uint256 token_id)

    returns the corresponding listing structure.
```

### Viewing all the NFT collections listed for renting

```
    Not required to sign by the users

    const tx = await insexchange_contract.getInsListedAdddresses()

    returns all the collection addresses listed for installment based renting.
```

### Viewing all the token ids of a NFT collections listed for selling

```
    Not required to sign by the users

    const tx = await insexchange_contract.getInsListedAdddressTokens(
        address collection_address)

    returns all the token ids of the given addresses listed for installment based rentings.
```

