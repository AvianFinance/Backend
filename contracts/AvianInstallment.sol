
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


contract AvianInstallment is ReentrancyGuard {

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    
    
    address private _marketOwner;
    uint256 private _listingFee = .001 ether;


    struct Listing_installment { 
        address owner;
        address user;
        address nftContract;
        uint256 tokenId;
        uint256 pricePerDay;
        uint64 numDays;
        uint256 startDateUNIX; // when the nft can start being rented
        uint256 endDateUNIX; // when the nft can no longer be rented
        uint256 expires; // when the user can no longer rent it
        uint64 installment_count;
        uint64 installment_index;
    }


    event INSNFTListed(
        address indexed owner,
        address indexed user,
        address indexed nftContract,
        uint256 tokenId,
        uint256 pricePerDay,
        uint256 startDateUNIX,
        uint256 endDateUNIX,
        uint256 expires,
        uint64 installment_count,
        uint64 installment_index
    );

    event NFTINSPaid(
        address indexed owner,
        address indexed user,
        address indexed nftContract,
        uint256 tokenId,
        uint256 startDateUNIX,
        uint256 endDateUNIX,
        uint256 expires,
        uint64 ins_index,
        uint256 amount
    );

    event NFTUnlisted(
        address indexed unlistSender,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 refund
    );

    // mapping for basics

    mapping(address => mapping(uint256 => Listing_installment)) private i_listings;   // Holds the erc 4907 for installment based rentings

    mapping(address => EnumerableSet.UintSet) private i_address_tokens; // maps installment based rent nft contracts to set of the tokens that are listed

    EnumerableSet.AddressSet private i_address; // tracks the ins basede rent nft contracts that have been listed

    Counters.Counter private i_listed;


    modifier notIListed( // Modifier to check whether a given erc4907 token is not listed or not for installment based
        address nftAddress,
        uint256 tokenId
    ) {
        Listing_installment memory listing = i_listings[nftAddress][tokenId];
        if (listing.pricePerDay > 0) {
            revert AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isIListed(address nftAddress, uint256 tokenId) {
        Listing_installment memory listing = i_listings[nftAddress][tokenId];
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

    function listInsBasedNFT( // installment based
        address nftAddress,
        uint256 tokenId,
        uint256 pricePerDay,
        uint256 startDateUNIX,
        uint256 endDateUNIX,
        uint64 installment_count
    ) public payable 
        nonReentrant 
        notIListed(nftAddress, tokenId)
    {
        require(isRentableNFT(nftAddress), "Contract is not an ERC4907");
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender, "Not owner of nft");
        require(msg.value == _listingFee, "Not enough ether for listing fee");
        require(pricePerDay > 0, "Rental price should be greater than 0");
        require(startDateUNIX >= block.timestamp, "Start date cannot be in the past");
        require(endDateUNIX >= startDateUNIX, "End date cannot be before the start date");

        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NotApprovedForMarketplace();
        }

        payable(_marketOwner).transfer(_listingFee);

        i_listings[nftAddress][tokenId] = Listing_installment(
            msg.sender,
            address(0),
            nftAddress,
            tokenId,
            pricePerDay,
            0,
            startDateUNIX,
            endDateUNIX,
            0,
            installment_count,
            0
        );

        i_listed.increment();
        EnumerableSet.add(i_address_tokens[nftAddress], tokenId);
        EnumerableSet.add(i_address, nftAddress);
        
        emit INSNFTListed(
            IERC721(nftAddress).ownerOf(tokenId),
            address(0),
            nftAddress,
            tokenId,
            pricePerDay,
            startDateUNIX,
            endDateUNIX,
            0,
            installment_count,
            0
        );
    }


    // Unlisting functionality

    function unlistINSNFT(                              
        address nftAddress, 
        uint256 tokenId
    ) public payable 
        nonReentrant 
        isOwner(nftAddress, tokenId, msg.sender)
        isIListed(nftAddress, tokenId)
    { 
        uint256 refund = 0;

        // clean up data

        IERC4907(nftAddress).setUser(tokenId, address(0), 0);

        EnumerableSet.remove(i_address_tokens[nftAddress], tokenId);

        delete i_listings[nftAddress][tokenId];

        if (EnumerableSet.length(i_address_tokens[nftAddress]) == 0) {
            EnumerableSet.remove(i_address, nftAddress);
        }
        i_listed.decrement();

        emit NFTUnlisted(
            msg.sender,
            nftAddress,
            tokenId,
            refund
        );
    }


    function getAINSListing(        // Get a specific s_listing
        address nftAddress, 
        uint256 tokenId
    ) external view
        returns (Listing_installment memory)
    {
        return i_listings[nftAddress][tokenId];
    }

    function getListingFee(
    ) public view 
        returns (uint256) 
    {
        return _listingFee;
    }

    function getINSListedAdddresses(
    ) public view 
        returns (address[] memory) 
    {
        address[] memory nftContracts = EnumerableSet.values(i_address);
        return nftContracts;
    }

    function getINSListedAdddressTokens(
        address nftAddress
    ) public view 
        returns (uint256[] memory) 
    {
        uint256[] memory tokens = EnumerableSet.values(i_address_tokens[nftAddress]);
        return tokens;
    }


    // start of the rental functions


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

    //-----------------------------------------

    function rentINSNFT(
        address nftContract,
        uint256 tokenId,
        uint64 numDays
    ) public payable 
        nonReentrant 
    {
        Listing_installment storage listing = i_listings[nftContract][tokenId];
        require(listing.user == address(0) || block.timestamp > listing.expires, "NFT already rented");
        // require(expires <= listing.endDateUNIX, "Rental period exceeds max date rentable");
        // Transfer rental fee

        uint64 expires = uint64(block.timestamp) + 86400;
        uint64 currIndex = listing.installment_index;
        uint64 nextIndex = currIndex + 1;
    
        uint256 rentalFee = listing.pricePerDay*numDays;
        
        uint256 insFee = calculateInstallment(listing.installment_count,rentalFee,nextIndex);

        require(msg.value >= insFee, "Not enough ether to cover rental period");
        payable(listing.owner).transfer(insFee);

        // Update listing
        IERC4907(nftContract).setUser(tokenId, msg.sender, expires);
        listing.user = msg.sender;
        listing.expires = expires;
        listing.numDays = numDays;
        listing.installment_index = nextIndex;

        emit NFTINSPaid(
            IERC721(nftContract).ownerOf(tokenId),
            msg.sender,
            nftContract,
            tokenId,
            listing.startDateUNIX,
            listing.endDateUNIX,
            expires,
            currIndex,
            insFee
        );
    }


    function calculateInstallment(
        uint256 installment_count,
        uint256 rentalFee,
        uint installment_index
    ) public pure
        returns (uint256) 
    {
        require(installment_index <= installment_count, "Installment Index should be lesser than the installment count");
        require(installment_index > 0, "Installment Index should be greater than 0");

        uint256 installment_amount;
        uint sum = 0;

        for (uint i = 1; i <= installment_count; i++) {
            sum = sum + i;
        }
        uint256 unit_price = rentalFee/sum;

        if (installment_index<installment_count){
            installment_amount = unit_price*(installment_count - installment_index +1);
        } else if (installment_index==installment_count){
            installment_amount = rentalFee - (unit_price*(sum-1));
        }

        return installment_amount;
    }

    function getNFTInstallment(
        address nftAddress,
        uint256 tokenId,
        uint64 rentalDays
    ) public view 
        returns (uint256) 
    {
        Listing_installment storage listing = i_listings[nftAddress][tokenId];

        uint64 currIndex = listing.installment_index;
        uint64 nextIndex = currIndex + 1;
    
        uint256 rentalFee = listing.pricePerDay*rentalDays;
        
        uint256 insFee = calculateInstallment(listing.installment_count,rentalFee,nextIndex);

        return insFee;
    }

    function payNFTIns(
        address nftContract,
        uint256 tokenId
    ) public payable 
        nonReentrant 
    {
        Listing_installment storage listing = i_listings[nftContract][tokenId];
        require(listing.user == msg.sender, "You are not the current user");
        require(block.timestamp < listing.expires, "NFT expired");

        uint256 expires = listing.expires + 86400;
        uint64 currIndex = listing.installment_index;
        uint64 nextIndex = currIndex + 1;
    
        uint256 rentalFee = listing.pricePerDay*listing.numDays;
        
        uint256 insFee = calculateInstallment(listing.installment_count,rentalFee,nextIndex);

        require(msg.value >= insFee, "Not enough ether to cover rental period");
        payable(listing.owner).transfer(insFee);

        // Update listing
        listing.expires = expires;
        listing.installment_index = nextIndex;

        emit NFTINSPaid(
            IERC721(nftContract).ownerOf(tokenId),
            msg.sender,
            nftContract,
            tokenId,
            listing.startDateUNIX,
            listing.endDateUNIX,
            expires,
            currIndex,
            insFee
        );
    }

}