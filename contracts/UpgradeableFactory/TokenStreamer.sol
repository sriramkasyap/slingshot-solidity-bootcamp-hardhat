pragma solidity ^0.8.9;

contract TokenStreamer {
    // Master  Contract
        // PROXY Storage (Dummies) - To avoid storage collision
        address public master;
        address public owner;
        
            // Recipient Address
            address public recipient;
            // Total Amount
            uint public total;
            // Previously Claimed Amount
            uint public claimed;
            // Start Time
            uint public startTime;
            // End Time
            uint public endTime;
            // Status - ACTIVE, DISABLED
            enum Status{INACTIVE, ACTIVE}
            Status public streamingStatus = Status.INACTIVE;

            
        modifier onlyRecipient {
            require(msg.sender == recipient, "You do not have authorization to claim this");
            _;
        }


        // Functions
            // Initialize (recipient, total, startTime, endTime) - Set - Payable
            function initialize(address _recipient,uint _total,uint  _startTime,uint _endTime) public payable {
                require(msg.value == _total, "Total amount should be deposited first");
                require(streamingStatus == Status.INACTIVE, "This Contract has already been initialized");
                require(_endTime > _startTime, "End Time should be greater than Start time");
                recipient = _recipient;
                total = _total;
                claimed = 0;
                startTime = _startTime;
                endTime = _endTime;
                streamingStatus = Status.ACTIVE;
            }

            // Get Current time helper
            function getCurrentTime() public view returns(uint) {
                return block.timestamp;
            }

            // Claim(amount) - Send Amount - Only Recipient
            function claim(uint _amount) public onlyRecipient {
                uint claimable = getClaimable();
                require(claimable >= _amount, "You cannot claim more than the streamed amount");
                payable(recipient).transfer(_amount);
                claimed = claimed + _amount;
            }
            
            // GetClaimable - Return Claimable amount
            function getClaimable() public view returns(uint){
                uint currentTime = getCurrentTime();
                return ((total / (endTime - startTime)) * (currentTime - startTime)) - claimed;
            }

            // ClaimAll - Send All Claimable Amount - Only recipient
            function claimAll() external onlyRecipient {
                uint  fullamount = getClaimable();
                payable(recipient).transfer(fullamount);
                claimed = claimed + fullamount;
            }

            // Get Contract Balance 
            function getBalance() public view returns(uint)  {
                return address(this).balance;
            }

            function whoisthis() public view returns(address)  {
                return address(this);
            }

            function whoami() public view returns (address) {
                return address(msg.sender);
            }

}