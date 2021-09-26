pragma solidity 0.5.16;

import "./PaddStandard.sol";
contract FeeToken is PaddToken  {
    using SafeMath for uint256;

    /* -------------------------------------- */
    // Mappings
    /* -------------------------------------- */
     mapping(address=>bool) isBlacklisted;

    /* -------------------------------------- */
    // Variables
    /* -------------------------------------- */
    address public rewarded = address(0);
    // percentage to be taken
    uint    public basisPointsRate = 0;
    // maximum fee to collect
    uint    public maximumFee = 0;

    /* ------------------------ */
    // Events
    /* ------------------------ */
    event BasisPointsRateSet(uint256 fee);
    event RewardedSet(address _address);
    event MaximumFeeSet(uint256 _amount);
    event AddressBlacklisted(address _address);
    event AddressUnBlacklisted(address _address);
    /**
    * @dev Fix for the ERC20 short address attack.
    */
    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }

 
    
    /**
    * @dev Blacklist an address from calling transfer function
    * @param _user The address to be blacklisted.
    */
   function blackList(address _user) public onlyOwner {
        require(!isBlacklisted[_user], "user already blacklisted");
        isBlacklisted[_user] = true;
        emit AddressBlacklisted(_user);
        }
    


    
    /**
    * @dev remove an address fromblacklist
    * @param _user The address to be blacklisted.
    */
    function removeFromBlacklist(address _user) public onlyOwner {
        require(isBlacklisted[_user], "user already whitelisted");
        isBlacklisted[_user] = false;
         emit AddressUnBlacklisted(_user);
    }
    
 


       /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) returns (bool) {
        require(!isBlacklisted[_to], "Recipient is backlisted");

        uint fee = (_value.mul(basisPointsRate)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        uint sendAmount = _value.sub(fee);
        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(sendAmount);
        if (fee > 0) {
            _balances[rewarded] = _balances[rewarded].add(fee);
            emit Transfer(msg.sender, rewarded, fee);
        }
        emit Transfer(msg.sender, _to, sendAmount);
        return true;
    }

    /* -------------------------------------- */
    // Setters
    /* -------------------------------------- */
    function setBasisPoints(uint256 _basisPointsRate) public onlyOwner {
        basisPointsRate = _basisPointsRate;
        emit BasisPointsRateSet(basisPointsRate);
    }
    function setRewarded(address _address) public onlyOwner {
        rewarded = _address;
        emit RewardedSet(_address);
    }
     function setMaximumFee(uint256 _maximumFee) public onlyOwner {
        maximumFee = _maximumFee;
        emit MaximumFeeSet(_maximumFee);
    }

  
}
