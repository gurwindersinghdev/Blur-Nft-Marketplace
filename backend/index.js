const express = require("express");
const app = express();
const port = 5001;
const Moralis = require("moralis").default;
const cors = require("cors");

require("dotenv").config({ path: ".env" });

app.use(cors());
app.use(express.json());

const MORALIS_API_KEY = process.env.MORALIS_API_KEY;

app.get("/getnftdata", async (req, res) => {
  try {
    const { query } = req; // Extract the query parameters from the request

    if (typeof query.contractAddress === "string") {
      // Check if a single contract address is provided
      const response = await Moralis.EvmApi.nft.getNFTTrades({
        address: query.contractAddress,
        chain: "0x13881",
      });

      return res.status(200).json(response); // Send the response with the retrieved NFT trade data
    } else {
      const nftData = []; // Create an array to store the NFT trade data

      for (let i = 0; i < query.contractAddress.length; i++) {
        // Iterate over each contract address in the array
        const response = await Moralis.EvmApi.nft.getNFTTrades({
          address: query.contractAddress[i],
          chain: "0x13881",
        });

        nftData.push(response); // Store the retrieved NFT trade data in the array
      }

      const response = { nftData }; // Create a response object with the collected NFT trade data
      return res.status(200).json(response); // Send the response with the collected NFT trade data
    }
  } catch (e) {
    console.log(`Something went wrong ${e}`);
    return res.status(400).json(); // Send a response with an error status if an error occurs
  }
});

app.get("/getcontractnft", async (req, res) => {
  try {
    const { query } = req; // Extract the query parameters from the request
    const chain = query.chain == "0x13881" ? "0x13881" : "0x13881"; // Determine the chain based on the query parameter

    const response = await Moralis.EvmApi.nft.getContractNFTs({
      chain,
      format: "decimal",
      address: query.contractAddress,
    });

    return res.status(200).json(response); // Send the response with the retrieved contract NFTs data
  } catch (e) {
    console.log(`Something went wrong ${e}`);
    return res.status(400).json(); // Send a response with an error status if an error occurs
  }
});

app.get("/getnfts", async (req, res) => {
  try {
    const { query } = req; // Extract the query parameters from the request

    const response = await Moralis.EvmApi.nft.getWalletNFTs({
      address: query.address,
      chain: query.chain,
    });

    return res.status(200).json(response); // Send the response with the retrieved wallet NFTs data
  } catch (e) {
    console.log(`Something went wrong ${e}`);
    return res.status(400).json(); // Send a response with an error status if an error occurs
  }
});

Moralis.start({
  apiKey: MORALIS_API_KEY,
}).then(() => {
  app.listen(port, () => {
    console.log(`Listening for API calls`);
  });
});
