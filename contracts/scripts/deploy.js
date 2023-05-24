const hre = require("hardhat");

// Import necessary Hardhat dependencies
const { ethers } = require("hardhat");

async function main() {
  // Deploy NFTMarketplace contract
  const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");
  const nftMarketplace = await NFTMarketplace.deploy();
  await nftMarketplace.deployed();
  console.log("NFTMarketplace contract deployed:", nftMarketplace.address);

  // Deploy messageNFT contract
  const MessageNFT = await ethers.getContractFactory("messageNFT");
  const messageNFT = await MessageNFT.deploy();
  await messageNFT.deployed();
  console.log("messageNFT contract deployed:", messageNFT.address);
}

// Run the deployment script
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
