// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ArtToken is ERC721Enumerable, Ownable {
  using Counters for Counters.Counter;

  struct Item {
    address creator;
    uint8 royalty;
    uint256 price;
    string uri;
  }

  Counters.Counter private _tokenIds;
  mapping(uint256 => Item) public items;

  constructor () ERC721("ArtToken", "ARTK") {}
  
  modifier IsExists(uint256 tokenId){
    require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");
    _;
  }

  function mint(
    uint256 price,
    string memory uri,
    uint8 royalty
  ) public returns (uint256) {
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);

    items[newItemId] = Item({
      creator: msg.sender,
      price: price,
      uri: uri,
      royalty: royalty
    });

    return newItemId;
  }

  function setRoyalty(uint256 tokenId, uint8 royalty) onlyOwner public {
    items[tokenId].royalty = royalty;
  }

  function getPrice(uint256 tokenId) public view IsExists(tokenId) returns (uint256) {
    return items[tokenId].price;
  }

  function tokenURI(uint256 tokenId) public view override IsExists(tokenId) returns (string memory) {
    return items[tokenId].uri;
  }

  function getTokenById(uint256 tokenId) external view IsExists(tokenId) returns (Item memory) {
    return items[tokenId];
  }
}