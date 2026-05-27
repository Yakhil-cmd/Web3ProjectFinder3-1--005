// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IVersion
 *
 * @author The Haven1 Development Team
 *
 * @notice Provides a method for retrieving a contract's semantic version.
 *
 * @dev The version is expected to be encoded as a `uint64` using the format:
 * `[32-bit major | 16-bit minor | 16-bit patch]`.
 *
 * See the `Semver` library for encoding, decoding, and comparison functions.
 */
interface IVersion {
    /**
     * @notice Returns the semantic version of the contract.
     *
     * @return A `uint64` representing the encoded semantic version.
     *
     * @dev The version should be encoded using the `Semver.encode` function.
     */
    function version() external view returns (uint64);

    /**
     * @notice Returns the decoded (human readable) semantic version of the contract.
     *
     * @return The major version.
     * @return The minor version.
     * @return The patch version.
     *
     * @dev The version should be decoded using the `Semver.decode` function.
     */
    function versionDecoded() external view returns (uint32, uint16, uint16);
}
