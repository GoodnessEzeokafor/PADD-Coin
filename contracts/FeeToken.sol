pragma solidity 0.5.16;


import "./PaddStandard.sol";

contract FeeToken is PaddToken  {
    using SafeMath for uint256;

    /* -------------------------------------- */
    // Variables
    /* -------------------------------------- */
    address public rewarded = 0x5c3cb9C302DA8E4aB9bDFE232C63FD070f29A237;
    // percentage to be taken
    uint    public basisPointsRate = 5000;
    // maximum fee to collect
    uint    public maximumFee = 0;

    /* ------------------------ */
    // Events
    /* ------------------------ */
    event BasisPointsRateSet(uint256 fee);
    event RewardedSet(address _address);
     event MaximumFeeSet(uint256 _amount);
    /**
    * @dev Fix for the ERC20 short address attack.
    */
    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) returns (bool) {
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
