// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// KeeperCompatible.sol imports the functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract Lifestyle is ERC20, Ownable, KeeperCompatibleInterface {
   
    uint public counter;

    address[] public renters;
    bytes32[] public renterPerformance;
    uint256[] public renterRewards;

    
    uint public immutable interval;
    uint public lastTimeStamp;

    event RenterDailyRewards(address indexed _renterid, uint _renterReward);
   

    constructor(uint updateInterval) ERC20("Lifestyle", "MTK") {
      interval = updateInterval;
      lastTimeStamp = block.timestamp;
      
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;
                     
           getDailyEnergyUsage();

           rewardRenters();
           
        }      
    }

   
     function rewardRenters() public {
        for (uint i = 0; i<renters.length-1; i++){
             _mint(renters[i], renterRewards[i]);

        emit RenterDailyRewards(renters[i], renterRewards[i]);
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

     function addrenterRewards(uint _rewardValue) public onlyOwner {
         renterRewards.push(_rewardValue);
     }


    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function getDailyEnergyUsage() public {

    /* Interface with Any Link API IWeather */ 

    }
}

contract Weather is ChainlinkClient {
    using Chainlink for Chainlink.Request;
    

    uint256 public dailyEnergyConsumptionCal;
    bytes32 public dailyEnergyJobId;
    uint256 public fee;
   
    
    event totalEnergyConsumption(uint256 _result);
    
    
    constructor(
        address _link,
        address _oracle,
        bytes32 _dailyEnergyJobId,
        uint256 _dailyEnergyConsumptionCal, 
        uint256 _fee
    ) {
        setChainlinkToken(_link);
        setChainlinkOracle(_oracle);
        dailyEnergyJobId = _dailyEnergyJobId;
        fee = _fee;
    }

    function requestTotalDailyEnergy(
        string memory _from,
        string memory _to
    ) external {
        Chainlink.Request memory req = buildChainlinkRequest(
            dailyEnergyJobId,
            address(this),
            this.fulfillTotalDailyEnergy.selector
        );
        req.add("dateFrom", _from);
        req.add("dateTo", _to);
        req.add("method", "Total");
        req.add("column", "Energy");
        sendChainlinkRequest(req, fee);
    }
    
    function fulfillTotalDailyEnergy(
        bytes32 _requestId,
        uint256 _result
    ) external recordChainlinkFulfillment(_requestId) {
        dailyEnergyConsumptionCal = _result;
        emit totalEnergyConsumption(_result);
    }
    
   
}
