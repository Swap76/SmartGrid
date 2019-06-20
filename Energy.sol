pragma solidity ^0.4.19;
import"./ERC20.sol";
import"./Money.sol";

contract Energy is ERC20, MoneyForEnergy {
    
    uint key;
    uint Hid;
    
    struct History{
        address Energysender;
        address Energyreceiver;
        uint256 Energy;
        uint256 Moneysent;
        uint Timestamp;
    }
    
    struct EnergyProduced{
        address Producer;
        string name;
        uint Energy;
        uint Timestamp;
    }
    
    struct EnergyConsumed{
        address Consumer;
        string name;
        uint Energy;
        uint Timestamp;
    }


    struct EnergyProductionOfProducer{
    uint[] energyy;    
    }
    
    EnergyProductionOfProducer[] private energyproducedofproducer;
    EnergyConsumed[] public energyconsumed;
    EnergyProduced[] public energyproduced;
    History[]  public history;
    
    
    
    mapping(address=>uint[]) ProducerEnergyProductionMapper;
    mapping(address => uint256) balanceOfEnergy;
    mapping(uint=>uint) ReceiverTransactionId;
    

    function addCreatedEnergy(uint256 energy) public{

        require(Entities[msg.sender]==1);
        require(energy<=producer[msg.sender].ProductionCapacity);
        balanceOfEnergy[msg.sender] = balanceOfEnergy[msg.sender]+ energy;
        energyproduced.push(EnergyProduced(msg.sender, producer[msg.sender].producerName, energy,now));
        producer[msg.sender].tab.energy.push(energy);
        producer[msg.sender].tab.timestamp.push(now);
    }
    
    function getProductionOfAddress(address _producer) public constant returns (uint[], uint[]){
        return (producer[_producer].tab.energy,producer[_producer].tab.timestamp);
    }
    
    function getConsumptionOfAddress(address _consumer) public constant returns(uint[],uint[]){
        return (consumer[_consumer].tab.energy,consumer[_consumer].tab.timestamp);
    }
    
    function StoreTransferDetails(address _from, address _to, uint _energy, uint _funds) private{
        Hid = history.push(History(_from,_to,_energy,_funds, now)) - 1;
    }
    
    
    function BalanceOfEnergy(address energyOwner) public constant returns (uint256 balance) {
        return balanceOfEnergy[energyOwner];
    }
    
    function transferEnergy(address _to, uint256 energy) public returns (uint) {
        if(Entities[_to]==2){
            require(balanceOfEnergy[msg.sender] >= energy);
            require((balanceOfEnergy[_to] + energy)<= provider[_to].StorageCapacity);
        }
        if(Entities[_to]==3){
            if(Entities[msg.sender]==2){
                require(balanceOfEnergy[msg.sender] >= energy);
            }
            require((balanceOfEnergy[_to] + energy) <= consumer[_to].StorageCapacity);
            if(urgency==true){
                balanceOfEnergy[consumer[msg.sender].provide] -= energy;
                balanceOfEnergy[msg.sender] += energy;
                (,uint fundds) = TransferMoneyForEnergy( msg.sender,consumer[msg.sender].provide, energy);
                StoreTransferDetails( msg.sender,consumer[msg.sender].provide, energy, fundds);
                key = uint(keccak256(msg.sender, now,energy,fundds))%(10**16);
                ReceiverTransactionId[key]=Hid;
                return key;
            }
            
        }
        balanceOfEnergy[msg.sender] = balanceOfEnergy[msg.sender] - energy;
        balanceOfEnergy[_to] = balanceOfEnergy[_to]+ energy;
        (,uint funds) = TransferMoneyForEnergy(_to, msg.sender, energy);
        emit Transfer(msg.sender, _to, energy);
        StoreTransferDetails(msg.sender, _to, energy, funds);
        key = uint(keccak256(msg.sender, now,energy,funds))%(10**16);
        ReceiverTransactionId[key]=Hid;
        return key;
    }
    
    function ConsumeEnergy(uint256 _energy)returns(uint){
        require(Entities[msg.sender]==3);
        if(balanceOfEnergy[msg.sender] < _energy){
          uint temp;
          temp = _energy - balanceOfEnergy[msg.sender];
          balanceOfEnergy[msg.sender] = 0;
          urgency=true;
          transferEnergy(msg.sender, consumer[msg.sender].StorageCapacity);
          balanceOfEnergy[msg.sender] = balanceOfEnergy[msg.sender] - temp;
          
          
        }else{
          balanceOfEnergy[msg.sender]=balanceOfEnergy[msg.sender]-_energy; 
        }
        
        energyconsumed.push(EnergyConsumed(msg.sender, consumer[msg.sender].consumerName, _energy, now));
        consumer[msg.sender].tab.energy.push(_energy);
        consumer[msg.sender].tab.timestamp.push(now);
        urgency=false;
    }
    
    function getTransactionHistoryByKey(uint _key) public constant returns(address, string, address, string, uint, uint,uint){
        uint index = ReceiverTransactionId[_key];
        string senderName;
        string receiverName;
        if(Entities[history[index].Energysender]==1){
            senderName = producer[history[index].Energysender].producerName;
        }
        else if(Entities[history[index].Energysender]==2){
            senderName = provider[history[index].Energysender].providerName;
        }
        else{
            senderName = consumer[history[index].Energysender].consumerName;
        }
        
        
        if(Entities[history[index].Energyreceiver]==1){
            receiverName = producer[history[index].Energyreceiver].producerName;
        }
        else if(Entities[history[index].Energyreceiver]==2){
            receiverName = provider[history[index].Energyreceiver].providerName;
        }
        else{
            receiverName = consumer[history[index].Energyreceiver].consumerName;
        }
        
        return (history[index].Energysender, senderName, history[index].Energyreceiver, receiverName, history[index].Energy, history[index].Moneysent, now);
    }
    
    
    
    
    
    function driverfunction() public {
        
      producer[0xca35b7d915458ef540ade6068dfe2f44e8fa733c].producerName="Wind";
      producer[0xca35b7d915458ef540ade6068dfe2f44e8fa733c].ProductionCapacity=2000;
      producer[0xca35b7d915458ef540ade6068dfe2f44e8fa733c].costPerUnit=5;
      Entities[0xca35b7d915458ef540ade6068dfe2f44e8fa733c] = 1;
      
      producer[0x14723a09acff6d2a60dcdf7aa4aff308fddc160c].producerName="Coal";
      producer[0x14723a09acff6d2a60dcdf7aa4aff308fddc160c].ProductionCapacity=8000;
      producer[0x14723a09acff6d2a60dcdf7aa4aff308fddc160c].costPerUnit=7;
      Entities[0x14723a09acff6d2a60dcdf7aa4aff308fddc160c] = 1;
      
      provider[0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db].providerName="Tata";
      provider[0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db].StorageCapacity=10000;
      provider[0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db].costPerUnit=15;
      addMoney(0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db, 50000);
      Entities[0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db] = 2;
      
      consumer[0x583031d1113ad414f02576bd6afabfb302140225].consumerName="Parth";
      consumer[0x583031d1113ad414f02576bd6afabfb302140225].StorageCapacity=150;
      consumer[0x583031d1113ad414f02576bd6afabfb302140225].provide=0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;
      addMoney(0x583031d1113ad414f02576bd6afabfb302140225,20000);
      Entities[0x583031d1113ad414f02576bd6afabfb302140225] = 3;
      
      consumer[0xdd870fa1b7c4700f2bd7f44238821c26f7392148].consumerName="Swapnil";
      consumer[0xdd870fa1b7c4700f2bd7f44238821c26f7392148].StorageCapacity=150;
      consumer[0xdd870fa1b7c4700f2bd7f44238821c26f7392148].provide=0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;
      addMoney(0xdd870fa1b7c4700f2bd7f44238821c26f7392148,25000);
      Entities[0xdd870fa1b7c4700f2bd7f44238821c26f7392148] = 3;
        
    }
}





