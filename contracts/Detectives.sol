// SPDX-License-Identifier: UNLICENSED

pragma solidity  ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

interface IRulers {
    function balanceOf(address _addr) external view returns (uint256);
}

contract Detectives is ERC721Enumerable, AccessControl {

    /**
    RANKS:  
    1-Detective I
    2-Detective II
    3-Detective III
    4-Lieutenant
    5-Captain
    6-Commander
    */

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    using Strings for uint256;

    struct Detective {
        uint256 actualRank;
        uint256 sP;
    }

    bytes32 public constant SPD_ROLE = keccak256("SPD_ROLE");

    uint256 public maxSupply;
    uint256 public mintPrice;
    bool public isMintingActive = false;
    string public baseExtension = ".json";
    string private baseURI;
    address private rulersTokenAddr;
    uint256[] public detectiveStatePsychopath = [80, 99, 100, 120, 160, 199, 200];
    mapping(uint256 => Detective) public tokenIdToDetective;

    constructor(
        string memory _contractName,
        string memory _contractSymbol,
        uint256 _setMaxSupply,
        uint256 _setMintPrice,
        address _spdAddr,
        address _rulersTokenAddr
    )
    ERC721(_contractName, _contractSymbol) {
        maxSupply = _setMaxSupply;
        mintPrice = _setMintPrice;
        rulersTokenAddr = _rulersTokenAddr;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(SPD_ROLE, _spdAddr);
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

    function getDetectiveRank(uint256 _tokenId) external view returns (uint256) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");

        return tokenIdToDetective[_tokenId].actualRank;
    }

    function mint() external payable {
        require(maxSupply > totalSupply(), "Error, sold out!");
        require(isMintingActive == true, "Error, minting is not active");
        require(msg.value >= mintPrice, "Error, not enought ETH");
        require(balanceOf(msg.sender) == 0, "Error, you can only mint 1 token");
        require(IRulers(rulersTokenAddr).balanceOf(msg.sender) == 0, "Error, you're a ruler");

        uint256 _index = 0;

        uint256 newTokenId = _tokenIds.current();
        tokenIdToDetective[newTokenId].sP = detectiveStatePsychopath[_index];
        tokenIdToDetective[newTokenId].actualRank = 1;
        _safeMint(msg.sender, newTokenId);
        _tokenIds.increment();
        console.log("NFT w/ ID %s has been minted to %s", newTokenId, msg.sender);


    }

    function walletOfOwner(address _owner) external view returns(uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);

        for(uint256 _index; _index < ownerTokenCount; _index++){
            tokenIds[_index] = tokenOfOwnerByIndex(_owner, _index);
        }

        return tokenIds;
    }

    function increaseDetectiveSP(uint256 _tokenId) external {
        require(_exists(_tokenId), "Error, token doesn't exist");
        require(tokenIdToDetective[_tokenId].sP != detectiveStatePsychopath[6], "Error, token SP at his limit!");

        if(hasRole(SPD_ROLE, _msgSender()) || IRulers(rulersTokenAddr).balanceOf(msg.sender) >= 1) {
            bool isFound = false;
            while(isFound == false) {
                uint256 _index = 0;
                if(tokenIdToDetective[_tokenId].sP == detectiveStatePsychopath[_index]) {
                    _index++;
                    tokenIdToDetective[_tokenId].sP = detectiveStatePsychopath[_index];
    
                } else {
                    _index++;
                }
           }
        }
        
    }

    function levelUpRank(uint256 _tokenId) external onlyRole(SPD_ROLE) {
        require(_exists(_tokenId), "Error, token doesn't exist");

        if(tokenIdToDetective[_tokenId].actualRank < 6) {
            tokenIdToDetective[_tokenId].actualRank++;
        }
    }

    function levelDownRank(uint256 _tokenId) external onlyRole(SPD_ROLE) {
        require(_exists(_tokenId), "Error, token doesn't exist");

        if(tokenIdToDetective[_tokenId].actualRank > 1) {
            tokenIdToDetective[_tokenId].actualRank--;
        }
    }

    function killDetective(uint256 _tokenId) external payable {
        require(_exists(_tokenId), "Error, token doesn't exist");
        require(IRulers(rulersTokenAddr).balanceOf(msg.sender) >= 1 , "Error, you are not a ruler");

        if(tokenIdToDetective[_tokenId].sP == detectiveStatePsychopath[4]) {
            _burn(_tokenId);
        }
        
    }

    function withdraw() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(address(this).balance > 0, "Error, the contract is empty");

        payable(msg.sender).transfer(address(this).balance);
    }



}