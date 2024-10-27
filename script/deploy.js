// script/deploy.js
const { ethers } = require("hardhat");

async function main() {
  const MockAVSService = await ethers.getContractFactory("MockAVSService");
  const mockAVSService = await MockAVSService.deploy();
  await mockAVSService.deployed();
  console.log("MockAVSService deployed to:", mockAVSService.address);

  const VotingAgeVerification = await ethers.getContractFactory(
    "VotingAgeVerification"
  );
  const votingAgeVerification = await VotingAgeVerification.deploy(
    mockAVSService.address
  );
  await votingAgeVerification.deployed();
  console.log(
    "VotingAgeVerification deployed to:",
    votingAgeVerification.address
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
