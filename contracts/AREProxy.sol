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

contract ARE_Proxy is ReentrancyGuard {

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

    struct VotingProposal {
        address contractAddress;
        uint8 voter1;
        uint8 voter2;
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

    event ImplUpgrade(
        address indexed marketowner,
        address indexed newImplAddrs
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

    modifier hasNotVoted() {
        if(msg.sender == voter1){
            require(pendingContract.voter1==0, "You have already voted on this proposal");
        } 
        if(msg.sender == voter2){
            require(pendingContract.voter2==0, "You have already voted on this proposal");
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

    modifier isMarketOwner(
        address ownerAddess
    ) {
        if (marketOwner != ownerAddess) {
            revert NotOwner();
        }
        _;
    }

    // State Variables for the proxy

    address private marketOwner;

    uint256 private _listingFee = .01 ether;

    uint64 private _maxInstallments = 10;

    mapping(address => mapping(uint256 => Listing_rent)) private r_listings;  

    mapping(address => EnumerableSet.UintSet) private r_address_tokens; 

    EnumerableSet.AddressSet private r_address;

    address private impl_rent;

    VotingProposal private pendingContract;

    address private voter1;

    address private voter2;

    constructor(address implContract, address address1, address address2) {
        marketOwner = msg.sender;
        impl_rent = implContract;
        voter1 = address1;
        voter2 = address2;
    }

    // Listing Functionality

    function listNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 pricePerDay
    ) public payable returns(string memory) {
        (bool success, bytes memory data) = impl_rent.delegatecall(abi.encodeWithSignature("listNFT(address,uint256,uint256)", nftAddress, tokenId, pricePerDay));
        require(success, "transaction failed");
        return(abi.decode(data, (string)));
    }

    // Unlisting functionality

    function unlistNFT(                        
        address nftAddress, 
        uint256 tokenId
    ) public payable returns(string memory) { 
        (bool success, bytes memory data) = impl_rent.delegatecall(abi.encodeWithSignature("unlistNFT(address,uint256)", nftAddress, tokenId));
        require(success, "transaction failed");
        return(abi.decode(data, (string)));
    }

    // updating functionality

    function updateNFT(                        
        address nftAddress, 
        uint256 tokenId,
        uint256 pricePerDay
    ) public returns(string memory) { 
        (bool success, bytes memory data) = impl_rent.delegatecall(abi.encodeWithSignature("updateRentNFT(address,uint256,uint256)", nftAddress, tokenId, pricePerDay));
        require(success, "transaction failed");
        return(abi.decode(data, (string)));
    }

    // start of the rental functions

    function rentNFT(
        address nftAddress,
        uint256 tokenId,
        uint64 numDays
    ) public payable returns(string memory) {
        (bool success, bytes memory data) = impl_rent.delegatecall(abi.encodeWithSignature("rentNFT(address,uint256,uint64)", nftAddress, tokenId, numDays));
        require(success, "transaction failed");
        return(abi.decode(data, (string)));
    }

    // Get a specific r_listing

    function getARListing(
        address nftAddress, 
        uint256 tokenId
    ) external view
        returns (Listing_rent memory)
    {
        return r_listings[nftAddress][tokenId];
    }

    // get the set of nft addresses listed for renting in the marketplace

    function getRListedAdddresses(
    ) public view 
        returns (address[] memory) 
    {
        address[] memory nftContracts = EnumerableSet.values(r_address);
        return nftContracts;
    }

    // get the set of nft token ids of a given nft address listed for renting

    function getRListedAdddressTokens(
        address nftAddress
    ) public view 
        returns (uint256[] memory) 
    {
        uint256[] memory tokens = EnumerableSet.values(r_address_tokens[nftAddress]);
        return tokens;
    }

    // get the listing fee for rentals

    function getListingFee(
    ) public view 
        returns (uint256) 
    {
        return _listingFee;
    }

    function createVotingProposal(
        address cAddress
    ) external 
        isMarketOwner(msg.sender) 
    {
        pendingContract.contractAddress = cAddress;
        pendingContract.voter1 = 0;
        pendingContract.voter2 = 0;
    }

    function voteOnProposal(bool supportChanges) external 
    {
        require((msg.sender == voter1 || msg.sender == voter2), "Not authorized to vote");

        if (msg.sender == voter1) {
            require(pendingContract.voter1==0, "You have already voted on this proposal");
            pendingContract.voter1 = getResult(supportChanges);
        } else {
            require(pendingContract.voter2==0, "You have already voted on this proposal");
            pendingContract.voter2 = getResult(supportChanges);
        }

    }

    function getResult(bool input) internal pure returns (uint8) {
        if (input) {
            return 2;
        } else {
            return 1;
        }
    }

    function isProposalApproved() public view returns (bool) {
        uint8 totalVotes = pendingContract.voter1 + pendingContract.voter2;

        if (totalVotes == 4) {
            return true;
        } else {
            return false;
        }
    }

    // upgrade functionality
    function updateImplContract() external
        nonReentrant
        isMarketOwner(msg.sender) 
    {
        require(pendingContract.voter1 != 0 && pendingContract.voter2 != 0, "Voters have not completed voting");
        require(pendingContract.voter1 ==2 && pendingContract.voter2 == 2, "Voters have not agreed on the proposal");
        
        impl_rent = pendingContract.contractAddress;

        emit ImplUpgrade(
            marketOwner,
            impl_rent
        );
    }

    function getImplAddrs(
    ) public view 
        returns (address) 
    {
        return impl_rent;
    }

    // functions to check whether a given token is 721 or 4907

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