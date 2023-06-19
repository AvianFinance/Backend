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

contract AvianInsExchange is ReentrancyGuard {

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

	struct Listing_installment {address owner;address user;address nftContract;uint256 tokenId;uint256 pricePerDay;uint64 installmentCount;uint64 expires;uint64 installmentIndex;uint256 paidIns;}

	event InstNftListed(address indexed owner,address indexed user,address indexed nftContract,uint256 tokenId,uint256 pricePerDay);
	event InstNftInsPaid(address indexed owner,address indexed user,address indexed nftContract,uint256 tokenId,uint64 expires,uint64 insCount,uint64 insIndex,uint256 insAmount);
	event InstNftUnlisted(address indexed unlistSender,address indexed nftContract,uint256 indexed tokenId);

    modifier notInsListed(address nftAddress, uint256 tokenId) {
        Listing_installment memory listing = i_listings[nftAddress][tokenId];
        if (listing.pricePerDay > 0) {
            revert AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isInsListed(address nftAddress, uint256 tokenId) {
        Listing_installment memory listing = i_listings[nftAddress][tokenId];
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

    mapping(address => mapping(uint256 => Listing_installment)) private i_listings;   

    mapping(address => EnumerableSet.UintSet) private i_address_tokens;

    EnumerableSet.AddressSet private i_address; 


    constructor() {
        marketOwner = msg.sender;
    }


    function listInsBasedNFT(address nftAddress, uint256 tokenId, uint256 price) public payable 
        nonReentrant 
        notInsListed(nftAddress, tokenId)
    returns(string memory){
        require(MarketplaceIsApproved(nftAddress, tokenId),'Marketplace is not aproved');
        require(isRentableNFT(nftAddress),'Contract is not an ERC4907');
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender,'Not owner of nft');
        require(price > 0,'Price should be greater than 0');

        require(msg.value >= _listingFee,'Not enough ether for payment');
        payable(marketOwner).transfer(_listingFee);

        i_listings[nftAddress][tokenId] = Listing_installment(msg.sender,address(0),nftAddress,tokenId,price,0,0,0,0);
        EnumerableSet.add(i_address_tokens[nftAddress],tokenId);
        EnumerableSet.add(i_address,nftAddress);
        
        emit InstNftListed(IERC721(nftAddress).ownerOf(tokenId), address(0), nftAddress, tokenId, price);

        return('Successfully listed the NFT for installment based rentals');
    }

    function unlistINSNFT(address nftAddress, uint256 tokenId) public
        isOwner(nftAddress, tokenId, msg.sender)
        isInsListed(nftAddress, tokenId)
    returns(string memory){ 

        EnumerableSet.remove(i_address_tokens[nftAddress],tokenId);
        delete i_listings[nftAddress][tokenId];
        if (EnumerableSet.length(i_address_tokens[nftAddress]) == 0) {
            EnumerableSet.remove(i_address,nftAddress);
        }

        emit InstNftUnlisted(msg.sender, nftAddress, tokenId);

        return('Successfully removed the listing');
    }

    function rentINSNFT(address nftAddress, uint256 tokenId, uint64 numDays) public payable 
        nonReentrant 
    returns(string memory){
        require(MarketplaceIsApproved(nftAddress, tokenId),'Marketplace is not aproved');
        require(isNotRented(nftAddress, tokenId),'NFT Already rented');
        require(numDays <= _maxInstallments,'Maximum of 10 rental days are allowed');
        require(numDays > 1,'Number of installments must be greater than 1');

        Listing_installment memory listing = i_listings[nftAddress][tokenId];

        uint256 rentalFee = calculateInstallment(0,numDays,listing.pricePerDay,1);

        uint64 expires = uint64(block.timestamp) + 86400;
        listing.user = msg.sender;
        listing.expires = expires;
        listing.installmentCount = numDays;
        listing.installmentIndex = 1;
        listing.paidIns = rentalFee;

        IERC4907(nftAddress).setUser(tokenId, msg.sender, expires);

        require(msg.value >= rentalFee,'Not enough ether for payment');
        payable(listing.owner).transfer(rentalFee);

        EnumerableSet.remove(i_address_tokens[nftAddress],tokenId);
        if (EnumerableSet.length(i_address_tokens[nftAddress]) == 0) {
            EnumerableSet.remove(i_address,nftAddress);
        }

        emit InstNftInsPaid(IERC721(nftAddress).ownerOf(tokenId), msg.sender, nftAddress, tokenId, expires, numDays, 1, rentalFee);

        return('Successfully rented the nft by paying the first installment');
    }

    function calculateInstallment(uint256 totalPaid, uint256 installmentCount, uint256 pricePerDay, uint64 installmentIndex) public pure
    returns(uint256){
        require(installmentIndex <= installmentCount,'Installment Index should be lesser than the installment count');
        require(installmentIndex > 0,'Installment Index should be greater than 0');

        uint256 rentalFee = pricePerDay*installmentCount;
        uint256 installment_amount;
        uint sum = (installmentCount*(installmentCount+1))/2;
        uint256 unit_price = rentalFee/sum;
        if (installmentIndex<installmentCount){
            installment_amount = unit_price*(installmentCount - installmentIndex +1);
        } else if (installmentIndex==installmentCount){
            installment_amount = rentalFee - totalPaid;
        }

        return(installment_amount);
    }

    function payNFTIns(address nftAddress, uint256 tokenId) public payable 
        nonReentrant 
    returns(string memory){
        require(MarketplaceIsApproved(nftAddress, tokenId),'Marketplace is not aproved');

        Listing_installment memory listing = i_listings[nftAddress][tokenId];

        require(listing.user == msg.sender,'You are not the current renter');
        require(listing.installmentIndex < listing.installmentCount,'Rental fee is fully paid');
        require(listing.installmentIndex >= 1,'Rental agreement not yet made');
        require(block.timestamp < listing.expires,'NFT expired');

        uint64 expires = listing.expires + 86400;
        uint64 currIndex = listing.installmentIndex;
        uint64 nextIndex = currIndex + 1;
        listing.expires = expires;
        uint256 rentalFee = calculateInstallment(listing.paidIns,listing.installmentCount,listing.pricePerDay,nextIndex);
        uint256 totalPaid = listing.paidIns + rentalFee;
        listing.installmentIndex = nextIndex;
        listing.paidIns = totalPaid;

        require(msg.value >= rentalFee,'Not enough ether for payment');
        payable(listing.owner).transfer(rentalFee);

        IERC4907(nftAddress).setUser(tokenId, msg.sender, expires);

        emit InstNftInsPaid(IERC721(nftAddress).ownerOf(tokenId), msg.sender, nftAddress, tokenId, expires, listing.installmentCount, nextIndex, rentalFee);
        if (listing.installmentIndex == listing.installmentCount){
            delete i_listings[nftAddress][tokenId];
        }

        return('Successfully paid the installment');
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