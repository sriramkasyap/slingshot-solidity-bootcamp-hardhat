const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('NFT Voting Contract', function () {
  let NFTVoting, nftvoting, owner, addr1, addr2;

  const initiateVoting = async () => {
    await nftvoting.initiateElection(['One', 'Two', 'Three']);

    await nftvoting.registerAsVoter(); // 0
    await nftvoting.connect(addr1).registerAsVoter(); // 1
    await nftvoting.connect(addr2).registerAsVoter(); // 2
  };

  beforeEach(async () => {
    NFTVoting = await ethers.getContractFactory('NFTVoting');
    nftvoting = await NFTVoting.deploy();
    await nftvoting.deployed();
    [owner, addr1, addr2] = await ethers.getSigners();
  });

  it('Should get initiated with Zero Votes for candidates', async function () {
    await nftvoting.initiateElection(['One', 'Two', 'Three']);

    expect(await nftvoting.getVoteCount('One')).to.equal(0);
    expect(await nftvoting.getVoteCount('Two')).to.equal(0);
    expect(await nftvoting.getVoteCount('Three')).to.equal(0);
  });

  it('Voters can get registered and receive NFT Voter ID', async function () {
    await nftvoting.connect(addr1).registerAsVoter();

    expect(await nftvoting.ownerOf(await nftvoting.tokenByIndex(0))).to.equal(
      addr1.address
    );

    await nftvoting.connect(addr2).registerAsVoter();

    expect(await nftvoting.ownerOf(await nftvoting.tokenByIndex(1))).to.equal(
      addr2.address
    );
  });

  it('Voters can vote a candidate using Voter ID', async function () {
    await nftvoting.initiateElection(['One', 'Two', 'Three']);
    await nftvoting.connect(addr1).registerAsVoter();

    let voterId = await nftvoting.tokenByIndex(0);
    await nftvoting.connect(addr1).vote('One', voterId);

    expect(await nftvoting.getVoteCount('One')).to.equal(1);
  });

  it('Every vote increases the candidate Vote Count', async function () {
    await initiateVoting();

    await nftvoting.vote('One', await nftvoting.tokenByIndex(0));
    expect(await nftvoting.getVoteCount('One')).to.equal(1);

    await nftvoting.connect(addr1).vote('One', await nftvoting.tokenByIndex(1));
    expect(await nftvoting.getVoteCount('One')).to.equal(2);

    await nftvoting.connect(addr2).vote('Two', await nftvoting.tokenByIndex(2));
    expect(await nftvoting.getVoteCount('Two')).to.equal(1);
  });

  it("Voter ID can't be used twice", async function () {
    try {
      await initiateVoting();

      await nftvoting.vote('One', await nftvoting.tokenByIndex(0));
      await nftvoting.vote('One', await nftvoting.tokenByIndex(0));
    } catch (error) {
      expect(error.message).to.include('revert');
      expect(error.message).to.include('This VoterID has already been used');
    }
  });

  it('Should not allow voting to unlisted candidates', async function () {
    await initiateVoting();

    try {
      await nftvoting.vote('Random', await nftvoting.tokenByIndex(0));
    } catch (error) {
      expect(error.message).to.include('revert');
      expect(error.message).to.include(
        'This candidate is not participating in this election'
      );
    }
  });

  it('Should allow only the owner to close voting', async function () {
    await initiateVoting();

    try {
      await nftvoting.connect(addr1).closeVoting();
    } catch (error) {
      expect(error.message).to.include('revert');
      expect(error.message).to.include('not the owner');
    }
  });

  it('Should not allow voting after closing', async function () {
    await initiateVoting();

    await nftvoting.vote('Two', await nftvoting.tokenByIndex(0));

    try {
      await nftvoting.closeVoting();
      await nftvoting
        .connect(addr1)
        .vote('One', await nftvoting.tokenByIndex(1));
    } catch (error) {
      expect(error.message).to.include('revert');
      expect(error.message).to.include('not active');
    }
  });

  it('Should not allow closing if voting not in progress', async function () {
    try {
      await nftvoting.closeVoting();
    } catch (error) {
      expect(error.message).to.include('revert');
    }
  });

  it('Should return appropriate Voting Status', async function () {
    expect(await nftvoting.getVotingStatus()).to.equal('Initialized');

    await initiateVoting();
    expect(await nftvoting.getVotingStatus()).to.include('in Progress');

    await nftvoting.vote('One', await nftvoting.tokenByIndex(0));

    await nftvoting.closeVoting();
    expect(await nftvoting.getVotingStatus()).to.include('complete');

    await nftvoting.resetVoting();
    expect(await nftvoting.getVotingStatus()).to.include('Initialized');
  });

  it('Should reset votes and candidates on reset', async function () {
    await initiateVoting();

    await nftvoting.vote('One', await nftvoting.tokenByIndex(0));
    await nftvoting.connect(addr1).vote('One', await nftvoting.tokenByIndex(1));
    await nftvoting.connect(addr2).vote('One', await nftvoting.tokenByIndex(2));
    await nftvoting.connect(addr3).vote('Two', await nftvoting.tokenByIndex(3));

    await nftvoting.closeVoting();

    await nftvoting.resetVoting();
    try {
      await nftvoting.getVotes('One');
    } catch (error) {
      expect(error.message).to.include('revert');
      expect(error.message).to.include('not listed');
    }
  });
});
