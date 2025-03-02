// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract WatchCertificate is ERC721Enumerable {

    using Strings for uint256;
    using SafeMath for uint256;

    bool public paused = false;
    address public contractHost; 

    mapping(uint256 tokenId => string tokenURI) private _tokenURIs;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     Events                                 */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    event WatchMinted(address indexed tokenOwner, uint256 indexed _tokenId);
    event WatchUpdated(address indexed tokenOwner, uint256 indexed _tokenId);
    
    constructor(address owner,string memory name,string memory symbol) ERC721(name,symbol) {
        contractHost=owner;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     Modifier                               */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    modifier hostOnly { 
        require(msg.sender == contractHost, "Only host can call this function");
        _;
    }

    /**
     * @notice Mints a new watch NFT to the specified address.
     * @dev The contract must not be paused for this function to execute.
     * @param _to The address of the recipient.
     * @param _tokenURI The metadata URI associated with the NFT.
    */
    function mintWatch(address _to, string memory _tokenURI) public hostOnly {
        require(!paused, "Contract is paused");
        uint256 currentId = totalSupply();
        uint256 mintIndex = currentId + 1;
        _safeMint(_to, mintIndex);
        _setTokenURI(mintIndex, _tokenURI);
        emit WatchMinted(_to, mintIndex);  
    }

    /**
     * @notice Updates the token URI of an existing watch NFT.
     * @dev Ensures that the provided address is the actual owner of the token.
     * @param _to The address of the token owner.
     * @param _tokenId The ID of the NFT to be updated.
     * @param _newTokenURI The new metadata URI.
    */
    function updateWatch(address _to, uint256 _tokenId, string memory _newTokenURI) public hostOnly {
        require(!paused, "Contract is paused");
        require(_to == ownerOf(_tokenId), "Owner of token doesn't match with address");
        _setTokenURI(_tokenId, _newTokenURI);
        emit WatchUpdated(_to, _tokenId);
    }

    // Set tokenURI of watch 
    function _setTokenURI(uint256 _tokenId, string memory _tokenURI) internal virtual {
        _tokenURIs[_tokenId] = _tokenURI;
    }

    /**
     * @notice Pauses or unpauses the contract, stopping or resuming minting.
     * @dev Only the contract host can change the paused state.
    */
    function pause(bool _state) public hostOnly {
        paused = _state;
    }

    /**
     * @notice Only the current host can assign a new host.
    */
    function setContractHost(address newOwner) public hostOnly {
        contractHost = newOwner;
    }

    // Get TokenURI 
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        string memory _uri = _tokenURIs[_tokenId];
        return string(abi.encodePacked(_uri));
    }


} 