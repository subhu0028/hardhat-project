require("@nomiclabs/hardhat-ethers");
const API_URL = "Your testnet rpc link";
const PRIVATE_KEY = "Your Private Account address";
const PUBLIC_KEY = "Your Account Address";

// Replace import statement with require
const toolbox = require("@nomicfoundation/hardhat-toolbox");

// Export the configuration object using module.exports
module.exports = {
	solidity: "0.8.21",
	defaultNetwork: "goerli",
	networks: {
		hardhat: {},
		goerli: {
			url: API_URL,
			accounts: [`0x${PRIVATE_KEY}`],
		},
	},
};
