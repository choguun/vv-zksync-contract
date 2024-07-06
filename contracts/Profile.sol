// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Profile is ERC721, ERC721Enumerable, Ownable {

    mapping(uint256 => string) public profileHandle; // tokenId => handle
    mapping(string => uint256) public handleToTokenId; // handle => tokenId
    uint256 public price = 0.0001 ether; // 0.0001 ETH

    constructor(address _initialOwner) ERC721("Profile", "Profile") {
      transferOwnership(_initialOwner);
    }
    
    function registerHandle(string memory username) external payable {
        mint(msg.sender, username);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
    }

    function mint(address _to, string memory username) public payable {
        require(msg.value >= price, "Insufficient amount");
        require(handleToTokenId[username] == 0, "Handle already exists");
        require(this.balanceOf(_msgSender()) == 0, "Only one profile handle per wallet");

        _safeMint(_to, totalSupply() + 1);
        handleToTokenId[username] = totalSupply();
        profileHandle[totalSupply()] = username;
    }

    // function withdraw() public onlyOwner {
    //     payable(msg.sender).transfer(address(this).balance);
    // }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
      return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}