const { BigNumber } = require("@ethersproject/bignumber");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Non-Tradeable Token Contract - Construction", function () {
  it("Should grant the owner the initial supply", async function () {
    const SKMGovToken = await ethers.getContractFactory("SKMGovToken");

    const initSupply = 10 ^ 18;
    const token = await SKMGovToken.deploy(initSupply);
    await token.deployed();

    const [owner] = await ethers.getSigners();

    expect(await token.balanceOf(owner.address)).to.equal(initSupply);
  });

  it("Should not let initial supply be greater than Max Supply Allowed", async function () {
    const SKMGovToken = await ethers.getContractFactory("SKMGovToken");

    const initSupply = 1001 * (10 ^ 18);
    const [owner] = await ethers.getSigners();
    try {
      const token = await SKMGovToken.deploy(initSupply);
      await token.deployed();
    } catch (error) {
      expect(error.message).to.include("revert");
      expect(error.message).to.include(
        "Initial Supply cannot be greater than Max Supply"
      );
    }
  });
});

describe("Non-Tradeable Token Contract - Access Control", async function () {
  let SKMGovToken,
    initSupply,
    owner,
    addr1,
    addr2,
    addr3,
    token,
    admin_role,
    member_role;

  before(async () => {
    SKMGovToken = await ethers.getContractFactory("SKMGovToken");
    initSupply = 1 * (10 ^ 18);
    [owner, addr1, addr2, addr3] = await ethers.getSigners();
    token = await SKMGovToken.deploy(initSupply);
    admin_role = await token.DEFAULT_ADMIN_ROLE();
    member_role = await token.TEAM_MEMBER_ROLE();
    await token.deployed();
  });

  it("Owner has default admin role", async function () {
    expect(await token.hasRole(admin_role, owner.address)).to.be.true;
  });

  it("Owner can add people to team", async function () {
    await token.addMember(addr1.address);
    expect(await token.hasRole(member_role, addr1.address)).to.be.true;
  });

  it("Owner can remove people from team", async function () {
    await token.addMember(addr1.address);
    expect(await token.hasRole(member_role, addr1.address)).to.be.true;

    await token.removeMember(addr1.address);
    expect(await token.hasRole(member_role, addr1.address)).to.be.false;
  });

  it("Team members cannot add others to team", async function () {
    try {
      await token.connect(addr1).addMember(addr2.address);
    } catch (error) {
      expect(error.message).to.include("revert");
      expect(error.message).to.include("missing role");
    }
  });

  it("Team members cannot remove others from team", async function () {
    try {
      await token.addMember(addr1.address);
      await token.addMember(addr2.address);
      await token.connect(addr1).removeMember(addr2.address);
    } catch (error) {
      expect(error.message).to.include("revert");
      expect(error.message).to.include("missing role");
    }
  });
});

describe("Non-Tradeable Token Contract - Token Minting and Transfer", function () {
  let SKMGovToken,
    initSupply,
    toMint,
    owner,
    addr1,
    addr2,
    addr3,
    token,
    admin_role,
    member_role,
    MAX_SUPPLY;

  before(async () => {
    SKMGovToken = await ethers.getContractFactory("SKMGovToken");
    initSupply = BigNumber.from(1 * (10 ^ 18));
    toMint = 1 * (10 ^ 18);
    [owner, addr1, addr2, addr3] = await ethers.getSigners();
    token = await SKMGovToken.deploy(initSupply);
    await token.deployed();
    admin_role = await token.DEFAULT_ADMIN_ROLE();
    member_role = await token.TEAM_MEMBER_ROLE();
    MAX_SUPPLY = await token.MAX_SUPPLY();
  });

  it("Owner can reward tokens to any address by minting", async function () {
    await token.rewardToken(addr1.address, toMint);

    expect(await token.balanceOf(owner.address)).to.equal(initSupply);
    expect(await token.balanceOf(addr1.address)).to.equal(toMint);
  });

  it("Team Members can reward token to others", async function () {
    await token.addMember(addr1.address);
    await token.connect(addr1).rewardToken(addr2.address, toMint);

    expect(await token.balanceOf(addr2.address)).to.equal(toMint);
  });

  it("Non-Team Members cannot reward tokens", async function () {
    try {
      await token.connect(addr2).rewardToken(addr3.address, 10 ^ 18);
    } catch (error) {
      expect(error.message).to.include("revert");
      expect(error.message).to.include("missing role");
    }
  });

  it("Should not be able to mint more than Max Supply", async function () {
    try {
      await token.rewardToken(addr1.address, MAX_SUPPLY);
    } catch (error) {
      expect(error.message).to.include("revert");
      expect(error.message).to.include("reached the maximum supply");
    }
  });
});
