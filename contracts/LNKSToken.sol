pragma solidity ^0.4.11;

import 'zeppelin/token/StandardToken.sol';              // ERC20 Standard Token interface
import 'LNKSVault.sol';                              

/// @title LNKS Token for which one token represents on gram of silver
/// @author Riaan F Venter~ RFVenter~ <msg@rfv.io>
contract LNKSToken is StandardToken {
    using SafeMath for uint;

    string public name = "Link Platform Silver Gram";     // Name of the Token
    string public symbol = "LNKS";                        // ERC20 compliant Token code
    uint public decimals = 18;                            // Token has 18 digit precision
    uint public totalSupply;                              // Total supply

    uint public transferFee;                              // 6 decimal percentage
    uint public storageFee;
    uint private storageFeeLoopCounter;

    mapping(address => uint) balances;
    mapping(address => bool) balances_exist;
    address[] balances_list;                              // the list of token holders

    LNKSVault public vaultContract;


    modifier onlyPayloadSize(uint size) {
        if(msg.data.length < size + 4) throw;
        _;
    }

    modifier onlyVault() {
        if (msg.sender != address(vaultContract)) throw;
        _;
    }

    function LNKSToken(address _purchase) {
        vaultContract = new LNKSPurchase(_purchase);
    }

    function setvaultContract(address _purchase) 
        onlyOwner {

        vaultContract = new LNKSPurchase(_purchase);
    }

    function setTransferFee(uint _transferFee)
        onlyOwner {

        transferFee = _transferFee;
    }

    function setStorageFee(uint _storageFee)
        onlyOwner {

        storageFee = _storageFee;
    }

    function setStorageFeePeriod(uint _storageFeePeriod)
        onlyOwner {

        storageFeePeriod = _storageFeePeriod;
    }

    function chargeStorageFees(uint _iterations) 
        onlyOwner {

        if (storageFeeLoopCounter != 0) {
            var iterEnd = storageFeeLoopCounter + _iterations;
            if (iterEnd > balances_list.length) iterEnd = balances_list.length;
            for (var i = storageFeeLoopCounter; i < iterEnd; i++) {
                var fee = balances[balances_list[iterEnd]].mul(storageFee);
            }
        }

        var sinceLastCharge = now - lastStorageFeeCharged;        // the time since the last charge
        var chargeIterations = sinceLastCharge / storageFeePeriod;    // the charge cycles since the last charge

    }

    function transferFrom(address _from, address _to, uint _value) 
        onlyPayloadSize(3 * 32) {

        var _allowance = allowed[_from][msg.sender];

        var fee = doTransfer(_from, _to, _value);

        allowed[_from][msg.sender] = _allowance.sub(_value.add(fee));  
    }

    function transfer(address _to, uint _value) 
        onlyPayloadSize(2 * 32) {

        doTransfer(msg.sender, _to, _value);
    }

    function doTransfer(address _from, address _to, uint _value) 
        internal 
        returns (uint fee) {

        fee = calcFee(_value);

        if (balances[_from] < _value.add(fee)) throw;

        if (!balances_exist(_to)) {
            balances_list.push(_to);          
            balances_exist(_to) = true;
        }

        balances[0] += fee;
        balances[_from] -= fee;

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);

        if (_to == address(vaultContract)) vaultContract.sellOrder(_from, _value);

        Transfer(_from, _to, _value);
    }

    function createTokens(address _to, uint _value) 
        external
        onlyVault {

        if (!balances_exist(_to)) {
            balances_list.push(_to);          
            balances_exist(_to) = true;
        }

        balances[_to] = balances[_to].add(_value);
        totalSupply = totalSupply.add(_value);
    }

    function destroyTokens(uint _value) 
        external
        onlyVault {

        address vault = address(vaultContract);

        balances[vault] = balances[vault].sub(_value);
        totalSupply = totalSupply.sub(_value);
    }
}