// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Semver
 *
 * @author The Haven1 Development Team
 *
 * @notice Provides utilities for encoding, decoding, and comparing semantic versions.
 *
 * @dev Uses a `uint64` to store version numbers in a compact format: (major, minor, patch).
 */
library Semver {
    /**
     * @notice Encodes a semantic version into a compact `uint64` format.
     *
     * @param major The major version (32 bits).
     * @param minor The minor version (16 bits).
     * @param patch The patch version (16 bits).
     *
     * @return A `uint64` representing the encoded version.
     *
     * @dev The version is packed as `[32-bit major | 16-bit minor | 16-bit patch]`.
     */
    function encode(
        uint32 major,
        uint16 minor,
        uint16 patch
    ) internal pure returns (uint64) {
        return (uint64(major) << 32) | (uint64(minor) << 16) | uint64(patch);
    }

    /**
     * @notice Decodes a `uint64`-encoded version into its major, minor, and patch components.
     *
     * @param version The `uint64`-encoded version.
     *
     * @return major The major version (32 bits).
     * @return minor The minor version (16 bits).
     * @return patch The patch version (16 bits).
     */
    function decode(
        uint64 version
    ) internal pure returns (uint32 major, uint16 minor, uint16 patch) {
        major = uint32(version >> 32);
        minor = uint16(version >> 16);
        patch = uint16(version);
    }

    /**
     * @notice Compares two `uint64`-encoded versions to check if the first is
     * at least the second.
     *
     * @param version   The version to check.
     * @param required  The minimum required version.
     *
     * @return `true` if `version` is greater than or equal to `required`, otherwise `false`.
     *
     * @dev This function allows checking for minimum required versions.
     */
    function isAtLeast(
        uint64 version,
        uint64 required
    ) internal pure returns (bool) {
        return version >= required;
    }

    /**
     * @notice Checks if two versions have the same major version.
     *
     * @param version   The version to check.
     * @param expected  The expected version.
     *
     * @return `true` if `version` and `expected` have the same major version, otherwise `false`.
     *
     * @dev This helps detect breaking changes.
     */
    function hasCompatibleMajorVersion(
        uint64 version,
        uint64 expected
    ) internal pure returns (bool) {
        return (version >> 32) == (expected >> 32);
    }
}
