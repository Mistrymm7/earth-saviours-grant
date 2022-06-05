// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// KeeperCompatible.sol imports the functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lifestyle is ERC20, Ownable, KeeperCompatibleInterface {
    /**
    * Public counter variable
    */
    uint public counter;

    address[] public renters;
    bytes32[] public renterPerformance;
    uint256[] public renterRewards;

    /**
    * Use an interval in seconds and a timestamp to slow execution of Upkeep
    */
    uint public immutable interval;
    uint public lastTimeStamp;

    constructor(uint updateInterval) ERC20("Lifestyle", "MTK") {
      interval = updateInterval;
      lastTimeStamp = block.timestamp;
      counter = 0;
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;
            counter = counter + 1;
           

           getDailyEnergyUsage();
           rewardRenters();

        }
       
    }

    function getDailyEnergyUsage() public {
                  
        }

   
     function rewardRenters() public {
        for (uint i = 0; i<renters.length-1; i++){
             _mint(renters[i], renterRewards[i]);
        }          
     }

     function addRenter(address _renter) public onlyOwner {
         renters.push(_renter);
     }

     function removeRenter(uint _id) public onlyOwner {
        for (uint i = _id; i<renters.length-1; i++){
            renters[i] = renters[i+1];
        }
        renters.pop();
     }


    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
