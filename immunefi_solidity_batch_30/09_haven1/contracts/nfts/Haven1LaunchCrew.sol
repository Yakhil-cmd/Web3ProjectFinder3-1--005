// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { NetworkGuardian } from "../network-guardian/NetworkGuardian.sol";
import { Address } from "../utils/Address.sol";
import { IVersion } from "../utils/interfaces/IVersion.sol";
import { Semver } from "../utils/Semver.sol";

contract Haven1LaunchCrew is ERC721Upgradeable, NetworkGuardian, IVersion {
    /* TYPE DECLARATIONS
    ==================================================*/

    using Address for address;

    /* STATE
    ==================================================*/

    /**
     * @dev The current version of the contract, packed into a uint64 as:
     * `[32-bit major | 16-bit minor | 16-bit patch]`.
     */
    uint64 private constant VERSION = uint64(0x0100000000); // Semver.encode(1, 0, 0)

    /**
     * @dev Indicates the current total supply. Must be incremented _before_
     * minting a new NFT.
     */
    uint256 private _totalSupply;

    /**
     * @dev The token URI. All NFTs issued by this contract will have the same
     * URI.
     */
    string private _uri;

    /* EVENTS
    ==================================================*/
    /**
     * @notice Emitted when then token URI is set.
     *
     * @param uri The new URI.
     */
    event URISet(string uri);

    /* ERRORS
    ==================================================*/
    error InvalidURI();
    error AlreadyMinted(address recipient);

    /* FUNCTIONS
    ==================================================*/

    /* Constructor
    ========================================*/

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /* Init
    ========================================*/

    /**
     * @notice Initializes the contract.
     *
     * @param association           The Haven1 Association address.
     * @param guardianController    The Network Guardian Controller address.
     * @param uri                   The token URI.
     *
     * @dev Requirements:
     * -    The provided addresses cannot be the zero address.
     * -    The Token URI must not be of length zero.
     */
    function initialize(
        address association,
        address guardianController,
        string memory uri
    ) external initializer {
        association.assertNotZero();
        guardianController.assertNotZero();

        if (bytes(uri).length == 0) {
            revert InvalidURI();
        }

        __NetworkGuardian_init(association, guardianController);
        __ERC721_init("Haven1 Launch Crew", "MOON");
        _uri = uri;
    }

    /* External
    ========================================*/

    /**
     * @notice Mints an NFT to the recipient.
     *
     * @param recipient The recipient of the NFT.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: DEFAULT_ADMIN_ROLE
     * -    Not callable when paused.
     * -    Cannot mint to the zero address or an address that already has a balance.
     */
    function mint(
        address recipient
    ) external whenNotGuardianPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        _mintNFT(recipient, ++_totalSupply);
    }

    /**
     * @notice Mints an NFT to each recipient.
     *
     * @param recipients An array of recipients.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: DEFAULT_ADMIN_ROLE
     * -    Not callable when paused.
     * -    Cannot mint to the zero address or an address that already has a balance.
     */
    function mintBatch(
        address[] memory recipients
    ) external whenNotGuardianPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 n = recipients.length;
        uint256 id = _totalSupply;

        for (uint256 i; i < n; ) {
            _mintNFT(recipients[i], ++id);

            unchecked {
                i++;
            }
        }

        _totalSupply = id;
    }

    /**
     * @notice Sets the Token URI.
     *
     * @param uri The new Token URI.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: DEFAULT_ADMIN_ROLE
     * -    Not callable when paused.
     * -    The Token URI must not be of length zero.
     *
     * Emits a `URISet` event.
     */
    function setURI(
        string memory uri
    ) external whenNotGuardianPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        if (bytes(uri).length == 0) {
            revert InvalidURI();
        }

        _uri = uri;
        emit URISet(uri);
    }

    /**
     * @notice Returns the current total supply.
     *
     * @return The current total supply.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @inheritdoc IVersion
     */
    function version() external pure returns (uint64) {
        return VERSION;
    }

    /**
     * @inheritdoc IVersion
     */
    function versionDecoded() external pure returns (uint32, uint16, uint16) {
        return Semver.decode(VERSION);
    }

    /* Public
    ========================================*/

    /**
     * @notice Returns the URI for a given token ID.
     *
     * @param tokenId The ID of the token for which the URI is retrieved.
     *
     * @return The URI for a given token ID.
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        return _baseURI();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721Upgradeable, NetworkGuardian) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /* Internal
    ========================================*/

    function _baseURI() internal view virtual override returns (string memory) {
        return _uri;
    }

    /* Private
    ========================================*/

    function _mintNFT(address recipient, uint256 id) private {
        recipient.assertNotZero();
        if (balanceOf(recipient) != 0) {
            revert AlreadyMinted(recipient);
        }

        _safeMint(recipient, id);
    }
}
