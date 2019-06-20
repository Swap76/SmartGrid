
pragma solidity ^0.4.19;
contract ERC20 {

    function transferEnergy(address to, uint tokens) public  returns (uint);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
}