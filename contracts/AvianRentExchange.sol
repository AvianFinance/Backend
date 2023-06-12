// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "./IERC4907.sol";

error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error ItemNotForSale(address nftAddress, uint256 tokenId);
error NotListed(address nftAddress, uint256 tokenId);
error AlreadyListed(address nftAddress, uint256 tokenId);
error NoProceeds();
error NotOwner();
error NotApprovedForMarketplace();
error PriceMustBeAboveZero();

contract AvianRentExchange is ReentrancyGuard {
    
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

    address private marketOwner;

    uint256 private _listingFee = .01 ether;

    uint64 private _maxInstallments = 10;

    mapping(address => mapping(uint256 => Listing_rent)) private r_listings;

    mapping(address => EnumerableSet.UintSet) private r_address_tokens;

    EnumerableSet.AddressSet private r_address;

    constructor() {
        marketOwner = msg.sender;
    }

    // Listing Functionality

    function listNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external payable 
        nonReentrant 
        notRListed(nftAddress, tokenId)
    returns (string memory) {
        require(MarketplaceIsApproved(nftAddress, tokenId),"Marketplace is not aproved");
        require(isRentableNFT(nftAddress), "Contract is not an ERC4907");
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender, "Not owner of nft");
        require(msg.value == _listingFee, "Not enough ether for listing fee");
        require(price > 0, "Price should be greater than 0");

        payable(marketOwner).transfer(_listingFee);

        r_listings[nftAddress][tokenId] = Listing_rent(
            msg.sender,
            address(0),
            nftAddress,
            tokenId,
            price,
            0
        );

        EnumerableSet.add(r_address_tokens[nftAddress], tokenId);
        EnumerableSet.add(r_address, nftAddress);
        
        emit NFTListed(
            IERC721(nftAddress).ownerOf(tokenId),
            address(0),
            nftAddress,
            tokenId,
            price,
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
        uint256 price
    ) external
        nonReentrant 
        isRListed(nftAddress, tokenId)
    returns (string memory) {
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender, "Not owner of nft");
        require(price > 0, "Price should be greater than 0");

        Listing_rent storage listing = r_listings[nftAddress][tokenId];

        listing.pricePerDay = price;

        emit NFTListed(
            listing.owner,
            listing.user,
            nftAddress,
            tokenId,
            price,
            listing.expires
        );

        return("NFT Successfully listed");
    }

    // rental functionality

    function rentNFT(
        address nftAddress,
        uint256 tokenId,
        uint64 numDays
    ) external payable 
        nonReentrant 
        isRListed(nftAddress, tokenId)
    returns(string memory) {
        require(MarketplaceIsApproved(nftAddress, tokenId),"Marketplace is not aproved");
        require(numDays <= _maxInstallments, "Maximum of 10 rental days are allowed");
        require(isNotRented(nftAddress, tokenId), "NFT Already rented");

        Listing_rent storage listing = r_listings[nftAddress][tokenId];
    
        uint256 rentalFee = listing.pricePerDay * numDays;
        require(msg.value >= rentalFee, "Not enough ether to cover rental period");

        uint64 expires = uint64(block.timestamp) + (numDays*86400);

        // Update listing
        IERC4907(nftAddress).setUser(tokenId, msg.sender, expires);
        listing.user = msg.sender;
        listing.expires = expires;

        payable(listing.owner).transfer(rentalFee);

        EnumerableSet.remove(r_address_tokens[nftAddress], tokenId);
        delete r_listings[nftAddress][tokenId];
        if (EnumerableSet.length(r_address_tokens[nftAddress]) == 0) {
            EnumerableSet.remove(r_address, nftAddress);
        }

        emit NFTRented(
            IERC721(nftAddress).ownerOf(tokenId),
            msg.sender,
            nftAddress,
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

    function MarketplaceIsApproved(address nftAddress, uint256 tokenId) internal view returns (bool) {
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            return false;
        } else {
            return true;
        }
    }

    function isNotRented(address nftAddress, uint256 tokenId) internal view returns (bool) {
        if (isRentableNFT(nftAddress)){
            IERC4907 nft = IERC4907(nftAddress);
            uint256 expiry = nft.userExpires(tokenId);
            if (block.timestamp < expiry) {
                return false;
            } else {
                return true;
            }
        } else {
            return true;
        }
    }
}