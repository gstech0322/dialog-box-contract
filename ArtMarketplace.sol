// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./ArtToken.sol";

contract ArtMarketplace is IERC721Receiver{
  ArtToken private artCollection;

  struct ItemForSale{
    address payable seller;
    uint256 price;
    bool onSale;
  }

  mapping(uint256 => ItemForSale) public itemsForSale;

  event ItemAddedForSale(uint256 tokenId);
  event ItemSold(uint256 id, address buyer, uint256 price);

  constructor(ArtToken _token) {
    artCollection = _token;
  }

  modifier OnlyItemOwner(uint256 tokenId){
    require(artCollection.ownerOf(tokenId) == address(this), "Sender does not own the item");
    _;
  }

  modifier ItemExists(uint256 tokenId){
    require(itemsForSale[tokenId].seller != address(0x0), "Could not find the item.");
    _;
  }

  modifier IsForSale(uint256 tokenId){
    require(itemsForSale[tokenId].onSale, "The item is already sold.");
    _;
  }

  function _putItemForSale(
    uint256 tokenId
  ) OnlyItemOwner(tokenId) private {
    itemsForSale[tokenId] = ItemForSale({
      seller: payable(msg.sender),
      price: artCollection.getPrice(tokenId),
      onSale: true
    });

    emit ItemAddedForSale(tokenId);
  }

  function buyItem(
    uint256 tokenId
  ) ItemExists(tokenId) IsForSale(tokenId) OnlyItemOwner(tokenId) payable external {
    require(msg.value >= itemsForSale[tokenId].price, "Not enough funds sent");
    itemsForSale[tokenId].onSale = false;
    artCollection.safeTransferFrom(address(this), msg.sender, tokenId);
    itemsForSale[tokenId].seller.transfer(msg.value);

    emit ItemSold(tokenId, msg.sender, itemsForSale[tokenId].price);
  }

  
  function mint(
    uint256 price,
    string memory uri
  ) public returns (uint256) {
    uint256 tokenId = artCollection.mint(price, uri, 5); // default royalty is 5%
    _putItemForSale(tokenId);
    return tokenId;
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external pure override returns (bytes4) {
    return this.onERC721Received.selector;
  }
}

// TODO:
// - don't support bidding
// - the user can't withdraw the item