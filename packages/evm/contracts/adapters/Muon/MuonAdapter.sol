// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { BlockHashOracleAdapter } from "../BlockHashOracleAdapter.sol";
import { MuonClient } from "./utils/MuonClient.sol";

contract MuonAdapter is BlockHashOracleAdapter, MuonClient {

    using ECDSA for bytes32;

    struct MuonSig{
        bytes reqId;
        SchnorrSign sign;
        bytes gatewaySignature;
    }

    // The apps can run their own gateway and
    // accept the transactions that is started by the gateway.
    address validGateway = msg.sender; // by default

    error ArrayLengthMissmatch(address emitter);

    constructor(
        uint256 _muonAppId,
        PublicKey memory _muonPublicKey
    ) MuonClient(_muonAppId, _muonPublicKey){ }

    // To get the gatewaySignature,
    // gwSign=true should be passed to the
    // MuonApp.
    function verifyTSSAndGateway(
        uint256[] memory ids,
        bytes32[] memory _hashes,
        MuonSig calldata muonSig
    ) public {
        bytes32 hash = keccak256(
            abi.encodePacked(
                muonAppId,
                muonSig.reqId,
                ids,
                _hashes
            )
        );
        bool verified = muonVerify(muonSig.reqId, uint256(hash), muonSig.sign, muonPublicKey);
        require(verified, "TSS not verified");

        hash = hash.toEthSignedMessageHash();
        address gatewaySignatureSigner = hash.recover(muonSig.gatewaySignature);

        require(gatewaySignatureSigner == validGateway, "Gateway is not valid");
    }

    /// @dev Stores the hashes for a given array of idss.
    /// @param ids Array of ids number for which to set the hashes.
    /// @param _hashes Array of hashes to set for the given ids.
    /// @notice Only callable by `amb` with a message passed from `reporter.
    /// @notice Will revert if given array lengths do not match.
    function storeHashes(uint256[] memory ids, bytes32[] memory _hashes) public {
        // TODO: should verify inputs
        if (ids.length != _hashes.length) revert ArrayLengthMissmatch(address(this));
        for (uint256 i = 0; i < ids.length; i++) {
            _storeHash(block.chainid, ids[i], _hashes[i]);
        }
    }
}
