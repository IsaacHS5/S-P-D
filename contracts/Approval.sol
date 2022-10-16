// SPDX-License-Identifier: UNLICENSED

pragma solidity  ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface IRulers {
    function balanceOf(address _addr) external view returns (uint256);
}

interface IDetectives {
    function balanceOf(address _addr) external view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns(uint256);
    function increaseDetectiveSP(uint256 _tokenId) external;
    function getDetectiveRank(uint256 _tokenId) external view returns (uint256);
}

contract Approval is ERC20, AccessControl {

    uint256 public maxSupply;
    uint256 public burntSupply;
    uint256 public illegalPrice;
    uint256 public maxRequests = 20;
    address internal illegalSeller;
    address[] public requesters;
    address private detectivesTokenAddr;
    address private rulersTokenAddr;
    mapping(address => uint256) public requesterToFeedOffer;

    constructor(
        string memory _name,
        string memory _symbol,
        address _illegalSeller,
        address _detectivesTokenAddr,
        address _rulersTokenAddr
        )
    ERC20(_name, _symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        illegalSeller = _illegalSeller;
        detectivesTokenAddr = _detectivesTokenAddr;
        rulersTokenAddr = _rulersTokenAddr;

    }

    function updateMaxSupply(uint256 _newMaxSupply) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Error, Only admin can update");
        maxSupply = _newMaxSupply;
    }

    function requetApproval() external {
        require(balanceOf(msg.sender) > 0, "Error, you can't request more approval");
        require(requesters.length < maxRequests, "Error, requests are at their limit");
        require(IDetectives(detectivesTokenAddr).balanceOf(msg.sender) >= 1, "Error, you are not a detective");

        requesters.push(msg.sender);
    }

    function deleteRequester(address _requester) external {
        require(IRulers(rulersTokenAddr).balanceOf(msg.sender) >= 1, "Error, you are not a ruler");
        
        bool isFound = false;
        while(isFound == false) {
            uint256 _index = 0;
            if(requesters[_index] == _requester) {
                delete requesters[_index];
                isFound = true;
            } else {
                _index++;
            }
        }

    }

    function sendToRequester(address _to, uint256 _tokenId) external {
        uint256 bigNumber = 1e18;
        uint256 total;

        require(IRulers(rulersTokenAddr).balanceOf(msg.sender) >= 1, "Error, you are not a ruler");
         require(
            totalSupply() + total <= (maxSupply - burntSupply),
            "Max has been reached."
        );

        if(IDetectives(detectivesTokenAddr).getDetectiveRank(_tokenId) == 6) {
            total = 5 * bigNumber;
            _mint(_to, total);

        } else if(IDetectives(detectivesTokenAddr).getDetectiveRank(_tokenId) >= 4) {
            total = 3 * bigNumber;
            _mint(_to, total);

        } else if(IDetectives(detectivesTokenAddr).getDetectiveRank(_tokenId) >= 2) {
            total = 2 * bigNumber;
            _mint(_to, total);

        } else {
            _mint(_to, bigNumber);
        }

    }

    function buyIlegallys(uint256 _amount) external payable {
        uint256 bigNumber = _amount * illegalPrice;

        require(msg.value >= bigNumber, "Must send right amount.");
        require(IDetectives(detectivesTokenAddr).balanceOf(msg.sender) >= 1, "Error, you are not a detective");
        require(
            totalSupply() + bigNumber <= (maxSupply - burntSupply),
            "Max has been reached."
        );

        // Pay to the illegalSeller
        payable(illegalSeller).transfer(msg.value);

        _mint(msg.sender, bigNumber);

        uint256 _tokenId = IDetectives(detectivesTokenAddr).tokenOfOwnerByIndex(msg.sender, 0);
        IDetectives(detectivesTokenAddr).increaseDetectiveSP(_tokenId);
    }

    function burn(address _account, uint256 _amount) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Error, only admin can burn"
        );
        require(maxSupply - burntSupply > 0, "Nothing to burn.");

        burntSupply += _amount;
        _burn(_account, _amount);
    }

    function withdraw() external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Error, only admin can withdraw");
        require(address(this).balance > 0, "Error, the contract is empty");

        payable(msg.sender).transfer(address(this).balance);
    }

}