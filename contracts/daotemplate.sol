pragma solidity ^0.8.4;

// SPDX-License-Identifier: MIT

import "./openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";


contract daotemplate is ERC20, ERC20Burnable {
    uint quorum;
    uint quorumend;
    uint ProposedQuorum;
    uint quorumvotes;

    uint threshold;
    uint thresholdend;
    uint proposedThreshold;
    uint thresholdvotes;

    uint locktime; // days but block.timestamp is in seconds
    uint locktimeend;
    uint proposedLocktime;
    uint locktimevotes;

    uint totalmembers;

    mapping (address => bool) staked;
    mapping (address => uint) amountstaked;
    mapping (address => Voter) BallotTracker;

    event StakeSubmitted(address staker, uint amount); 
    event ProposalAccepted();
    event ProposalFailed();
    event QuorumChanged(uint newValue);
    event thresholdChanged(uint newValue);
    event locktimeChanged(uint newValue);

    struct Proposals {
       bool quorum;
       bool threshold;
       bool locktime;
    }
    struct Voter {
       bool quorum;
       bool threshold;
       bool locktime;
    }

    Proposals private overview; // keeps track of what proposals are in progress

    constructor(string memory _name, string memory _symbol, uint _locktime, uint _quorum, uint _threshold) 
        ERC20(_name, _symbol) {
        // ERC20.decimals(0); mint by units of 1
        quorum = _quorum;
        threshold = _threshold;
        locktime = _locktime;
    }

    function stake() payable external {
        require(msg.value == threshold, 'stake requirement not met');
        // will this work? 10 AVAX or ETHER recognized just by int?
        require(staked[msg.sender] == false, 'has already staked');
        staked[msg.sender] = true;
        amountstaked[msg.sender] = msg.value;
        emit StakeSubmitted(msg.sender, msg.value);
        mint();
    }

    function mint() internal {
        require(staked[msg.sender] == true, 'has not staked');
        _mint(msg.sender, 1);
        totalmembers++;
    }

    function withdraw() external {
        require(staked[msg.sender] == true, 'has not staked');
        _burn(msg.sender, 1);
        staked[msg.sender] == false;
        uint transfervalue = amountstaked[msg.sender];
        totalmembers--;
        payable(msg.sender).transfer(transfervalue);
    }

    modifier DaoMember {
        require(staked[msg.sender] == true, 'not a dao Member (has not staked)');
        _;
    }

    function proposeChangeQuorum(uint newQuorum) external DaoMember {
        require(overview.quorum == false, 'quorum proposal in progress');
        overview.quorum = true;
        quorumend = block.timestamp + (locktime * 24 * 60 * 60);
        ProposedQuorum = newQuorum;
    }

    function voteQuorum(bool vote) external DaoMember {
        require(overview.quorum == true, 'no quorum proposal in progress');
        require(BallotTracker[msg.sender].quorum == false, 'has already voted');
        BallotTracker[msg.sender].quorum = true;
        if (block.timestamp < quorumend) {
            if (vote == true) {
                quorumvotes++;
            }
        }
        overview.quorum = false;
        decideQuorum();
    }
    function decideQuorum() internal {
        uint decimalfor = quorumvotes / totalmembers;
        if (decimalfor > (quorum / 100)) {
            quorum = ProposedQuorum;
            emit ProposalAccepted();
            emit QuorumChanged((ProposedQuorum));
        }
        emit ProposalFailed();
    }

    function resetQuorumVotes() external DaoMember {
        require(overview.quorum == false, 'quorum proposal in progress');
        BallotTracker[msg.sender].quorum = false;
    }

    function proposeChangeThreshold(uint newThreshold) external DaoMember {
        require(overview.threshold == false, 'threshold proposal in progress');
        overview.threshold = true;
        thresholdend = block.timestamp + (locktime * 24 * 60 * 60);
        proposedThreshold = newThreshold;
    }

    function voteThreshold(bool vote) external DaoMember {
        require(overview.threshold == true, 'no threshold proposal in progress');
        require(BallotTracker[msg.sender].threshold == false, 'has already voted');
        BallotTracker[msg.sender].threshold == true;
        if (block.timestamp < thresholdend) {
            if (vote == true) {
                thresholdvotes++;
            }
        }
        overview.threshold = false;
        decideThreshold();
    }

    function decideThreshold() internal {
        uint decimalfor = thresholdvotes / totalmembers;
        if (decimalfor > (quorum / 100)) {
            threshold = proposedThreshold;
            emit ProposalAccepted();
            emit thresholdChanged(proposedThreshold);
        }
        emit ProposalFailed();
    }

    function resetThresholdVotes() external DaoMember {
        require(overview.threshold == false, 'threshold proposal in progress');
        BallotTracker[msg.sender].threshold = false;
    }

    function proposeChangeLocktime(uint newLocktime) external DaoMember {
        require(overview.locktime == false, 'locktime proposal in progress');
        overview.locktime = true;
        locktimeend = block.timestamp + (locktime * 24 * 60 * 60);
        proposedLocktime = newLocktime;
    }

    function voteLocktime(bool vote) external DaoMember {
        require(overview.locktime == true, 'no locktime proposal in progress');
        require(BallotTracker[msg.sender].locktime == false, 'has already voted');
        BallotTracker[msg.sender].locktime == true;
        if (block.timestamp < locktimeend) {
            if (vote == true) {
                locktimevotes++;
            }
        }
        overview.locktime = false;
        decideLocktime();
    }

    function decideLocktime() internal {
        uint decimalfor = locktimevotes / totalmembers;
        if (decimalfor > (quorum / 100)) {
            locktime = proposedLocktime;
            emit ProposalAccepted();
            emit locktimeChanged(proposedLocktime);
        }
        emit ProposalFailed();
    }
    
    function resetLocktimeVotes() external DaoMember {
        require(overview.locktime == false, 'locktime proposal in progress');
        BallotTracker[msg.sender].locktime = false;
    }
}

