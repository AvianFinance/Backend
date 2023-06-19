// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "./IERC4907.sol";

error NotListed(address nftAddress, uint256 tokenId);
error AlreadyListed(address nftAddress, uint256 tokenId);
error NotOwner();

contract AvianRentExchange is ReentrancyGuard {
    
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    struct Listing_rent {address owner;address user;address nftContract;uint256 tokenId;uint256 pricePerDay;uint256 expires;}

	event RentNftListed(address indexed owner,address indexed user,address indexed nftContract,uint256 tokenId,uint256 pricePerDay,uint256 expires);
	event RentNftRented(address indexed owner,address indexed user,address indexed nftContract,uint256 tokenId,uint64 expires,uint256 rentalFee);
	event RentNftUnlisted(address indexed unlistSender,address indexed nftContract,uint256 indexed tokenId);

    modifier notRentListed(address nftAddress, uint256 tokenId) {
        Listing_rent memory listing = r_listings[nftAddress][tokenId];
        if (listing.pricePerDay > 0) {
            revert AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isRentListed(address nftAddress, uint256 tokenId) {
        Listing_rent memory listing = r_listings[nftAddress][tokenId];
        if (listing.pricePerDay <= 0) {
            revert NotListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isOwner(address nftAddress, uint256 tokenId, address spender) {
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


    function listNFT(address nftAddress, uint256 tokenId, uint256 price) external payable 
        nonReentrant 
        notRentListed(nftAddress, tokenId)
    returns(string memory){
        require(MarketplaceIsApproved(nftAddress, tokenId),'Marketplace is not aproved');
        require(isRentableNFT(nftAddress),'Contract is not an ERC4907');
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender,'Not owner of nft');
        require(price > 0,'Price should be greater than 0');

        require(msg.value >= _listingFee,'Not enough ether for payment');
        payable(marketOwner).transfer(_listingFee);

        r_listings[nftAddress][tokenId] = Listing_rent(msg.sender,address(0),nftAddress,tokenId,price,0);
        EnumerableSet.add(r_address_tokens[nftAddress],tokenId);
        EnumerableSet.add(r_address,nftAddress);
        
        emit RentNftListed(IERC721(nftAddress).ownerOf(tokenId), address(0), nftAddress, tokenId, price, 0);

        return('NFT Successfully listed');
    }

    function unlistNFT(address nftAddress, uint256 tokenId) external
        nonReentrant 
        isOwner(nftAddress, tokenId, msg.sender)
        isRentListed(nftAddress, tokenId)
    returns(string memory){ 

        EnumerableSet.remove(r_address_tokens[nftAddress],tokenId);
        delete r_listings[nftAddress][tokenId];
        if (EnumerableSet.length(r_address_tokens[nftAddress]) == 0) {
            EnumerableSet.remove(r_address,nftAddress);
        }

        emit RentNftUnlisted(msg.sender,nftAddress,tokenId);

        return('NFT Successfully unlisted');
    }

    function updateRentNFT(address nftAddress, uint256 tokenId, uint256 price) external
        nonReentrant 
        isRentListed(nftAddress, tokenId)
    returns(string memory){
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender,'Not owner of nft');
        require(price > 0,'Price should be greater than 0');

        Listing_rent storage listing = r_listings[nftAddress][tokenId];
        listing.pricePerDay = price;

        emit RentNftListed(listing.owner, listing.user, nftAddress, tokenId, price, listing.expires);

        return('NFT Successfully listed');
    }

    function rentNFT(address nftAddress, uint256 tokenId, uint64 numDays) external payable 
        nonReentrant 
        isRentListed(nftAddress, tokenId)
    returns(string memory){
        require(MarketplaceIsApproved(nftAddress, tokenId),'Marketplace is not aproved');
        require(numDays <= _maxInstallments,'Maximum of 10 rental days are allowed');
        require(isNotRented(nftAddress, tokenId),'NFT Already rented');

        Listing_rent memory listing = r_listings[nftAddress][tokenId];
    
        uint256 rentalFee = listing.pricePerDay * numDays;
        uint64 expires = uint64(block.timestamp) + (numDays*86400);
        IERC4907(nftAddress).setUser(tokenId, msg.sender, expires);
        listing.user = msg.sender;
        listing.expires = expires;

        require(msg.value >= rentalFee,'Not enough ether for payment');
        payable(listing.owner).transfer(rentalFee);

        EnumerableSet.remove(r_address_tokens[nftAddress],tokenId);
        delete r_listings[nftAddress][tokenId];
        if (EnumerableSet.length(r_address_tokens[nftAddress]) == 0) {
            EnumerableSet.remove(r_address,nftAddress);
        }

        emit RentNftRented(IERC721(nftAddress).ownerOf(tokenId), msg.sender, nftAddress, tokenId, expires, rentalFee);

        return('NFT successfully rented');
    }

    function isRentableNFT(address nftContract) public view 
    returns(bool){

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
        return(_isRentable && _isNFT);
    }

    function isNFT(address nftContract) public view 
    returns(bool){

        bool _isNFT = false;
        try IERC165(nftContract).supportsInterface(type(IERC721).interfaceId) returns (bool nft) {
            _isNFT = nft;
        } catch {
            return false;
        }
        return(_isNFT);
    }

    function MarketplaceIsApproved(address nftAddress, uint256 tokenId) internal view 
    returns(bool){

        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            return false;
        } else {
            return true;
        }

    }

    function isNotRented(address nftAddress, uint256 tokenId) internal view 
    returns(bool){

        if (isRentableNFT(nftAddress)){
            IERC4907 nft = IERC4907(nftAddress);
            uint256 expiry = nft.userExpires(tokenId);
            if (block.timestamp < expiry){
                return false;
            } else {
                return true;
            }
        } else {
            return true;
        }

    }

    
}