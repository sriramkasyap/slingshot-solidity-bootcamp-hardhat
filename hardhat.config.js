require("@nomiclabs/hardhat-waffle");
require("solidity-coverage");
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.7",
  networks: {
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/a610e824d6bc4bef94728de6b76a098f",
      accounts: [
        "426ca860238d5414b59d9588cb8e85b2aca94bf20a025c175746fa8c14767725",
      ],
    },
  },
  etherscan: {
    apiKey: "U8QD8TJTGES2BTISEJKZZPR3QHC5N54H17",
  },
};
