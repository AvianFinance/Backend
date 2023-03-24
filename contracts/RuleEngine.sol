// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


contract RuleEngine {

    uint256 private rule = 40;
    address private _approved;

    constructor(address admin){
        _approved = admin;
    }

    function getRule(
    ) public view 
        returns (uint256) 
    {
        return rule;
    }

    function updateRule(uint256 new_rule) external {
        require(msg.sender==_approved,"only approved user can change rules");
        rule = new_rule;
    }
}

// Function to be implemented in each proxy contract

    // function upgrade_rules() public{
    //     require(msg.sender==_marketowner,"Only the market owner can upgade");
    //     (bool success, bytes memory data) = _rules.staticcall(abi.encodeWithSignature("getRule()"));
    //     require(success, "transaction failed");
    //     (uint256 insVal) = abi.decode(data, (uint256));
    //     cond = insVal;
    // }

