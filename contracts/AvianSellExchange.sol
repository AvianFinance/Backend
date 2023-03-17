// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error ItemNotForSale(address nftAddress, uint256 tokenId);
error NotListed(address nftAddress, uint256 tokenId);
error AlreadyListed(address nftAddress, uint256 tokenId);
error NoProceeds();
error NotOwner();
error NotApprovedForMarketplace();
error PriceMustBeAboveZero();


contract AvianSellExchange is ReentrancyGuard {

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    struct Listing_sell {
        address owner;
        address nftContract;
        uint256 tokenId;
        uint256 price;
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

    modifier notSListed( 
        address nftAddress,
        uint256 tokenId
    ) {
        Listing_sell memory listing = s_listings[nftAddress][tokenId];
        if (listing.price > 0) {
            revert AlreadyListed(nftAddress, tokenId);
        }
        _;
    }


    modifier isSListed(address nftAddress, uint256 tokenId) {
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


    // mapping for basics

    address private _marketOwner;

    uint256 private _listingFee = .01 ether;

    mapping(address => mapping(uint256 => Listing_sell)) private s_listings;   // Holds the erc 721 for basic listings
 
    mapping(address => uint256) private s_proceeds;
    
    mapping(address => EnumerableSet.UintSet) private s_address_tokens; // maps buy sell nft contracts to set of the tokens that are listed

    EnumerableSet.AddressSet private s_address; // tracks the rent nft contracts that have been listed

    Counters.Counter private s_listed;

    constructor() {
        _marketOwner = msg.sender;
    }

    // Listing Functionality

    function listItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external
        notSListed(nftAddress, tokenId)
    returns(string memory){
        require(isNFT(nftAddress), "Contract is not an ERC721");
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender, "Not owner of nft");
        require(price > 0, "listing price should be greater than 0");

        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NotApprovedForMarketplace();
        }

        s_listings[nftAddress][tokenId] = Listing_sell(msg.sender,nftAddress,tokenId,price);

        s_listed.increment();
        EnumerableSet.add(s_address_tokens[nftAddress], tokenId);
        EnumerableSet.add(s_address, nftAddress);

        emit ItemListed(msg.sender, nftAddress, tokenId, price);

        return("NFT Listed successfully for upright selling");
    }


    // Unlisting functionality

    function cancelListing(                             // For erc721 listings
        address nftAddress, 
        uint256 tokenId
    ) external
        isOwner(nftAddress, tokenId, msg.sender)
        isSListed(nftAddress, tokenId)
    {
        delete s_listings[nftAddress][tokenId];

        EnumerableSet.remove(s_address_tokens[nftAddress], tokenId);

        if (EnumerableSet.length(s_address_tokens[nftAddress]) == 0) {
            EnumerableSet.remove(s_address, nftAddress);
        }
        s_listed.decrement();

        emit ItemCanceled(msg.sender, nftAddress, tokenId);
    }


    // Buying and selling functionality

    function buyItem(           // Buy a nft listed in the s_listings map
        address nftAddress, 
        uint256 tokenId
    ) external payable
        isSListed(nftAddress, tokenId)
        nonReentrant
    returns(string memory){
        Listing_sell memory listedItem = s_listings[nftAddress][tokenId];
        if (msg.value < listedItem.price) {
            revert PriceNotMet(nftAddress, tokenId, listedItem.price);
        }
        s_proceeds[listedItem.owner] += msg.value; // https://fravoll.github.io/solidity-patterns/pull_over_push.html

        delete s_listings[nftAddress][tokenId];

        EnumerableSet.remove(s_address_tokens[nftAddress], tokenId);

        if (EnumerableSet.length(s_address_tokens[nftAddress]) == 0) {
            EnumerableSet.remove(s_address, nftAddress);
        }
        s_listed.decrement();

        IERC721(nftAddress).safeTransferFrom(listedItem.owner, msg.sender, tokenId);
        emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
        return("NFT successfully Bought");
    }

    // Update already listed listings

    function updateListing(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
    ) external
        isSListed(nftAddress, tokenId)
        nonReentrant
        isOwner(nftAddress, tokenId, msg.sender)
    returns(string memory){
        require(newPrice > 0, "listing price should be greater than 0");

        s_listings[nftAddress][tokenId].price = newPrice;

        emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);

        return("Successfully updated the listing");
    }

    // Withdraw Proceeds in the pull pattern. Used when multiple transactions are made within a single function

    function withdrawProceeds() external returns(string memory){
        uint256 proceeds = s_proceeds[msg.sender];
        if (proceeds <= 0) {
            revert NoProceeds();
        }
        s_proceeds[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: proceeds}("");
        require(success, "Transfer failed");

        return("Successfully transferred the proceeds");
    }

    // Getter Functions

    function getASListing(        // Get a specific s_listing
        address nftAddress, 
        uint256 tokenId
    ) external view
        returns (Listing_sell memory)
    {
        return s_listings[nftAddress][tokenId];
    }


    function getProceeds(       // Get the proceeds available for a seller
        address seller
    ) external view 
        returns (uint256) 
    {
        return s_proceeds[seller];
    }

    function getSellListings(
    ) public view 
        returns (Listing_sell[] memory) 
    {
        Listing_sell[] memory listings = new Listing_sell[](s_listed.current());
        uint256 listingsIndex = 0;
        address[] memory nftContracts = EnumerableSet.values(s_address);

        for (uint i = 0; i < nftContracts.length; i++) {
            address nftAddress = nftContracts[i];
            uint256[] memory tokens = EnumerableSet.values(s_address_tokens[nftAddress]);
            for (uint j = 0; j < tokens.length; j++) {
                listings[listingsIndex] = s_listings[nftAddress][tokens[j]];
                listingsIndex++;
            }
        }
        return listings;
    }

    function getSListedAdddresses(
    ) public view 
        returns (address[] memory) 
    {
        address[] memory nftContracts = EnumerableSet.values(s_address);
        return nftContracts;
    }

    function getSListedAdddressTokens(
        address nftAddress
    ) public view 
        returns (uint256[] memory) 
    {
        uint256[] memory tokens = EnumerableSet.values(s_address_tokens[nftAddress]);
        return tokens;
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