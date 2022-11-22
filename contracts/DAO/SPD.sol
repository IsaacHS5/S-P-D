// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

contract SPD is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl {
        
    constructor(IVotes _votesAddr, TimelockController _timeLockAddr)
    Governor("SPD")
    GovernorSettings(1 /* 1 block */, 28800 /* 4 days */, 0)
    GovernorVotes(_votesAddr)
    GovernorVotesQuorumFraction(4)
    GovernorTimelockControl(_timeLockAddr) {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool) {
            
        return super.supportsInterface(interfaceId);
    }

    function votingDelay() public view override(IGovernor, GovernorSettings) returns (uint256) {
        return super.votingDelay();
    }

    function votingPeriod() public view override(IGovernor, GovernorSettings) returns (uint256) {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function state(uint256 _proposalId) public view override(Governor, GovernorTimelockControl) returns (ProposalState) {
        return super.state(_proposalId);
    }

    function propose(
        address[] memory _targets, 
        uint256[] memory _values, 
        bytes[] memory _calldatas,
        string memory description
        ) 
        public override(Governor, IGovernor) returns (uint256) {

            return super.propose(_targets, _values, _calldatas, description);
    }

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256) {

        return super.proposalThreshold();
    }    

    function _execute(
        uint256 _proposalId, 
        address[] memory _targets, 
        uint256[] memory _values, 
        bytes[] memory _calldatas, 
        bytes32 _descriptionHash
        )
        internal
        override(Governor, GovernorTimelockControl) {

        super._execute(_proposalId, _targets, _values, _calldatas, _descriptionHash);
    }

    function _cancel(
        address[] memory _targets, 
        uint256[] memory _values, 
        bytes[] memory _calldatas, 
        bytes32 _descriptionHash
        )
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256) {

        return super._cancel(_targets, _values, _calldatas, _descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address) {

        return super._executor();
    }

}
