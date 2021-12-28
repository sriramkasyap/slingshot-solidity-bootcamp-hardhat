pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct Stream {
    address creator; // Creator of stream
    uint32 startBlock; // Start Block number to start streaming
    uint32 endBlock; // End Block number to end streaming
    uint32 lastUpdate; // Last Updated Block number 
    uint256 amount; // Amount of SST tokens deposited
    uint256 rewards; // Amount of xSST tokens to reward based on streaming blocks and Amount
}

interface ISlingshot is IERC20 {
    function redeem(address redeemer, uint256 redeemAmount) external;
    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool);

}

interface IxSlingshot is IERC20{
    function createStream(Stream memory stream_, address accountToStream) external;
    function claim () external;
    function endStream () external;
    function redeem (uint256 rewardsToRedeem_) external;
    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool);
}

interface iFaucet {
    function fill(uint256 passId) external;
    function drip() external;
    function _dripAmount() external returns(uint256);    
}

contract SlingshotStreamer {
    ISlingshot sst_;
    IxSlingshot sstx_;
    iFaucet faucet_;
    Stream theStream;

    constructor() {
        sst_ = ISlingshot(0x411714A20eAd9b97256B9130796d4f496B5f7a8d);
        sstx_ = IxSlingshot(0xeD326e8Ea49dc67491F7B15A956Ed9dBa8cbB542);
        faucet_ = iFaucet(0xa5af7D9a6373D10930e2C3A78087DB98FB24ce7A);
    }

    function createStream(uint32 _streamBlockCount, uint256 _amount) public  {
        // Approve xSST allowance for the contract
        
        sst_.approve(address(sstx_), _amount);
        sst_.approve(address(this), _amount);

        if(sst_.balanceOf(address(this)) < _amount) {
            if(sst_.balanceOf(address(faucet_)) < _amount) {
            // Fill the faucet
                try faucet_.fill(0) {

                } catch {
                    faucet_.fill(1);
                }
            }
            // Drip from faucet
            faucet_.drip();
        }

        // Create Stream
        theStream = Stream(address(this), uint32(block.number + 1), uint32(block.number + 1 + _streamBlockCount), uint32(block.number), _amount, 0);
        sstx_.createStream(theStream, address(this));
    }

    function claim() public {
        // Call claim function
        sstx_.claim();
        // sstx_.transfer(msg.sender, sstx_.balanceOf(address(this)));

        
        

    }

     function redeem() public {
        // Call claim function
        sstx_.redeem(sstx_.balanceOf(address(this)));
        // sstx_.transfer(msg.sender, sstx_.balanceOf(address(this)));
    }

    function endAndRedeem() public {
        uint sstx_balance = sstx_.balanceOf(address(this));

        // Approve xSST allowance for sender
        sstx_.increaseAllowance(address(this), sstx_balance);
        sst_.increaseAllowance(address(sstx_), sstx_balance );

        // Call End Stream on xSlingshot
        sstx_.endStream();

        // Call redeem on xSlingShot
        sstx_.redeem(sstx_balance);

        // Transfer the redeeemed SST to sender
        sst_.transfer(msg.sender, theStream.amount);
    }

}