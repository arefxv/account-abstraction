// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {EntryPoint} from "@AA/core/EntryPoint.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract CodeConstants {
    address public constant BURNER_WALLET = 0x4D49400f047E66f72699C31F25483d8039B0351d;
    address public constant SEPOLIA_ETH_ENTRYPOINT = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;
    address public constant SEPOLIA_ETH_USDC_ADDRESS = 0x53844F9577C2334e541Aec7Df7174ECe5dF1fCf0;
    address public constant ETH_MAINNET_ENTRYPOINT = 0x0000000071727De22E5E9d8BAf0edAc6f37da032;
    address public constant ETH_MAINNET_USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant ARBITRUM_MAINNET_ENTRYPOINT = 0x0000000071727De22E5E9d8BAf0edAc6f37da032;
    address public constant ARBITRUM_MAINNET_USDC_ADDRESS = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address public constant ZKSYNC_MAINNET_USDC_ADDRESS = 0x1d17CBcF0D6D143135aE902365D2E5e2A16538D4;
    address public constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
    uint256 public constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 public constant SEPOLIA_ETH_CHAIN_ID = 11155111;
    uint256 public constant ARBITRUM_MAINNET_CHAIN_ID = 42_161;
    uint256 public constant ZKSYNC_MAINNET_CHAIN_ID = 324;
}

contract HelperConfig is Script, CodeConstants {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error HelperConfig__InvalidChainId();

    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    struct NetworkConfig {
        address entryPoint;
        address usdc;
        address account;
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    constructor() {
        networkConfigs[ETH_MAINNET_CHAIN_ID] = getEthMainnetConfig();
        networkConfigs[SEPOLIA_ETH_CHAIN_ID] = getSepoliaEthConfig();
        networkConfigs[ARBITRUM_MAINNET_CHAIN_ID] = getArbitrumMainnetConfig();
        networkConfigs[ZKSYNC_MAINNET_CHAIN_ID] = getZksyncMainnetConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilConfig();
        } else if (networkConfigs[chainId].account != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    /*//////////////////////////////////////////////////////////////
                                CONFIGS
    //////////////////////////////////////////////////////////////*/

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({entryPoint: SEPOLIA_ETH_ENTRYPOINT, usdc: SEPOLIA_ETH_USDC_ADDRESS, account: BURNER_WALLET});
    }

    function getEthMainnetConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({entryPoint: ETH_MAINNET_ENTRYPOINT, usdc: ETH_MAINNET_USDC_ADDRESS, account: BURNER_WALLET});
    }

    function getArbitrumMainnetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: ARBITRUM_MAINNET_ENTRYPOINT,
            usdc: ARBITRUM_MAINNET_USDC_ADDRESS,
            account: BURNER_WALLET
        });
    }

    function getZksyncSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: address(0),
            usdc: 0x5A7d6b2F92C77FAD6CCaBd7EE0624E64907Eaf3E,
            account: BURNER_WALLET
        });
    }

    function getZksyncMainnetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: address(0), usdc: ZKSYNC_MAINNET_USDC_ADDRESS, account: BURNER_WALLET});
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.account != address(0)) {
            return localNetworkConfig;
        }

        vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);
        EntryPoint entryPoint = new EntryPoint();
        ERC20Mock usdc = new ERC20Mock();
        vm.stopBroadcast();

        localNetworkConfig =
            NetworkConfig({entryPoint: address(entryPoint), usdc: address(usdc), account: ANVIL_DEFAULT_ACCOUNT});

        return localNetworkConfig;
    }
}
