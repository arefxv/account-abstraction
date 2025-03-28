// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {MinimalAccount} from "src/ethereum/MinimalAccount.sol";
import {HelperConfig, CodeConstants} from "./HelperConfig.s.sol";

contract DeployMinimalAccount is Script {
    function run() external {
        deployMinimalAccount();
    }

    function deployMinimalAccount() public returns (MinimalAccount, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast(config.account);
        MinimalAccount minimalAccount = new MinimalAccount(config.entryPoint);
        minimalAccount.transferOwnership(config.account);
        vm.stopBroadcast();

        return (minimalAccount, helperConfig);
    }
}
