// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {GovernanceToken} from "../../src/tokens/GovernanceToken.sol";
import {RWATimelock} from "../../src/governance/RWATimelock.sol";
import {RWAGovernor} from "../../src/governance/RWAGovernor.sol";

contract RWAGovernorTest is Test {
    GovernanceToken token;
    RWATimelock timelock;
    RWAGovernor governor;

    address owner = makeAddr("owner");
    address voter = makeAddr("voter");
    address voter2 = makeAddr("voter2");
    uint256 constant INITIAL_SUPPLY = 1_000_000e18;

    function setUp() public {
        vm.prank(owner);
        token = new GovernanceToken(owner, INITIAL_SUPPLY);

        address[] memory proposers = new address[](1);
        proposers[0] = address(this);
        address[] memory executors = new address[](1);
        executors[0] = address(this);
        
        vm.prank(owner);
        timelock = new RWATimelock(1, proposers, executors, address(this));

        vm.prank(owner);
        governor = new RWAGovernor(token, timelock, 1, 50, 1e18, 4);

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));

        vm.prank(owner);
        token.transfer(voter, 500_000e18);
        vm.prank(voter);
        token.delegate(voter);

        vm.prank(owner);
        token.transfer(voter2, 100_000e18);
        vm.prank(voter2);
        token.delegate(voter2);

        vm.roll(block.number + 1);
    }

    function testParameters() public view {
        assertEq(governor.votingDelay(), 1);
        assertEq(governor.votingPeriod(), 50);
    }

    function testProposalCreation() public {
        address[] memory targets = new address[](1);
        targets[0] = address(token);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSelector(token.transfer.selector, voter2, 1000e18);
        string memory description = "Transfer tokens";

        vm.prank(voter);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        vm.roll(block.number + 2);
        assertEq(uint256(governor.state(proposalId)), uint256(1));
    }

    function testVoting() public {
        address[] memory targets = new address[](1);
        targets[0] = address(token);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSelector(token.transfer.selector, voter2, 1000e18);

        vm.prank(voter);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Test");
        vm.roll(block.number + 2);

        vm.prank(voter);
        governor.castVote(proposalId, 1);
        vm.prank(voter2);
        governor.castVote(proposalId, 1);

        vm.roll(block.number + 51);
        assertEq(uint256(governor.state(proposalId)), uint256(4));
    }

    function testProposeAndQueue() public {
        address[] memory targets = new address[](1);
        targets[0] = address(token);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSelector(token.transfer.selector, voter2, 10e18);

        vm.prank(voter);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Queue test");
        vm.roll(block.number + 2);

        vm.prank(voter);
        governor.castVote(proposalId, 1);

        vm.roll(block.number + 51);

        bytes32 descriptionHash = keccak256(abi.encodePacked("Queue test"));
        governor.queue(targets, values, calldatas, descriptionHash);

        assertEq(uint256(governor.state(proposalId)), uint256(5));
    }
}
