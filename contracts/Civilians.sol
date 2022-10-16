// SPDX-License-Identifier: UNLICENSED

pragma solidity  ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

interface IRulers {
    function balanceOf(address _addr) external view returns (uint256);
}

contract Civilians is ERC721Enumerable, AccessControl {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    using Strings for uint256;

    struct Civilian {
        string name;
        uint256 id;
        uint256 sP;
        bool dead;
        address suspicius;
    }

    uint256 public maxSupply;
    bool public isMintingActive = false;
    string public baseExtension = ".json";
    string private baseURI;
    address private rulersTokenAddr;
    uint256[] public civilianStatePsychopath = [80, 99, 100, 120, 160, 199, 200];
    mapping(uint256 => Civilian) public tokenIdToCivilian;

    constructor(
        string memory _contractName,
        string memory _contractSymbol,
        uint256 _setMaxSupply,
        address _rulersTokenAddr
    )
    ERC721(_contractName, _contractSymbol) {
        maxSupply = _setMaxSupply;
        rulersTokenAddr = _rulersTokenAddr;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function flipIsMintingActive() external onlyRole(DEFAULT_ADMIN_ROLE) {
        
        isMintingActive = !isMintingActive;
    }

    function updateBaseURI(string memory _baseURI) external onlyRole(DEFAULT_ADMIN_ROLE) {

        baseURI = _baseURI;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns(string memory _tokenURI) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");

        return bytes(baseURI).length > 0 ?
           string(abi.encodePacked(baseURI, _tokenId.toString(), baseExtension)) : "";
    }

    function mint() external {
        require(maxSupply > totalSupply(), "Error, sold out!");
        require(isMintingActive == true, "Error, minting is not active");
        require(balanceOf(msg.sender) == 0, "Error, you can't mint more tokens");
        require(IRulers(rulersTokenAddr).balanceOf(msg.sender) >= 1, "Error, you're not a ruler");
        
        uint256 _amount = 5;

        for(uint256 _nfts; _nfts < _amount; _nfts++) {
            uint256 newTokenId = _tokenIds.current();
            tokenIdToCivilian[newTokenId].sP = civilianStatePsychopath[0];
            _safeMint(msg.sender, newTokenId);
            _tokenIds.increment();
            console.log("NFT w/ ID %s has been minted to %s", newTokenId, msg.sender);

        }

    }

    function increaseCivilianSP(uint256 _tokenId) external {
        require(_exists(_tokenId), "Error, token doesn't exist");
        require(tokenIdToCivilian[_tokenId].sP != civilianStatePsychopath[6], "Error, token SP at his limit!");

        if(IRulers(rulersTokenAddr).balanceOf(msg.sender) >= 1) {
            bool isFound = false;
            while(isFound == false) {
                uint256 _index = 0;
                if(tokenIdToCivilian[_tokenId].sP == civilianStatePsychopath[_index]) {
                    _index++;
                    tokenIdToCivilian[_tokenId].sP = civilianStatePsychopath[_index];
    
                } else {
                    _index++;
                }
           }
        }
        
    }

    function withdraw() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(address(this).balance > 0, "Error, the contract is empty");

        payable(msg.sender).transfer(address(this).balance);
    }
}