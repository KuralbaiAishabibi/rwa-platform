// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {GovernanceToken} from "../src/tokens/GovernanceToken.sol";
import {RWATimelock} from "../src/governance/RWATimelock.sol";
import {RWAGovernor} from "../src/governance/RWAGovernor.sol";

contract DeployGovernance is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(pk);
        
        vm.startBroadcast(pk);
        
        GovernanceToken token = new GovernanceToken(deployer, 1_000_000e18);
        
        address[] memory proposers = new address[](1);
        proposers[0] = deployer;
        address[] memory executors = new address[](1);
        executors[0] = deployer;
        
        RWATimelock timelock = new RWATimelock(172800, proposers, executors, deployer);
        
        RWAGovernor governor = new RWAGovernor(
            token,
            timelock,
            6570,
            46000,
            10_000e18,
            4
        );
        
        token.transferOwnership(address(timelock));
        
        vm.stopBroadcast();
        
        console.log("=== Governance Deployed ===");
        console.log("Token:", address(token));
        console.log("Timelock:", address(timelock));
        console.log("Governor:", address(governor));
    }
}
