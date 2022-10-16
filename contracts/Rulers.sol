// SPDX-License-Identifier: UNLICENSED

pragma solidity  ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

interface IApproval {
    function balanceOf(address _addr) external view returns (uint256);
    function transfer(address _to, uint256 _amount) external payable;
}

interface IDetectives {
    function balanceOf(address _addr) external view returns (uint256);
    function increaseDetectiveSP(uint256 _tokenId) external;
    function levelUpRank(uint256 _tokenId) external;
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external returns (uint256);
    function levelDownRank(uint256 _tokenId) external;
}

contract Rulers is ERC721Enumerable, AccessControl {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    using Strings for uint256;

    struct Ruler {
        bool isUriRevealed;
        bool isSPRevealed;
        bytes32 sP;
    }

    bytes32 public constant SPD_ROLE = keccak256("SPD_ROLE");

    uint256 public maxSupply;
    uint256 public mintPrice;
    bool public isMintingActive = false;
    string public baseExtension = ".json";
    address private approvalTokenAddr;
    address private detectivesTokenAddr;
    bytes32 rulerStatePsychopath;
    mapping(uint256 => string) private tokenURIs;
    mapping(uint256 => Ruler) private tokenIdToRuler;

    constructor(
        string memory _contractName,
        string memory _contractSymbol,
        uint256 _setMaxSupply,
        uint256 _setMintPrice,
        bytes32 _setRulerStatePsychopath,
        address _spdAddr,
        address _setDetectiveTokenAddr,
        address _setApprovalTokenAddr
    ) 
    ERC721(_contractName, _contractSymbol) {
        maxSupply = _setMaxSupply;
        mintPrice = _setMintPrice;
        rulerStatePsychopath = _setRulerStatePsychopath;
        detectivesTokenAddr = _setDetectiveTokenAddr;
        approvalTokenAddr = _setApprovalTokenAddr;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(SPD_ROLE, _spdAddr);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function flipIsMintingActive() external onlyRole(DEFAULT_ADMIN_ROLE) {
        
        isMintingActive = !isMintingActive;
    }

    function setURIs(uint256 _state, string memory _uri) external onlyRole(DEFAULT_ADMIN_ROLE) {
       
        tokenURIs[_state] = _uri;
    }

    function mint() external payable {
        require(maxSupply > totalSupply(), "Error, sold out!");
        require(isMintingActive == true, "Error, minting is not active");
        require(msg.value >= mintPrice, "Error, not enought ETH");
        require(balanceOf(msg.sender) == 0, "Error, you can only mint 1 token");
        require(IDetectives(detectivesTokenAddr).balanceOf(msg.sender) >= 1, "Error, you're a detective");

        uint256 _index = 0;

        uint256 newTokenId = _tokenIds.current();
        tokenIdToRuler[newTokenId].sP = rulerStatePsychopath[_index];
        _safeMint(msg.sender, newTokenId);
        _tokenIds.increment();
        console.log("NFT w/ ID %s has been minted to %s", newTokenId, msg.sender);
        _index++;

        if(_index == 5) {
            _index = 0;
        }

    } 

    function walletOfOwner(address _owner) external view returns(uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);

        for(uint256 _index; _index < ownerTokenCount; _index++){
            tokenIds[_index] = tokenOfOwnerByIndex(_owner, _index);
        }

        return tokenIds;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns(string memory _tokenURI) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");

        if(tokenIdToRuler[_tokenId].isUriRevealed == true) {
            string memory currentURI = tokenURIs[1];
            return bytes(currentURI).length > 0 ?
                string(abi.encodePacked(currentURI, _tokenId.toString(), baseExtension)) : "";

        } else if(msg.sender == ownerOf(_tokenId)) {
            string memory currentURI = tokenURIs[1];
            return bytes(currentURI).length > 0 ?
                string(abi.encodePacked(currentURI, _tokenId.toString(), baseExtension)) : "";

        } else {
            string memory currentURI = tokenURIs[0];
            return bytes(currentURI).length > 0 ?
                string(abi.encodePacked(currentURI, _tokenId.toString(), baseExtension)) : "";

        }
    }

    function ifMatchRevealIdentity(uint256 _tokenId, address _suspiciusAddr) external payable {
        require(_exists(_tokenId), "Error, token doesn't exist");
        require(IApproval(approvalTokenAddr).balanceOf(msg.sender) >= 1, "Error, you don't hace approval");
        require(IDetectives(detectivesTokenAddr).balanceOf(msg.sender) >= 1, "Error, you're not a detective");
        
        address tokenOwnerAddr = ownerOf(_tokenId);
        IApproval(approvalTokenAddr).transfer(tokenOwnerAddr, 1);
        uint256 _senderTokenId = IDetectives(detectivesTokenAddr).tokenOfOwnerByIndex(msg.sender, 0);

        if(ownerOf(_tokenId) == _suspiciusAddr) {
            tokenIdToRuler[_tokenId].isUriRevealed = true;
            tokenIdToRuler[_tokenId].isSPRevealed = true;
            IDetectives(detectivesTokenAddr).levelUpRank(_senderTokenId);


        } else {
            IDetectives(detectivesTokenAddr).increaseDetectiveSP(_tokenId);
            IDetectives(detectivesTokenAddr).levelDownRank(_senderTokenId);

        }
    }

    function investigateSpfToken(uint256 _tokenId) external payable returns(bytes32 _statePsychopath) {
        require(_exists(_tokenId), "Error, token doesn't exist");
        require(IApproval(approvalTokenAddr).balanceOf(msg.sender) >= 1, "Error, you don't hace approval");
        require(IDetectives(detectivesTokenAddr).balanceOf(msg.sender) >= 1, "Error, you're not a detective");
        
        if(tokenIdToRuler[_tokenId].isSPRevealed == true) {
            return tokenIdToRuler[_tokenId].sP;
        }
        
    }

    function increaseSp(uint256 _tokenId) external onlyRole(SPD_ROLE) {
        require(_exists(_tokenId), "Error, token doesn't exist");
        
        bool isFound = false;
        while(isFound == false) {
            uint256 _index = 0;
            if(tokenIdToRuler[_tokenId].sP == rulerStatePsychopath[_index]) {
                _index++;
                tokenIdToRuler[_tokenId].sP = rulerStatePsychopath[_index];

            } else {
                _index++;
            }
        }
    }

    function killRuler(uint256 _tokenId) external payable {
        require(_exists(_tokenId), "Error, token doesn't exist");
        require(IApproval(approvalTokenAddr).balanceOf(msg.sender) >= 1, "Error, you don't hace approval");
        require(IDetectives(detectivesTokenAddr).balanceOf(msg.sender) >= 1, "Error, you're not a detective");

        if(tokenIdToRuler[_tokenId].sP == rulerStatePsychopath[4] || IApproval(approvalTokenAddr).balanceOf(msg.sender) >= 4) {
            _burn(_tokenId);
        }
        
    }

    function burnByOwner(uint256 _tokenId) external {
        require(_exists(_tokenId), "Error, the doesn't must");
        require(ownerOf(_tokenId) == msg.sender, "Error, you're not the owner of this token");

        _burn(_tokenId);
    }

    function withdraw() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(address(this).balance > 0, "Error, the contract is empty");

        payable(msg.sender).transfer(address(this).balance);
    }
   
        
}