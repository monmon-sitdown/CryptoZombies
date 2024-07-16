// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ZombieFactory} from "contracts/zombiefactory.sol";

interface KittyInterface {
    function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {
    address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    KittyInterface kittyContract = KittyInterface(ckAddress);

    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) public {
        require(zombieToOwner[_zombieId] == msg.sender);
        Zombie storage myZombie = zombies[_zombieId];
        //Data location must be "storage", "memory" or "calldata" for variable, 
    
        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;

        if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            newDna = newDna - newDna % 100 + 99;
        }

        _createZombie("NoName", newDna);
    }

    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract ZombieFactory {
    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    mapping(uint => address) public zombieToOwner;
    mapping(address => uint) public ownerZombieCount;

    function _createZombie(string memory _name, uint _dna) internal {
        uint id = zombies.length;
        zombies.push(Zombie(_name, _dna));

        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;

        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        require(ownerZombieCount[msg.sender] == 0);

        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}

