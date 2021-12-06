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
      expect(error.message.startsWith("revert"));
      expect(error.message.includes("You can only vote once"));
    }
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
      expect(error.message.startsWith("revert"));
      expect(error.message.includes("You can only vote once"));
    }
  });
});
