// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {AssetToken} from "../src/tokens/AssetToken.sol";
import {AssetCertificate} from "../src/tokens/AssetCertificate.sol";
import {RwaYieldVault} from "../src/vault/RwaYieldVault.sol";
import {ChainlinkPriceOracle} from "../src/oracles/ChainlinkPriceOracle.sol";
import {RwaLendingPool} from "../src/lending/RwaLendingPool.sol";
import {VaultFactory} from "../src/factories/VaultFactory.sol";
import {MockERC20} from "../test/vault/MockERC20.sol";

contract DeployCore is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(pk);

        vm.startBroadcast(pk);

        AssetToken rwaToken = new AssetToken("Real World Asset", "RWA", deployer);
        AssetCertificate cert = new AssetCertificate(deployer);
        MockERC20 stable = new MockERC20("Stable USD", "SUSD");
        ChainlinkPriceOracle oracle = new ChainlinkPriceOracle(deployer);

        RwaLendingPool lending = new RwaLendingPool();
        lending.initialize(address(stable), address(oracle), deployer);

        RwaYieldVault vault = new RwaYieldVault(stable, deployer);
        VaultFactory factory = new VaultFactory();

        vm.stopBroadcast();

        console.log("=== Core Contracts Deployed ===");
        console.log("AssetToken:", address(rwaToken));
        console.log("Certificate:", address(cert));
        console.log("Stablecoin:", address(stable));
        console.log("Oracle:", address(oracle));
        console.log("LendingPool:", address(lending));
        console.log("Vault:", address(vault));
        console.log("Factory:", address(factory));
    }
}
