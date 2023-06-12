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

contract AvianSellExchange is ReentrancyGuard {

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    struct Listing_sell {
        address owner;
        address nftContract;
        uint256 tokenId;
        uint256 price;
    }

    // events for the basic buy/sell functions

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

    // modifiers for marketplace checks

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

    // state variables to match as in the proxy context (order should be maintained)

    address private marketOwner;

    uint256 private _listingFee = .01 ether;

    mapping(address => mapping(uint256 => Listing_sell)) private s_listings;   

    mapping(address => uint256) private s_proceeds;
    
    mapping(address => EnumerableSet.UintSet) private s_address_tokens; 

    EnumerableSet.AddressSet private s_address; 

    constructor() {
        marketOwner = msg.sender;
    }

    // Listing Functionality

    function listItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external
        notSListed(nftAddress, tokenId)
    returns(string memory){
        require(MarketplaceIsApproved(nftAddress, tokenId),"Marketplace is not aproved");
        require(isNFT(nftAddress), "Contract is not an ERC721");
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender, "Not owner of nft");
        require(price > 0, "listing price should be greater than 0");

        s_listings[nftAddress][tokenId] = Listing_sell(msg.sender,nftAddress,tokenId,price);

        EnumerableSet.add(s_address_tokens[nftAddress], tokenId);
        EnumerableSet.add(s_address, nftAddress);

        emit ItemListed(msg.sender, nftAddress, tokenId, price);

        return("NFT Listed successfully for upright selling");
    }

    // Unlisting functionality

    function cancelListing(                           
        address nftAddress, 
        uint256 tokenId
    ) external
        isOwner(nftAddress, tokenId, msg.sender)
        isSListed(nftAddress, tokenId)
    returns(string memory){
        delete s_listings[nftAddress][tokenId];
        EnumerableSet.remove(s_address_tokens[nftAddress], tokenId);
        if (EnumerableSet.length(s_address_tokens[nftAddress]) == 0) {
            EnumerableSet.remove(s_address, nftAddress);
        }

        emit ItemCanceled(msg.sender, nftAddress, tokenId);
        return("NFT unlisted successfully");
    }


    // Buying and selling functionality

    function buyItem(
        address nftAddress, 
        uint256 tokenId
    ) external payable
        isSListed(nftAddress, tokenId)
        nonReentrant
    returns(string memory){
        require(MarketplaceIsApproved(nftAddress, tokenId),"Marketplace is not aproved");
        require(isNotRented(nftAddress, tokenId), "NFT Already rented");

        Listing_sell memory listedItem = s_listings[nftAddress][tokenId];
        if (msg.value < listedItem.price) {
            revert PriceNotMet(nftAddress, tokenId, listedItem.price);
        }
        s_proceeds[listedItem.owner] += msg.value;

        delete s_listings[nftAddress][tokenId];

        EnumerableSet.remove(s_address_tokens[nftAddress], tokenId);

        if (EnumerableSet.length(s_address_tokens[nftAddress]) == 0) {
            EnumerableSet.remove(s_address, nftAddress);
        }

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

    // function to check whether a given address, token id pair represent a valid nft

    function isNFT(address nftContract) public view returns (bool) {
        bool _isNFT = false;

        try IERC165(nftContract).supportsInterface(type(IERC721).interfaceId) returns (bool nft) {
            _isNFT = nft;
        } catch {
            return false;
        }
        return _isNFT;
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