// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IAccount} from "@AA/interfaces/IAccount.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IEntryPoint} from "@AA/interfaces/IEntryPoint.sol";
import {PackedUserOperation} from "@AA/interfaces/PackedUserOperation.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_SUCCESS, SIG_VALIDATION_FAILED} from "@AA/core/Helpers.sol";

/**
 * @title MinimalAccount
 * @author ArefXV
 * @notice A minimal implementation of an Account Abstraction contract.
 * @dev This contract adheres to the IAccount interface and enables user operations
 *      via an EntryPoint contract. It incorporates security checks and owner-based controls.
 */

contract MinimalAccount is IAccount, Ownable {
    /*/////////////////////////////////////////////////////////////////
                                  ERRORS
    /////////////////////////////////////////////////////////////////*/
    error MinimalAccount__NotFromEntryPoint();
    error MinimalAccount__NotFromEntryPointOrOwner();
    error MinimalAccount__CallFailed(bytes);

    /*/////////////////////////////////////////////////////////////////
                            STATE VARIABLES
    /////////////////////////////////////////////////////////////////*/

    /**
     * @notice Address of the EntryPoint contract associated with this account.
     * @dev This is immutable and set at the time of contract deployment.
     */
    IEntryPoint private immutable i_entryPoint;

    /*/////////////////////////////////////////////////////////////////
                                MODIFIERS
    /////////////////////////////////////////////////////////////////*/

    /**
     * @dev Ensures that the caller is the EntryPoint contract.
     */
    modifier requireFromEntryPoint() {
        if (msg.sender != address(i_entryPoint)) {
            revert MinimalAccount__NotFromEntryPoint();
        }
        _;
    }

     /**
     * @dev Ensures that the caller is either the EntryPoint contract or the owner.
     */
    modifier requireFromEntryPointOrOwner() {
        if (msg.sender != address(i_entryPoint) && msg.sender != owner()) {
            revert MinimalAccount__NotFromEntryPointOrOwner();
        }
        _;
    }

    /*/////////////////////////////////////////////////////////////////
                                FUNCTIONS
    /////////////////////////////////////////////////////////////////*/

    /**
     * @param entryPoint The address of the EntryPoint contract.
     * @dev Initializes the contract with the provided EntryPoint and sets the deployer as the owner.
     */
    constructor(address entryPoint) Ownable(msg.sender) {
        i_entryPoint = IEntryPoint(entryPoint);
    }

    receive() external payable {}

    /*/////////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    /////////////////////////////////////////////////////////////////*/

    /**
     * @notice Executes a transaction from this account.
     * @param dest The destination address for the transaction.
     * @param value The amount of Ether to send.
     * @param funcData The data payload of the transaction.
     * @dev Can only be called by the EntryPoint or the owner.
     */
    function execute(address dest, uint256 value, bytes calldata funcData) external requireFromEntryPointOrOwner {
        (bool success, bytes memory result) = dest.call{value: value}(funcData);
        if (!success) {
            revert MinimalAccount__CallFailed(result);
        }
    }

     /**
     * @notice Validates a user operation and pre-funds the account if necessary.
     * @param userOp The packed user operation.
     * @param userOpHash The hash of the user operation.
     * @param missingAccountFunds The amount required to pre-fund the account.
     * @return validationData A status code indicating whether the signature is valid.
     * @dev Can only be called by the EntryPoint.
     */
    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        requireFromEntryPoint
        returns (uint256 validationData)
    {
        validationData = _validateSignature(userOp, userOpHash);
        _payPrefund(missingAccountFunds);
    }

    /*/////////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    /////////////////////////////////////////////////////////////////*/

     /**
     * @notice Validates the signature of the user operation.
     * @param userOp The packed user operation.
     * @param userOpHash The hash of the user operation.
     * @return validationData A status code indicating whether the signature is valid.
     */
    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256 validationData)
    {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);
        if (signer != owner()) {
            return SIG_VALIDATION_FAILED;
        }
        return SIG_VALIDATION_SUCCESS;
    }

    /**
     * @notice Transfers missing funds to the EntryPoint for pre-funding.
     * @param missingAccountFunds The amount required to pre-fund the account.
     */
    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success,) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint256).max}("");
            (success);
        }
    }

    /*/////////////////////////////////////////////////////////////////
                                GETTERS
    /////////////////////////////////////////////////////////////////*/


    /**
     * @return The address of the EntryPoint contract associated with this account.
     */
    function getEntryPoint() external view returns (address) {
        return address(i_entryPoint);
    }
}
