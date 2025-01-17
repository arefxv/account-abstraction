# AccountAb-straction: A Minimal Account Abstraction Solution Supporting Ethereum and zkSync

This repository implements a robust and secure account abstraction contract designed for Ethereum and zkSync networks. Built with the Foundry framework, it leverages modularity and efficiency to handle user operations effectively.

## Features
* **cross-Network Compatibility**: Supports Ethereum and zkSync for seamless interoperability.
* **Modular Design**: Utilizes Foundry libraries and OpenZeppelin utilities for security and extensibility.
* **Account Abstraction**: Adheres to EIP-4337 to enable flexible user operations.
* **Security**: Incorporates signature validation, owner-based controls, and secure fund transfers.

## Contract Overview

### MinimalAccount.sol

* Implements account abstraction for Ethereum.
* Allows external calls, user operation validation, and pre-funding.
* Ensures secure interaction with the EntryPoint contract.

### ZkMinimalAccount.sol

* Extends account abstraction functionality for zkSync.
* Handles transaction validation, execution, and bootloader interactions.
* Ensures compliance with zkSync's lifecycle for type 113 transactions.

## Quick Start

1. Clone the Repository

```
git clone https://github.com/arefxv/account-abstraction
cd account-abstraction
```

2. Install Dependencies Ensure you have Foundry installed. Then, install the necessary packages:

```
foundryup
forge install eth-infinitism/account-abstraction@v0.7.0 --no-commit
forge install openzeppelin/openzeppelin-contracts@v5.0.2 --no-commit
forge install Cyfrin/foundry-devops --no-commit
forge install Cyfrin/foundry-era-contracts@v0.0.3 --no-commit
```

3. Compile the Contracts

```

forge build

```

4. Run Tests

```
forge test
```

## zkSync Foundry

```
foundryup-zksync
forge zkbuild
forge zktest
```

___
# Thank you for checking it out!# account-abstraction
