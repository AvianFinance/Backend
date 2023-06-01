// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract FunctionVoting is Ownable {
    struct VotingProposal {
        uint256 proposalId;
        address functionAddress;
        string proposedChanges;
        uint256 votingStart;
        uint256 votingEnd;
        uint256 forVotes;
        uint256 againstVotes;
        bool isAuthorized;
    }

    uint256 private proposalIdCounter;
    mapping(uint256 => VotingProposal) private votingProposals;
    mapping(address => mapping(uint256 => bool)) private hasVoted;

    modifier hasNotVoted(uint256 proposalId) {
        require(!hasVoted[msg.sender][proposalId], "You have already voted on this proposal");
        _;
    }

    modifier onlyAuthorized(uint256 proposalId) {
        require(votingProposals[proposalId].isAuthorized, "Function change is not authorized");
        _;
    }

    function createVotingProposal(address functionAddress, string memory proposedChanges, uint256 votingDuration) external onlyOwner returns (uint256) {
        uint256 newProposalId = proposalIdCounter++;
        uint256 votingStart = block.timestamp;
        uint256 votingEnd = votingStart + votingDuration;

        VotingProposal memory newProposal = VotingProposal(
            newProposalId,
            functionAddress,
            proposedChanges,
            votingStart,
            votingEnd,
            0,
            0,
            false
        );

        votingProposals[newProposalId] = newProposal;

        return newProposalId;
    }

    function voteOnProposal(uint256 proposalId, bool supportChanges) external hasNotVoted(proposalId) {
        VotingProposal storage proposal = votingProposals[proposalId];
        require(block.timestamp >= proposal.votingStart && block.timestamp <= proposal.votingEnd, "Voting period has ended");

        if (supportChanges) {
            proposal.forVotes++;
        } else {
            proposal.againstVotes++;
        }

        hasVoted[msg.sender][proposalId] = true;
    }

    function calculateVotingResult(uint256 proposalId) public view returns (bool) {
        VotingProposal memory proposal = votingProposals[proposalId];
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes;

        if (totalVotes == 0) {
            return false; // Proposal has no votes
        }

        uint256 majorityThreshold = totalVotes / 2 + 1;

        if (proposal.forVotes >= majorityThreshold) {
            return true; // Proposal is authorized
        } else if (proposal.againstVotes >= majorityThreshold) {
            return false; // Proposal is not authorized
        } else {
            return false; // Voting result is inconclusive
        }
    }

    function authorizeFunctionChange(uint256 proposalId) external onlyOwner {
        bool result = calculateVotingResult(proposalId);
        votingProposals[proposalId].isAuthorized = result;
    }

    // Example function secured by the voting system
    function exampleFunction() external onlyAuthorized(proposalId) {
        // Function logic here
    }
}