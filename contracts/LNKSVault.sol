pragma solidity ^0.4.11;

import 'zeppelin/ownership/Ownable.sol';                // Token owned by a MultiSig Wallet
import 'rfv/Drainable.sol';                             // Enables ETH withdraw to owner

/// @title 
/// @author Riaan F Venter~ RFVenter~ <msg@rfv.io>
contract LNKSVault is Drainable {
    uint public storageFee;                               // 6 decimal percentage
    uint public storageFeePeriod;                         // how many seconds between each storage fee
    uint public lastStorageFeeCharged;                    // the unix timestamp of when the last stoarge fee was charged

    ERC20 private lnkToken;                               
    address private lnkTokenAddress;

    address[] public lnksHolders;
    address[] public lnkHolders;

    Order[] public buyOrders;
    Order[] public sellOrders;

    
    struct Order { 
        address address; 
        uint amount;
    }

    modifier onlyToken() {
        if (msg.sender != address(lnkToken)) throw;
        _;
    }

    function buyOrder() {

      buyOrders.push(Order(msg.sender, msg.value));
    }

    function sellOrder(address _from, uint _value) 
        onlyToken {

        sellOrders.push(Order(_from, _value));
    }

    function buy()
        onlyOwner {

        if (index >= array.length) return;

        for (uint i = index; i<array.length-1; i++){
          array[i] = array[i+1];
        }
        delete array[array.length-1];
        array.length--;
        return array;

        buyOrders.push(Order(msg.sender, msg.value));
    }

    function sell() 
      onlyOwner {

      buyOrders.push(Order(msg.sender, msg.value));
    }


    function setToken(address _token) 
      onlyOwner {

      lnkTokenAddress = _token;
      lnkToken = ERC20(_token);
    }

    function removelnksHolder(address _lnksHolder)
      internal {

      for (uint i = 0; i < lnksHolders.length; i++) {
        if (lnksHolders[i] == _lnksHolder) {
          lnksHolders[i] = 0;
          break;
    }

    function addLnkHolder(address _lnkHolder)
      external
      returns (bool _success) {

      for (uint i = 0; i < lnkHolders.length; i++) {
        if (lnkHolders[i] == _lnkHolder) return false;
      }
      if (lnkToken.balanceOf(_lnkHolder) == 0) return false;
      lnkHolders.push(_lnkHolder);
      return true;
        }


    function setToken(address _token) 
      onlyOwner {

      lnkTokenAddress = _token;
      lnkToken = ERC20(_token);
    }

    function removelnksHolder(address _lnksHolder)
      internal {

      for (uint i = 0; i < lnksHolders.length; i++) {
        if (lnksHolders[i] == _lnksHolder) {
          lnksHolders[i] = 0;
          break;
    }

    function addLnkHolder(address _lnkHolder)
      external
      returns (bool _success) {

      for (uint i = 0; i < lnkHolders.length; i++) {
        if (lnkHolders[i] == _lnkHolder) return false;
      }
      if (lnkToken.balanceOf(_lnkHolder) == 0) return false;
      lnkHolders.push(_lnkHolder);
      return true;
    }
    
        
    function refund() external {
        // Abort if not in Funding Failure state.
        if (!funding) throw;
        if (block.number <= fundingEndBlock) throw;
        if (totalTokens >= tokenCreationMin) throw;

        var gntValue = balances[msg.sender];
        if (gntValue == 0) throw;
        balances[msg.sender] = 0;
        totalTokens -= gntValue;

        var ethValue = gntValue / tokenCreationRate;
        Refund(msg.sender, ethValue);
        if (!msg.sender.send(ethValue)) throw;
    }
    contract IController {
    function assertIsWhitelisted(address _target) public constant returns(bool);
    function lookup(bytes32 _key) public constant returns(address);
    function assertOnlySpecifiedCaller(address _caller, bytes32 _allowedCaller) public constant returns(bool);
    function stopInEmergency() constant returns(bool);
    function onlyInEmergency() constant returns(bool);
}
}
