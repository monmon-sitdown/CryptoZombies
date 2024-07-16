// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ZombieAttack} from "contracts/zombieattack.sol";
import {ERC721} from "contracts/erc721.sol";

/*
@title:A contract that manages transferring zombie ownership
@author:Qin
@dev:Compliant with OpenZeppelin's implementation of the ERC721 spec draft
*/

contract ZombieOwnership is ZombieAttack, ERC721 {
    mapping (uint => address) zombieApprovals;
    function balanceOf(address _owner) external override view returns (uint256)  {
    // 1. Return the number of zombies `_owner` has here
        return ownerZombieCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external override view returns (address) {
    // 2. Return the owner of `_tokenId` here
     return zombieToOwner[_tokenId];
  }


    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownerZombieCount[_to]++;
        ownerZombieCount[_from]--;
   
        zombieToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }
  function transferFrom(address _from, address _to, uint256 _tokenId) external override payable {
    require (zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
    _transfer(_from, _to, _tokenId);
  }

  function approve(address _approved, uint256 _tokenId) external override payable onlyOwnerOf(_tokenId) {
    zombieApprovals[_tokenId] = _approved;

    emit Approval(msg.sender, _approved, _tokenId);
  }
}