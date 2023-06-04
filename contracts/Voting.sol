// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

error NotOwner();

contract FunctionVoting {
    struct VotingProposal {
        address contractAddress;
        uint256 voter1;
        uint256 voter2;
    }

    mapping(address => VotingProposal) private votingProposals;
    mapping(address => mapping(address => bool)) private hasVoted;

    address private _marketOwner;
    address private voter1;
    address private voter2;
    
    modifier hasNotVoted(address contractAddress) {
        require(!hasVoted[msg.sender][contractAddress], "You have already voted on this proposal");
        _;
    }

    modifier isOwner(
        address owneraddess
    ) {
        if (_marketOwner != owneraddess) {
            revert NotOwner();
        }
        _;
    }

    // modifier onlyAuthorized(uint256 proposalId) {
    //     require(votingProposals[proposalId].isAuthorized, "Function change is not authorized");
    //     _;
    // }

    constructor(address address1, address address2) {
        _marketOwner = msg.sender;
        voter1 = address1;
        voter2 = address2;
    }

    function createVotingProposal(
        address contractAddress
    ) external 
        isOwner(msg.sender) {

        VotingProposal memory newProposal = VotingProposal(
            contractAddress,
            0,
            0
        );
        votingProposals[contractAddress] = newProposal;
    }

    function voteOnProposal(
        address contractAddress, 
        bool supportChanges
    ) external 
        hasNotVoted(contractAddress) {

        VotingProposal storage proposal = votingProposals[contractAddress];
        require((msg.sender != voter1 || msg.sender != voter2), "Not authorized to vote");

        if (supportChanges) {
            if (msg.sender == voter1) {
                proposal.voter1 = 1;
            } else {
                proposal.voter2 = 1;
            }
        } else {
            if (msg.sender == voter1) {
                proposal.voter1 = 2;
            } else {
                proposal.voter2 = 2;
            }
        }
        hasVoted[msg.sender][contractAddress] = true;
    }

    function calculateVotingResult(
        address contractAddress
    ) public 
        view 
        returns (uint256) {
        VotingProposal memory proposal = votingProposals[contractAddress];
        uint256 totalVotes = proposal.voter1 + proposal.voter2;

        if (totalVotes == 0) {
            return 0; // Proposal has no votes
        } else if (proposal.voter1 == 1 && proposal.voter2 == 1) {
            return 0; // Proposal is authorized
        } else if (proposal.voter1 == 2 && proposal.voter2 == 2) {
            return 2; // Proposal is not authorized
        } else {
            return 1; // Voting result is inconclusive
        }
    }
}