# Project Title


## Listing Functionality

### Listing a NFT to Sell

```
function listItem(address nftAddress, uint256 tokenId, uint256 price)
```

### Updating an existing NFT

```
    function updateListing(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
    )
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
    function listNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 pricePerDay,
        uint256 startDateUNIX,
        uint256 endDateUNIX
    )
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
    function buyItem(         
        address nftAddress, 
        uint256 tokenId
    )
```

## Renting Functionality

### Renting an already listed NFT to Rent

```
    function rentNFT(
        address nftContract,
        uint256 tokenId,
        uint64 numDays
    )
```

## Handling Proceeds

### View available proceeds

```
    function getProceeds(address seller)
```

### Get available proceeds

```
    function withdrawProceeds()
```

## Getter functions for Buy/Sell

### View available listings for selling

```
    function getSellListings()
```

### View collection addresses listed to sell

```
    function getSListedAdddresses()
```

### View token ids of a given collection, listed to sell

```
    function getSListedAdddressTokens(address nftAddress)
```

### View price info of a sell single listing

```
    function getASListing(address nftAddress, uint256 tokenId)
```


## Getter functions for Rent/Lend

### View available listings for renting

```
    function getRentListings()
```

### View collection addresses listed to rent

```
    function getRListedAdddresses()
```

### View token ids of a given collection, listed to rent

```
    function getRListedAdddressTokens(address nftAddress)
```

### View price info of a single rent listing

```
    function getARListing(address nftAddress, uint256 tokenId)
```

## Service Functions

### View the listing charge for rental lists

```
    function getListingFee()
```

### Check whether a contract is 4907 or not

```
    function isRentableNFT(address nftContract)
```

### Check whether a contract is 721 or not

```
    function isNFT(address nftContract)
```





































