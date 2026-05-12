// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {RwaYieldVault} from "../vault/RwaYieldVault.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VaultFactory {
    event VaultCreated(address indexed vault, address indexed asset, uint256 salt);

    function createVault(ERC20 asset, address owner) external returns (RwaYieldVault) {
        RwaYieldVault vault = new RwaYieldVault(asset, owner);
        emit VaultCreated(address(vault), address(asset), 0);
        return vault;
    }

    function createVaultWithSalt(ERC20 asset, address owner, uint256 salt) external returns (RwaYieldVault) {
        bytes memory bytecode = type(RwaYieldVault).creationCode;
        address vaultAddr;
        assembly {
            vaultAddr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            if iszero(vaultAddr) { revert(0, 0) }
        }
        RwaYieldVault vault = RwaYieldVault(vaultAddr);
        emit VaultCreated(address(vault), address(asset), salt);
        return vault;
    }

    function predictAddress(ERC20 asset, address owner, uint256 salt) public view returns (address) {
        bytes memory bytecode = type(RwaYieldVault).creationCode;
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode)));
        return address(uint160(uint256(hash)));
    }
}
