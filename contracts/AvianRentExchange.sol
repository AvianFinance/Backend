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

    struct Listing_rent {
        address owner;
        address user;
        address nftContract;
        uint256 tokenId;
        uint256 pricePerDay;
        uint256 expires;
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

    // modifiers for the marketplace

    modifier notRListed(
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

    // state variables to match as in the proxy context (order should be maintained)

    address private _marketOwner;

    uint256 private _listingFee = .01 ether;

    uint64 private _maxInstallments = 10;

    mapping(address => mapping(uint256 => Listing_rent)) private r_listings;

    mapping(address => EnumerableSet.UintSet) private r_address_tokens;

    EnumerableSet.AddressSet private r_address;

    Counters.Counter private r_listed;

    constructor() {
        _marketOwner = msg.sender;
    }

    // Listing Functionality

    function listNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 pricePerDay
    ) external payable 
        nonReentrant 
        notRListed(nftAddress, tokenId)
    returns (string memory) {
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

        return("NFT Successfully listed");
    }


    // Unlisting functionality

    function unlistNFT(                          
        address nftAddress, 
        uint256 tokenId
    ) external
        nonReentrant 
        isOwner(nftAddress, tokenId, msg.sender)
        isRListed(nftAddress, tokenId)
    returns (string memory) { 
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

        return("NFT Successfully unlisted");
    }

    // List updating Functionality

    function updateRentNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 pricePerDay
    ) external
        nonReentrant 
        isRListed(nftAddress, tokenId)
    returns (string memory) {
        require(isRentableNFT(nftAddress), "Contract is not an ERC4907");
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender, "Not owner of nft");
        require(pricePerDay > 0, "Rental price should be greater than 0");

        Listing_rent storage listing = r_listings[nftAddress][tokenId];

        listing.pricePerDay = pricePerDay;

        emit NFTListed(
            listing.owner,
            listing.user,
            nftAddress,
            tokenId,
            pricePerDay,
            listing.expires
        );

        return("NFT Successfully listed");
    }

    // rental functionality

    function rentNFT(
        address nftContract,
        uint256 tokenId,
        uint64 numDays
    ) external payable 
        nonReentrant 
    returns(string memory) {
        require(numDays <= _maxInstallments, "Maximum of 10 rental days are allowed");

        Listing_rent storage listing = r_listings[nftContract][tokenId];
        require(listing.user == address(0) || block.timestamp > listing.expires, "NFT already rented");

        IERC721 nft = IERC721(nftContract);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NotApprovedForMarketplace();
        }

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

        return("NFT successfully rented");
    }

    // functions to check whether a given address, token id pair represent a valid nft

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