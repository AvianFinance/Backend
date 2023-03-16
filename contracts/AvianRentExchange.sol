
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


contract AvianRentExchange is ReentrancyGuard {

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    
    
    address private _marketOwner;
    uint256 private _listingFee = .01 ether;
    uint64 private _maxInstallments = 10;

    struct Listing_rent {
        address owner;
        address user;
        address nftContract;
        uint256 tokenId;
        uint256 pricePerDay;
        uint256 expires; // when the user can no longer rent it
    }

    // events for nft rentals

    event NFTListed(
        address indexed owner,
        address indexed user,
        address indexed nftContract,
        uint256 tokenId,
        uint256 pricePerDay,
        uint256 expires
    );
    event NFTRented(
        address indexed owner,
        address indexed user,
        address indexed nftContract,
        uint256 tokenId,
        uint64 expires,
        uint256 rentalFee
    );
    event NFTUnlisted(
        address indexed unlistSender,
        address indexed nftContract,
        uint256 indexed tokenId
    );

    // mapping for basics

    mapping(address => mapping(uint256 => Listing_rent)) private r_listings;   // Holds the erc 4907 for rent listings _listingMap 

    mapping(address => EnumerableSet.UintSet) private r_address_tokens; // maps rent nft contracts to set of the tokens that are listed

    EnumerableSet.AddressSet private r_address; // tracks the rent nft contracts that have been listed

    Counters.Counter private r_listed;

    modifier notRListed( // Modifier to check whether a given erc4907 token is not listed or not
        address nftAddress,
        uint256 tokenId
    ) {
        Listing_rent memory listing = r_listings[nftAddress][tokenId];
        if (listing.pricePerDay > 0) {
            revert AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isRListed(address nftAddress, uint256 tokenId) {
        Listing_rent memory listing = r_listings[nftAddress][tokenId];
        if (listing.pricePerDay <= 0) {
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

    constructor() {
        _marketOwner = msg.sender;
    }

    // Listing Functionality

    function listNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 pricePerDay
    ) public payable 
        nonReentrant 
        notRListed(nftAddress, tokenId)
    {
        require(isRentableNFT(nftAddress), "Contract is not an ERC4907");
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender, "Not owner of nft");
        require(msg.value == _listingFee, "Not enough ether for listing fee");
        require(pricePerDay > 0, "Rental price should be greater than 0");

        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NotApprovedForMarketplace();
        }

        payable(_marketOwner).transfer(_listingFee);

        r_listings[nftAddress][tokenId] = Listing_rent(
            msg.sender,
            address(0),
            nftAddress,
            tokenId,
            pricePerDay,
            0
        );

        r_listed.increment();
        EnumerableSet.add(r_address_tokens[nftAddress], tokenId);
        EnumerableSet.add(r_address, nftAddress);
        
        emit NFTListed(
            IERC721(nftAddress).ownerOf(tokenId),
            address(0),
            nftAddress,
            tokenId,
            pricePerDay,
            0
        );
    }


    // Unlisting functionality

    function unlistNFT(                                 // for erc4907 listings
        address nftAddress, 
        uint256 tokenId
    ) public payable 
        nonReentrant 
        isOwner(nftAddress, tokenId, msg.sender)
        isRListed(nftAddress, tokenId)
    { 
        EnumerableSet.remove(r_address_tokens[nftAddress], tokenId);

        delete r_listings[nftAddress][tokenId];

        if (EnumerableSet.length(r_address_tokens[nftAddress]) == 0) {
            EnumerableSet.remove(r_address, nftAddress);
        }
        r_listed.decrement();

        emit NFTUnlisted(
            msg.sender,
            nftAddress,
            tokenId
        );
    }

    function getARListing(        // Get a specific r_listing
        address nftAddress, 
        uint256 tokenId
    ) external view
        returns (Listing_rent memory)
    {
        return r_listings[nftAddress][tokenId];
    }

    function getRentListings(
    ) public view 
        returns (Listing_rent[] memory) 
    {
        Listing_rent[] memory listings = new Listing_rent[](r_listed.current());
        uint256 listingsIndex = 0;
        address[] memory nftContracts = EnumerableSet.values(r_address);

        for (uint i = 0; i < nftContracts.length; i++) {
            address nftAddress = nftContracts[i];
            uint256[] memory tokens = EnumerableSet.values(r_address_tokens[nftAddress]);
            for (uint j = 0; j < tokens.length; j++) {
                listings[listingsIndex] = r_listings[nftAddress][tokens[j]];
                listingsIndex++;
            }
        }
        return listings;
    }

    function getListingFee(
    ) public view 
        returns (uint256) 
    {
        return _listingFee;
    }

    function getRListedAdddresses(
    ) public view 
        returns (address[] memory) 
    {
        address[] memory nftContracts = EnumerableSet.values(r_address);
        return nftContracts;
    }

    function getRListedAdddressTokens(
        address nftAddress
    ) public view 
        returns (uint256[] memory) 
    {
        uint256[] memory tokens = EnumerableSet.values(r_address_tokens[nftAddress]);
        return tokens;
    }


    // start of the rental functions

    function rentNFT(
        address nftContract,
        uint256 tokenId,
        uint64 numDays
    ) public payable 
        nonReentrant 
    {
        require(numDays <= _maxInstallments, "Maximum of 10 rental days are allowed");
        Listing_rent storage listing = r_listings[nftContract][tokenId];
        require(listing.user == address(0) || block.timestamp > listing.expires, "NFT already rented");

        uint64 expires = uint64(block.timestamp) + (numDays*86400);
    
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
            expires,
            rentalFee
        );
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

    function isNFT(address nftContract) public view returns (bool) {
        bool _isNFT = false;

        try IERC165(nftContract).supportsInterface(type(IERC721).interfaceId) returns (bool nft) {
            _isNFT = nft;
        } catch {
            return false;
        }
        return _isNFT;
    }
}