// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarketplace is ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address public owner;

    constructor() {
        owner == msg.sender;
    }

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;


    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

 function createMarketItem(address nftContract, uint256 tokenId, uint256 price)
    public payable nonReentrant
{
    // Ensure that the price is greater than 0
    require(price > 0, "Price must be greater than 0");

    // Increment the item IDs counter
    _itemIds.increment();
    uint256 itemId = _itemIds.current();

    // Create a new MarketItem and store it in the idToMarketItem mapping
    idToMarketItem[itemId] = MarketItem(
        itemId,
        nftContract,
        tokenId,
        payable(msg.sender),    // Seller's address wrapped in the payable type
        payable(address(0)),    // Initial buyer's address (zero address) wrapped in the payable type
        price,
        false                   // Flag indicating if the item is sold, initially set to false
    );

    // Transfer the ownership of the NFT token from the caller to the contract
    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

    // Emit an event to notify listeners about the creation of the market item
    emit MarketItemCreated(
        itemId,
        nftContract,
        tokenId,
        msg.sender,
        address(0),             // Initial buyer's address (zero address)
        price,
        false                   // Flag indicating if the item is sold
    );
}


function createMarketSale(
    address nftContract,
    uint256 itemId
) public payable nonReentrant {
    // Retrieve the price, tokenId, and sold status of the item
    uint256 price = idToMarketItem[itemId].price;
    uint256 tokenId = idToMarketItem[itemId].tokenId;
    bool sold = idToMarketItem[itemId].sold;

    // Require the sent value to match the price of the item
    require(msg.value == price, "Please submit the asking price in order to complete the purchase");

    // Require the item to not be sold already
    require(sold != true, "This Sale has already finished");

    // Transfer the payment to the seller
    idToMarketItem[itemId].seller.transfer(msg.value);

    // Transfer the NFT ownership from the contract to the buyer
    IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

    // Update the owner, increment items sold, and mark the item as sold
    idToMarketItem[itemId].owner = payable(msg.sender);
    _itemsSold.increment();
    idToMarketItem[itemId].sold = true;
}

function fetchMarketItems() public view returns (MarketItem[] memory) {
    // Get the total number of items and calculate the number of unsold items
    uint256 itemCount = _itemIds.current();
    uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
    uint256 currentIndex = 0; // Current index for populating the 'items' array

    // Create a new dynamic array 'items' to store unsold market items
    MarketItem[] memory items = new MarketItem[](unsoldItemCount);

    // Iterate through all items to find unsold items
    for (uint256 i = 0; i < itemCount; i++) {
        // Check if the item's owner is the zero address (not assigned to any owner)
        if (idToMarketItem[i + 1].owner == address(0)) {
            uint256 currentId = i + 1; // Get the current item's ID
            MarketItem storage currentItem = idToMarketItem[currentId]; // Get the reference to the current market item
            items[currentIndex] = currentItem; // Add the unsold item to the 'items' array
            currentIndex += 1; // Increment the current index for the next item
        }
    }

    return items; // Return the array of unsold market items
}
}