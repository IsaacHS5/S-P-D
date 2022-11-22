// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract Votes is ERC20, ERC20Permit, Ownable, ERC20Votes {

    uint256 price = 1 wei;

    constructor() ERC20("Votes", "VTS") ERC20Permit("Votes") {}

    function mint(address _rulersTokenAddr, address _to, uint256 _amount) public payable {

        if(msg.value >= price && IERC721(_rulersTokenAddr).balanceOf(msg.sender) != 1) {
            revert("No enough WEI and/or you're not a ruler");

        } 
        _mint(_to, _amount);
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "Error, the contract is empty");

        payable(msg.sender).transfer(address(this).balance);
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(address _from, address _to, uint256 _amount)
        internal
        override(ERC20, ERC20Votes) {

        super._afterTokenTransfer(_from, _to, _amount);
    }

    function _mint(address _to, uint256 _amount) internal override(ERC20, ERC20Votes) {
        super._mint(_to, _amount);
    }

    function _burn(address _account, uint256 _amount) internal override(ERC20, ERC20Votes) {
        super._burn(_account, _amount);
    }

}