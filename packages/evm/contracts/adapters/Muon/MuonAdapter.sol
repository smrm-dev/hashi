// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

import { BlockHashOracleAdapter } from "../BlockHashOracleAdapter.sol";

contract MuonAdapter is BlockHashOracleAdapter {

    error ArrayLengthMissmatch(address emitter);

    constructor() { }

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
