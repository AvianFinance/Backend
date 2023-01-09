
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "./IERC4907.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error ItemNotForSale(address nftAddress, uint256 tokenId);
error NotListed(address nftAddress, uint256 tokenId);
error AlreadyListed(address nftAddress, uint256 tokenId);
error NoProceeds();
error NotOwner();
error NotApprovedForMarketplace();
error PriceMustBeAboveZero();


contract Marketplace is ReentrancyGuard {

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    
    Counters.Counter private _nftsListed;
    address private _marketOwner;
    uint256 private _listingFee = .001 ether;

    struct Listing_sell {
        uint256 price;
        address seller;
    }

    struct Listing_rent {
        address owner;
        address user;
        address nftContract;
        uint256 tokenId;
        uint256 pricePerDay;
        uint256 startDateUNIX; // when the nft can start being rented
        uint256 endDateUNIX; // when the nft can no longer be rented
        uint256 expires; // when the user can no longer rent it
    }

    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    event ItemCanceled(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    event ItemBought(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    // events for nft rentals

    event NFTListed(
        address indexed owner,
        address indexed user,
        address indexed nftContract,
        uint256 tokenId,
        uint256 pricePerDay,
        uint256 startDateUNIX,
        uint256 endDateUNIX,
        uint256 expires
    );
    event NFTRented(
        address indexed owner,
        address indexed user,
        address indexed nftContract,
        uint256 tokenId,
        uint256 startDateUNIX,
        uint256 endDateUNIX,
        uint64 expires,
        uint256 rentalFee
    );
    event NFTUnlisted(
        address indexed unlistSender,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 refund
    );

    // mapping for basics

    mapping(address => mapping(uint256 => Listing_sell)) private s_listings;
    mapping(address => uint256) private s_proceeds;

    // mapping for rentals

    // maps contract address to token id to properties of the rental listing
    mapping(address => mapping(uint256 => Listing_rent)) private _listingMap;
    // maps nft contracts to set of the tokens that are listed
    mapping(address => EnumerableSet.UintSet) private _nftContractTokensMap;
    // tracks the nft contracts that have been listed
    EnumerableSet.AddressSet private _nftContracts;

    // modifiers for basics

    modifier notListed(
        address nftAddress,
        uint256 tokenId
    ) {
        Listing_sell memory listing = s_listings[nftAddress][tokenId];
        if (listing.price > 0) {
            revert AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing_sell memory listing = s_listings[nftAddress][tokenId];
        if (listing.price <= 0) {
            revert NotListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NotOwner();
        }
        _;
    }

    // To provide the listing fee

    constructor() {
        _marketOwner = msg.sender;
    }

    // start of the basic functions

    // IsNotOwner Modifier - Nft Owner can't buy his/her NFT
    // Modifies buyItem function
    // Owner should only list, cancel listing or update listing
    /* modifier isNotOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender == owner) {
            revert IsNotOwner();
        }
        _;
    } */

    /////////////////////
    // Main Functions //
    /////////////////////
    /*
     * @notice Method for listing NFT
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     * @param price sale price for each item
     */
    function listItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    )
        external
        notListed(nftAddress, tokenId)
        isOwner(nftAddress, tokenId, msg.sender)
    {
        if (price <= 0) {
            revert PriceMustBeAboveZero();
        }
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NotApprovedForMarketplace();
        }
        s_listings[nftAddress][tokenId] = Listing_sell(price, msg.sender);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    /*
     * @notice Method for cancelling listing
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     */
    function cancelListing(address nftAddress, uint256 tokenId)
        external
        isOwner(nftAddress, tokenId, msg.sender)
        isListed(nftAddress, tokenId)
    {
        delete (s_listings[nftAddress][tokenId]);
        emit ItemCanceled(msg.sender, nftAddress, tokenId);
    }

    /*
     * @notice Method for buying listing
     * @notice The owner of an NFT could unapprove the marketplace,
     * which would cause this function to fail
     * Ideally you'd also have a `createOffer` functionality.
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     */
    function buyItem(address nftAddress, uint256 tokenId)
        external
        payable
        isListed(nftAddress, tokenId)
        // isNotOwner(nftAddress, tokenId, msg.sender)
        nonReentrant
    {
        // Challenge - How would you refactor this contract to take:
        // 1. Abitrary tokens as payment? (HINT - Chainlink Price Feeds!)
        // 2. Be able to set prices in other currencies?
        // 3. Tweet me @PatrickAlphaC if you come up with a solution!
        Listing_sell memory listedItem = s_listings[nftAddress][tokenId];
        if (msg.value < listedItem.price) {
            revert PriceNotMet(nftAddress, tokenId, listedItem.price);
        }
        s_proceeds[listedItem.seller] += msg.value;
        // Could just send the money...
        // https://fravoll.github.io/solidity-patterns/pull_over_push.html
        delete (s_listings[nftAddress][tokenId]);
        IERC721(nftAddress).safeTransferFrom(listedItem.seller, msg.sender, tokenId);
        emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
    }

    /*
     * @notice Method for updating listing
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     * @param newPrice Price in Wei of the item
     */
    function updateListing(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
    )
        external
        isListed(nftAddress, tokenId)
        nonReentrant
        isOwner(nftAddress, tokenId, msg.sender)
    {
        //We should check the value of `newPrice` and revert if it's below zero (like we also check in `listItem()`)
        if (newPrice <= 0) {
            revert PriceMustBeAboveZero();
        }
        s_listings[nftAddress][tokenId].price = newPrice;
        emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);
    }

    /*
     * @notice Method for withdrawing proceeds from sales
     */
    function withdrawProceeds() external {
        uint256 proceeds = s_proceeds[msg.sender];
        if (proceeds <= 0) {
            revert NoProceeds();
        }
        s_proceeds[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: proceeds}("");
        require(success, "Transfer failed");
    }

    /////////////////////
    // Getter Functions //
    /////////////////////

    function getListing(address nftAddress, uint256 tokenId)
        external
        view
        returns (Listing_sell memory)
    {
        return s_listings[nftAddress][tokenId];
    }

    function getProceeds(address seller) external view returns (uint256) {
        return s_proceeds[seller];
    }


    // start of the rental functions

    function listNFT(
        address nftContract,
        uint256 tokenId,
        uint256 pricePerDay,
        uint256 startDateUNIX,
        uint256 endDateUNIX
    ) public payable nonReentrant {
        require(isRentableNFT(nftContract), "Contract is not an ERC4907");
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Not owner of nft");
        require(msg.value == _listingFee, "Not enough ether for listing fee");
        require(pricePerDay > 0, "Rental price should be greater than 0");
        require(startDateUNIX >= block.timestamp, "Start date cannot be in the past");
        require(endDateUNIX >= startDateUNIX, "End date cannot be before the start date");
        require(_listingMap[nftContract][tokenId].nftContract == address(0), "This NFT has already been listed");

        payable(_marketOwner).transfer(_listingFee);
        _listingMap[nftContract][tokenId] = Listing_rent(
            msg.sender,
            address(0),
            nftContract,
            tokenId,
            pricePerDay,
            startDateUNIX,
            endDateUNIX,
            0
        );
        _nftsListed.increment();
        EnumerableSet.add(_nftContractTokensMap[nftContract], tokenId);
        EnumerableSet.add(_nftContracts, nftContract);
        emit NFTListed(
            IERC721(nftContract).ownerOf(tokenId),
            address(0),
            nftContract,
            tokenId,
            pricePerDay,
            startDateUNIX,
            endDateUNIX,
            0
        );
    }

        // function to rent NFT
    function rentNFT(
        address nftContract,
        uint256 tokenId,
        uint64 expires
    ) public payable nonReentrant {
        Listing_rent storage listing = _listingMap[nftContract][tokenId];
        require(listing.user == address(0) || block.timestamp > listing.expires, "NFT already rented");
        require(expires <= listing.endDateUNIX, "Rental period exceeds max date rentable");
        // Transfer rental fee
        uint256 numDays = (expires - block.timestamp)/60/60/24 + 1;
        uint256 rentalFee = listing.pricePerDay * numDays;
        require(msg.value >= rentalFee, "Not enough ether to cover rental period");
        payable(listing.owner).transfer(rentalFee);
        // Update listing
        IERC4907(nftContract).setUser(tokenId, msg.sender, expires);
        listing.user = msg.sender;
        listing.expires = expires;

        emit NFTRented(
            IERC721(nftContract).ownerOf(tokenId),
            msg.sender,
            nftContract,
            tokenId,
            listing.startDateUNIX,
            listing.endDateUNIX,
            expires,
            rentalFee
        );
    }

    // function to unlist your rental, refunding the user for any lost time
    function unlistNFT(address nftContract, uint256 tokenId) public payable nonReentrant {
        Listing_rent storage listing = _listingMap[nftContract][tokenId];
        require(listing.owner != address(0), "This NFT is not listed");
        require(listing.owner == msg.sender || _marketOwner == msg.sender , "Not approved to unlist NFT");
        // fee to be returned to user if unlisted before rental period is up
        // nothing to refund if no renter
        uint256 refund = 0;
        if (listing.user != address(0)) {
            refund = ((listing.expires - block.timestamp) / 60 / 60 / 24 + 1) * listing.pricePerDay;
            require(msg.value >= refund, "Not enough ether to cover refund");
            payable(listing.user).transfer(refund);
        }
        // clean up data
        IERC4907(nftContract).setUser(tokenId, address(0), 0);
        EnumerableSet.remove(_nftContractTokensMap[nftContract], tokenId);
        delete _listingMap[nftContract][tokenId];
        if (EnumerableSet.length(_nftContractTokensMap[nftContract]) == 0) {
            EnumerableSet.remove(_nftContracts, nftContract);
        }
        _nftsListed.decrement();

        emit NFTUnlisted(
            msg.sender,
            nftContract,
            tokenId,
            refund
        );
    }

    function getAllListings() public view returns (Listing_rent[] memory) {
        Listing_rent[] memory listings = new Listing_rent[](_nftsListed.current());
        uint256 listingsIndex = 0;
        address[] memory nftContracts = EnumerableSet.values(_nftContracts);
        for (uint i = 0; i < nftContracts.length; i++) {
            address nftAddress = nftContracts[i];
            uint256[] memory tokens = EnumerableSet.values(_nftContractTokensMap[nftAddress]);
            for (uint j = 0; j < tokens.length; j++) {
                listings[listingsIndex] = _listingMap[nftAddress][tokens[j]];
                listingsIndex++;
            }
        }
        return listings;
    }

    function getListingFee() public view returns (uint256) {
        return _listingFee;
    }

    function isRentableNFT(address nftContract) public view returns (bool) {
        bool _isRentable = false;
        bool _isNFT = false;
        try IERC165(nftContract).supportsInterface(type(IERC4907).interfaceId) returns (bool rentable) {
            _isRentable = rentable;
        } catch {
            return false;
        }
        try IERC165(nftContract).supportsInterface(type(IERC721).interfaceId) returns (bool nft) {
            _isNFT = nft;
        } catch {
            return false;
        }
        return _isRentable && _isNFT;
    }
}