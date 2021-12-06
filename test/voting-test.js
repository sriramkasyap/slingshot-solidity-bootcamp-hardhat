const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

async function initiate(voting) {
  return await voting.initiate(["One", "Two", "Three"]);
}

describe("Voting Contract", function () {
  it("Should get initiated with Zero Votes for candidates", async function () {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.deployed();

    await voting.initiate(["One", "Two", "Three"]);

    expect(await voting.getVotes("One")).to.equal(0);
    expect(await voting.getVotes("Two")).to.equal(0);
    expect(await voting.getVotes("Three")).to.equal(0);
  });

  it("Anyone can vote and increase Vote Count", async function () {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.deployed();

    await initiate(voting);

    const [owner, addr1, addr2] = await ethers.getSigners();

    await voting.vote("One");
    expect(await voting.getVotes("One")).to.equal(1);

    await voting.connect(addr1).vote("One");
    expect(await voting.getVotes("One")).to.equal(2);

    await voting.connect(addr2).vote("Two");
    expect(await voting.getVotes("Two")).to.equal(1);
  });

  it("No one can vote twice", async function () {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.deployed();

    await initiate(voting);

    try {
      await voting.vote("One");
      await voting.vote("One");
    } catch (error) {
      expect(error.message).to.include("revert");
      expect(error.message).to.include("You can only vote once");
    }
  });

  it("Should not allow voting to unlisted candidates", async function () {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.deployed();

    await initiate(voting);

    try {
      await voting.vote("Random");
    } catch (error) {
      expect(error.message).to.include("revert");
      expect(error.message).to.include("This Candidate is not listed");
    }
  });

  it("Should allow only the owner to close voting", async function () {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.deployed();

    await initiate(voting);

    const [owner, addr1] = await ethers.getSigners();

    try {
      await voting.connect(addr1).closeVoting();
    } catch (error) {
      expect(error.message).to.include("revert");
      expect(error.message).to.include("not authorized");
    }
  });

  it("Should not allow voting after closing", async function () {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.deployed();

    await initiate(voting);

    const [owner, addr1] = await ethers.getSigners();

    await voting.vote("Two");

    try {
      await voting.closeVoting();
      await voting.connect(addr1).vote("One");
    } catch (error) {
      expect(error.message).to.include("revert");
      expect(error.message).to.include("not active");
    }
  });

  it("Should not allow closing if voting not in progress", async function () {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.deployed();

    try {
      await voting.closeVoting();
    } catch (error) {
      expect(error.message).to.include("revert");
    }
  });

  it("Should return appropriate Voting Status", async function () {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.deployed();

    expect(await voting.getVotingStatus()).to.equal("Initialized");

    await initiate(voting);
    expect(await voting.getVotingStatus()).to.include("in Progress");

    await voting.vote("One");

    await voting.closeVoting();
    expect(await voting.getVotingStatus()).to.include("complete");

    await voting.resetVoting();
    expect(await voting.getVotingStatus()).to.include("Initialized");
  });

  it("Should return appropriate Voting Status", async function () {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.deployed();

    expect(await voting.getVotingStatus()).to.equal("Initialized");

    await initiate(voting);
    expect(await voting.getVotingStatus()).to.include("in Progress");

    await voting.vote("One");

    await voting.closeVoting();
    expect(await voting.getVotingStatus()).to.include("complete");

    await voting.resetVoting();
    expect(await voting.getVotingStatus()).to.include("Initialized");
  });

  it("Should reset votes and candidates on reset", async function () {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.deployed();

    await initiate(voting);

    const [owner, addr1, addr2, addr3] = await ethers.getSigners();

    await voting.vote("One");
    await voting.connect(addr1).vote("One");
    await voting.connect(addr2).vote("One");
    await voting.connect(addr3).vote("Two");

    await voting.closeVoting();

    await voting.resetVoting();
    try {
      await voting.getVotes("One");
    } catch (error) {
      expect(error.message).to.include("revert");
      expect(error.message).to.include("not listed");
    }
  });
});
