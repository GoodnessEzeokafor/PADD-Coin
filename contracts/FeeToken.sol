contract FeeToken is PaddToken {
    using SafeMath for uint256;
 /* -------------------------------------- */
    // Mappings
    /* -------------------------------------- */
    mapping(address => bool) isBlacklisted;

    mapping(address => bool) _isExcludedFromFee;

    /* -------------------------------------- */
    // Variables
    /* -------------------------------------- */
    address public rewarded = address(0);
    // percentage to be taken
    uint256 public basisPointsRate = 0;
    // maximum fee to collect
    uint256 public maximumFee = 0;

    /* ------------------------ */
    // Events
    /* ------------------------ */
    event BasisPointsRateSet(uint256 fee);
    event RewardedSet(address _address);
    event MaximumFeeSet(uint256 _amount);

    event AddressBlacklisted(address _address);
    event AddressUnBlacklisted(address _address);

    event AddressExempted(address _address);
    /**
     * @dev Fix for the ERC20 short address attack.
     */
    modifier onlyPayloadSize(uint256 size) {
        require(!(msg.data.length < size .add( 4)));
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

    //adding multiple addresses to the blacklist.subUsed to manually block known bots and scammers
    function batchBlackList(address[] memory addresses) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = true;
        }
    }

    function batchRemoveFromBlackList(address[] memory addresses)
        public
        onlyOwner
    {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = false;
        }
    }

    //set a wallet address so that it does not have to pay transaction fees
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    //set a wallet address so that it has to pay transaction fees
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value)
        public
        override
        onlyPayloadSize(2 * 32)
        returns (bool)
    {
        require(
            _msgSender() != address(0),
            "Bep20: transfer from the zero address"
        );
        require(!isBlacklisted[_msgSender()], "This address is backlisted");
        require(!isBlacklisted[_to], "Recipient is backlisted");
        require(_to != address(0), "Bep20: transfer to the zero address");
        require(_to != _msgSender(), "Bep20: cant transfer to Yourself");


        address sender = _msgSender();
        address recipient = _to;

        if (_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
            _transferWithFees(sender, recipient, _value);
        } else if (
            !_isExcludedFromFee[sender] && _isExcludedFromFee[recipient]
        ) {
            _transferWithFees(sender, recipient, _value);
        } else if (
            !_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]
        ) {
            _transferWithFees(sender, recipient, _value);
        } else if (
            _isExcludedFromFee[sender] && _isExcludedFromFee[recipient]
        ) {
            _transferWithoutFees(sender, recipient, _value);
        } else {
            _transferWithFees(sender, recipient, _value);
        }
        return true;
    }


    function _transferWithoutFees(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        // take no fee
        _balances[sender] = _balances[sender] .sub (amount);
        _balances[recipient] = _balances[recipient] .add (amount);

        emit Transfer(sender, recipient, amount);
    }
   function _transferWithFees(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        // take fee from recipient
        uint256 fee = calculateFees(amount);
        uint256 sendAmount = amount.sub(fee);

        _balances[sender] = _balances[sender].sub(amount.sub(fee.div(2)));
        _balances[recipient] = _balances[recipient] .add (sendAmount);

        // send fee to reward wallet
        if (fee > 0) {
            _balances[rewarded] = _balances[rewarded] .add (fee.div(2));
            // burn 50% of fee
            _burn(sender, (fee.div(2)));
            emit Transfer(sender, rewarded, fee);
        }
        emit Transfer(sender, recipient, sendAmount);
    }

    function calculateFees(uint256 amount) public view returns (uint256) {
        uint256 fee = (amount .mul (basisPointsRate)) .div(10000);
        
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        return fee;
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
