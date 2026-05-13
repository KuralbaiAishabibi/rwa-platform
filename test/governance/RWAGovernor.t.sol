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
        governor = new RWAGovernor(
            token,
            timelock,
            1,
            10,
            10_000e18,
            4
        );

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));

        vm.prank(owner);
        token.transfer(voter, 100_000e18);
        vm.prank(voter);
        token.delegate(voter);
        vm.roll(block.number + 1);
    }

    function testParameters() public view {
        assertEq(governor.votingDelay(), 1);
        assertEq(governor.votingPeriod(), 10);
        assertEq(governor.proposalThreshold(), 10_000e18);
    }

    function testProposalCreation() public {
        address[] memory targets = new address[](1);
        targets[0] = address(token);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSelector(token.transfer.selector, owner, 1000e18);
        string memory description = "Transfer tokens";

        vm.prank(voter);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        vm.roll(block.number + 2);
        assertEq(uint256(governor.state(proposalId)), uint256(1));
    }
}
