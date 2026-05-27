// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title IDistributor
 *
 * @author The Haven1 Development Team
 */
interface IDistributor {
    /**
     * @notice Emitted when a reward distribution occurred.
     *
     * @param to        The address of the recipient.
     * @param token     The address of the token that was distributed.
     * @param amount    The amount that was distributed.
     */
    event RewardsDistributed(
        address indexed to,
        address indexed token,
        uint256 amount
    );

    /**
     * @dev Distributes tokens or assets according to the implemented logic.
     */
    function distribute() external;
}
