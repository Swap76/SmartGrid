


pragma solidity ^0.4.19;
import "./Energy.sol";

contract MoneyForEnergy {
    
    event TransferOfMoney(address from, address to, uint money);
    
    bool urgency=false;
    
    struct TABS{
        uint[] energy;
        uint[] timestamp;
    }
    
    
    struct Producer{
        string producerName;
        uint256 ProductionCapacity;
        uint256 costPerUnit;   
        TABS tab;
    }
    
    struct Provider{
        string providerName;
        uint256 StorageCapacity;
        uint256 costPerUnit;
    }
    
    struct Consumer{
        string consumerName;
        uint256 StorageCapacity;
        address provide;
        TABS tab;
    }
    
    
    
    mapping(address => Producer)public producer;
    mapping(address => Provider) provider;
    mapping(address => Consumer) consumer;
    mapping(address => uint) balancesOfMoney;
    mapping(address => uint) costPerUnit; 
    mapping(address=>uint) Entities;
    
    
    modifier CheckIfAlreadyEntity(address _addr){
        require(Entities[_addr]==0);
        _;
    }
    
    function addProducer(string _name, uint _productionCapacity, uint _cpu) public CheckIfAlreadyEntity(msg.sender) {
        TABS tabb;
        producer[msg.sender]=Producer(_name,_productionCapacity,_cpu,tabb);
        Entities[msg.sender] = 1;
    }
    
    function addProvider(string _name, uint _storageCapacity, uint _cpu) public CheckIfAlreadyEntity(msg.sender) {
        provider[msg.sender]=Provider(_name, _storageCapacity,_cpu);
        Entities[msg.sender] = 2;
    }
    
    function addConsumer(string _name, uint _storageCapacity, address _provider) public CheckIfAlreadyEntity(msg.sender) {
        TABS tabb;
        consumer[msg.sender] = Consumer(_name, _storageCapacity,_provider, tabb);
        Entities[msg.sender] = 3;
    }
    
     function addMoney(address accountOwner, uint money) internal{
         balancesOfMoney[accountOwner] = balancesOfMoney[accountOwner]+ money;
        
    }
    
    function balanceOfAccount(address accountOwner) public constant returns (uint balance) {
        return balancesOfMoney[accountOwner];
    }
    
    function setCostPerUnit(uint cpu) public{
        if(Entities[msg.sender]==1){
           producer[msg.sender].costPerUnit= cpu; 
        }
        else if(Entities[msg.sender] == 2){
            provider[msg.sender].costPerUnit= cpu; 
        }
        else if(Entities[msg.sender] ==3){
            costPerUnit[msg.sender] = cpu;  
        }
    }
    
     function SetCostPerUnit() internal returns(uint){
        uint cpu;
        if(Entities[msg.sender]==1){
          cpu= producer[msg.sender].costPerUnit; 
        }
        else if(Entities[msg.sender] == 2){
          cpu=  provider[msg.sender].costPerUnit; 
        }
        else if(Entities[msg.sender] ==3){
            if(urgency==true){
                cpu=20;
            }
            else
            cpu = 17;  
        }
        return(cpu); 
    }
    function TransferMoneyForEnergy(address from,address to, uint energy) internal returns (bool success, uint funds) {
        uint CostPerUint=SetCostPerUnit();
        uint money= energy*CostPerUint;
        require(balancesOfMoney[from] >= money);
        balancesOfMoney[from] = balancesOfMoney[from]- money;
        balancesOfMoney[to] = balancesOfMoney[to]+ money;
        emit TransferOfMoney(from, to, money);
        return (true,money);
    }
}






