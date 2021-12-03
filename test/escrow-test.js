const { expect } = require("chai");
const { ethers } = require("hardhat");

let signers;

(async () => {
  signers = await ethers.getSigners();
  console.log(signers);
})();

describe("Escrow", function () {
  it("Should have user_A, amount and balance set on initiation", async function () {
    const Escrow = await ethers.getContractFactory("EscrowHolder");
    const escrow = await Escrow.deploy();
    const contractValue = 1e15;
    await escrow.deployed();

    await escrow.connect(signers[0]).initiate(signers[1], contractValue, {
      value: contractValue,
    });

    expect(await escrow.user_A()).to.equal(signers[0].address);
    expect(await escrow.amount()).to.equal(contractValue);
    expect(await escrow.user_B()).to.equal(signers[1]);
  });

  //   it("Should not let anyone report completion", async function () {
  //     const Escrow = await ethers.getContractFactory("EscrowHolder");
  //     const escrow = await Escrow.deploy();
  //     const contractValue = 1e15;
  //     await escrow.deployed();
  //     await escrow.connect(someone).reportCompletion();
  //   });
});
