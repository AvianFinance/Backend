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


contract AIE_Proxy is ReentrancyGuard {

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    struct Listing_installment { 
        address owner;
        address user;
        address nftContract;
        uint256 tokenId;
        uint256 pricePerDay;
        uint64 installmentCount;
        uint64 expires;
        uint64 installmentIndex;
        uint256 paidIns;
    }

    struct VotingProposal {
        address contractAddress;
        uint256 voter1;
        uint256 voter2;
    }

    // events for nft rentals

    event INSNFTListed(
        address indexed owner,
        address indexed user,
        address indexed nftContract,
        uint256 tokenId,
        uint256 pricePerDay
    );

    event NFTINSPaid(
        address indexed owner,
        address indexed user,
        address indexed nftContract,
        uint256 tokenId,
        uint64 expires,
        uint64 insCount,
        uint64 insIndex,
        uint256 insAmount,
        uint256 totalPaid
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

    modifier notIListed(
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

    modifier isOwnerContract(
        address owneraddess
    ) {
        if (_marketOwner != owneraddess) {
            revert NotOwner();
        }
        _;
    }

    // State Variables for the proxy

    address private _marketOwner;

    uint256 private _listingFee = .01 ether;

    uint64 private _maxInstallments = 10;

    mapping(address => mapping(uint256 => Listing_installment)) private i_listings;   

    mapping(address => EnumerableSet.UintSet) private i_address_tokens;

    EnumerableSet.AddressSet private i_address; 

    Counters.Counter private i_listed;

    address private impl_installment;

    VotingProposal private pendingContract;

    address private voter1;

    address private voter2;

    constructor(address _implContract, address address1, address address2) {
        _marketOwner = msg.sender;
        impl_installment = _implContract;
        voter1 = address1;
        voter2 = address2;
    }

    // listing functionality

    function listInsBasedNFT( 
        address nftAddress,
        uint256 tokenId,
        uint256 pricePerDay
    ) public payable returns(string memory) {
        (bool success, bytes memory data) = impl_installment.delegatecall(abi.encodeWithSignature("listInsBasedNFT(address,uint256,uint256)", nftAddress, tokenId, pricePerDay));
        require(success, "transaction failed");
        return(abi.decode(data, (string)));
    }


    // Unlisting functionality

    function unlistINSNFT(                              
        address nftAddress, 
        uint256 tokenId
    ) public returns(string memory){ 
        (bool success, bytes memory data) = impl_installment.delegatecall(abi.encodeWithSignature("unlistINSNFT(address,uint256)", nftAddress, tokenId));
        require(success, "transaction failed");
        return(abi.decode(data, (string)));
    }

    // renting functionality

    function rentINSNFT(
        address nftAddress,
        uint256 tokenId,
        uint64 numDays
    ) public payable returns(string memory){
        (bool success, bytes memory data) = impl_installment.delegatecall(abi.encodeWithSignature("rentINSNFT(address,uint256,uint64)", nftAddress, tokenId, numDays));
        require(success, "transaction failed");
        return(abi.decode(data, (string)));
    }

    // get the next installment

    function getNftInstallment(
        address nftAddress,
        uint256 tokenId,
        uint64 installmentCount
    ) public view returns (uint256) {
        require(installmentCount<=_maxInstallments,"installment count must me less than the maximum allowed installments");
        require(installmentCount>0,"installment count must be greater than 1");
        Listing_installment storage listing = i_listings[nftAddress][tokenId];

        uint64 currIndex = listing.installmentIndex;
        uint64 nextIndex = currIndex + 1;

        if (listing.installmentCount>0){
            installmentCount = listing.installmentCount;
            require(nextIndex<=installmentCount,"NFT fully paid");
        }

        (bool success, bytes memory data) = impl_installment.staticcall(abi.encodeWithSignature("calculateInstallment(uint256,uint256,uint256,uint64)", listing.paidIns, installmentCount, listing.pricePerDay, nextIndex));
        require(success, "transaction failed");
        return(abi.decode(data, (uint256)));
    }

    // installment payment

    function payNFTIns(
        address nftAddress,
        uint256 tokenId
    ) public payable returns(string memory){
        (bool success, bytes memory data) = impl_installment.delegatecall(abi.encodeWithSignature("payNFTIns(address,uint256)", nftAddress, tokenId));
        require(success, "transaction failed");
        return(abi.decode(data, (string)));
    }

    // Get an individual listing

    function getAInsListing(        
        address nftAddress, 
        uint256 tokenId
    ) external view returns (Listing_installment memory){
        return i_listings[nftAddress][tokenId];
    }

    //  get the addresses listed for rentals

    function getInsListedAdddresses(
    ) public view returns (address[] memory) {
        address[] memory nftContracts = EnumerableSet.values(i_address);
        return nftContracts;
    }

    // get the token ids under a given address which are listed

    function getInsListedAdddressTokens(
        address nftAddress
    ) public view returns (uint256[] memory) {
        uint256[] memory tokens = EnumerableSet.values(i_address_tokens[nftAddress]);
        return tokens;
    }

    // get the listing fee

    function getListingFee(
    ) public view 
        returns (uint256) 
    {
        return _listingFee;
    }

    // service functions

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

    function createVotingProposal(
        address cAddress
    ) external 
        isOwnerContract(msg.sender) 
    {
        pendingContract.contractAddress = cAddress;
        pendingContract.voter1 = 0;
        pendingContract.voter2 = 0;
    }

    function voteOnProposal(
        bool supportChanges
    ) external 
        hasNotVoted() 
    {
        require((msg.sender == voter1 || msg.sender == voter2), "Not authorized to vote");

        if (supportChanges) {
            if (msg.sender == voter1) {
                pendingContract.voter1 = 2;
            } else {
                pendingContract.voter2 = 2;
            }
        } else {
            if (msg.sender == voter1) {
                pendingContract.voter1 = 1;
            } else {
                pendingContract.voter2 = 1;
            }
        }
    }

    function calculateVotingResult() public 
        view 
        returns (uint256) 
    {
        uint256 totalVotes = pendingContract.voter1 + pendingContract.voter2;

        if (totalVotes == 0) {
            return 0; // Proposal has no votes
        } else if (pendingContract.voter1 == 1 && pendingContract.voter2 == 1) {
            return 0; // Proposal is authorized
        } else if (pendingContract.voter1 == 2 && pendingContract.voter2 == 2) {
            return 2; // Proposal is not authorized
        } else {
            return 1; // Voting result is inconclusive
        }
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

    // Implementation upgrade logic

    function updateImplContract() external
        nonReentrant
    {
        require(msg.sender == _marketOwner, "marketplace can only be upgraded by the owner");
        require(pendingContract.voter1 != 0 && pendingContract.voter2 != 0, "Voters have not completed voting");
        require(pendingContract.voter1 ==2 && pendingContract.voter2 == 2, "Voters have not agreed on the proposal");
        
        impl_installment = pendingContract.contractAddress;
        emit ImplUpgrade(
            _marketOwner,
            impl_installment
        );
    }

    function getImplAddrs(
    ) public view 
        returns (address) 
    {
        return impl_installment;
    }
}