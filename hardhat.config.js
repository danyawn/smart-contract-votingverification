require("dotenv").config();
require("@nomiclabs/hardhat-ethers");

module.exports = {
    solidity: "0.8.13",
    networks: {
        goerli: {
            url: process.env.ALCHEMY_API_URL,
            accounts: [process.env.PRIVATE_KEY],
        },
    },
};
