const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Rulers", function() {

  let rulersContract;
  let approvalContract;
  let detectivesContract;
  let owner;
  let user1;
  let user2;

  beforeEach(async function() {
    const maxSupply = 100;
    const mintPrice = 1;
    [owner, user1, user2] = await ethers.getSigners();

    // Deploy approval contract
    
  });


});
